//
//  CellsVM.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 18/05/22.
//

import Foundation
import MathParser

enum CellFormulaError: Error {
    case invalidFormula
    case cellOutOfRange
    case circularDependency(Set<Cell>)

    var errorMessage: String {
        switch self {
        case .invalidFormula: return "Invalid Formula"
        case .cellOutOfRange: return "Out of range"
        case .circularDependency: return "Circular Dependency"
        }
    }
}

class CellsVM: ObservableObject {
    // Regex matches strings like "A1", "B22" etc.
    private static let regex = try! NSRegularExpression(pattern: #"(?<cell>[A-Z]{1}[0-9]+)"#)

    let rows = 11
    let cols = 14
    private var parents = [Cell: Set<Cell>]()

    @Published var grid: [[Cell]]

    // Single tapping a cell highlights it
    // When highlighted cell changes, we recompute the old highlighted cell
    @Published var highlightedCell: Cell? {
        didSet {
            recompute(cell: oldValue)
        }
    }

    // Double tapping a cell - or single tapping a highlighted cell - selects it
    @Published var selectedCell: Cell?

    init() {
        var c = [[Cell]]()
        for r in 0..<rows {
            var row = [Cell]()
            for c in 0..<cols {
                row.append(Cell(row: r, col: c))
            }
            c.append(row)
        }
        self.grid = c
    }

    private func recompute(cell: Cell?) {
        guard let cell = cell else { return }
        var newChildren = Set<Cell>()
        do {
            if cell.rawString.starts(with: "=") {
                let formula = String(cell.rawString.dropFirst())
                let (parsed, children) = try parseFormula(formula)
                let value = try evaluateFormula(parsed)
                cell.value = value
                cell.valueString = String(format: "%.2f", value)
                newChildren = children
            } else {
                cell.value = Double(cell.rawString)
                cell.valueString = cell.rawString
            }
        } catch let error as CellFormulaError {
            cell.value = nil
            cell.valueString = error.errorMessage
        } catch {
            cell.value = nil
            cell.valueString = "Error"
        }

        // Detect any circular dependencies that might have been created
        // as a result of the this recomputation.
        do {
            try ensureNoCircularDependencies(cell, children: newChildren)
            updateDeps(for: cell, children: newChildren)
            parents[cell]?.forEach { recompute(cell: $0) }
        } catch CellFormulaError.circularDependency(let cells) {
            let msg = CellFormulaError.circularDependency(cells).errorMessage
            cells.forEach { cell in
                cell.value = nil
                cell.valueString = msg
            }
        } catch {
            cell.value = nil
            cell.valueString = "Error"
        }
    }

    // Parses the formula by replacing all cell refs with their values.
    // Returns the formula with all refs replaced by cell values, and a set of
    // extracted cells. Throws cellOutOfRange if any extracted cell is out of
    // spreadsheet bounds.
    private func parseFormula(_ formula: String) throws -> (String, Set<Cell>) {
        var new = formula
        let range = NSRange(formula.startIndex..<formula.endIndex, in: formula)
        let matches = Self.regex.matches(in: formula, options: [], range: range)
        var children = Set<Cell>()
        for match in matches {
            let cellStrRange = Range(match.range(withName: "cell"), in: formula)!
            let cellStr = String(formula[cellStrRange])
            let row = Int(cellStr.dropFirst())!
            let col = Int(cellStr.first!.asciiValue! - 64)
            guard row < grid.count, col < grid[0].count else {
                throw CellFormulaError.cellOutOfRange
            }
            let childCell = grid[row][col]
            children.insert(childCell)
            new = new.replacingOccurrences(of: cellStr, with: String(childCell.value ?? 0))
        }
        return (new, children)
    }

    private func ensureNoCircularDependencies(_ cell: Cell, children: Set<Cell>) throws {
        var remainingChildren = Array(children)
        var seenChildren = Set<Cell>()
        while !remainingChildren.isEmpty {
            let current = remainingChildren.removeFirst()
            if seenChildren.contains(current) {
                throw CellFormulaError.circularDependency(seenChildren)
            }
            seenChildren.insert(current)
            remainingChildren.append(contentsOf: current.children)
        }
    }

    // Evaluates a formula like "2+(3*6)" and returns the numerical value.
    // Throws invalidFormula if there's any error in formula
    private func evaluateFormula(_ formula: String) throws -> Double {
        do {
            return try formula.evaluate()
        } catch {
            throw CellFormulaError.invalidFormula
        }
    }

    private func updateDeps(for cell: Cell, children: Set<Cell>) {
        // Remove this cell from parents dict of current children
        // If this causes the parents dict to have empty value set,
        // remove the empty set from dict as well.
        for oldChild in cell.children {
            parents[oldChild]?.remove(cell)
            if parents[oldChild]?.isEmpty ?? false {
                parents.removeValue(forKey: oldChild)
            }
        }

        // For each new child, add this cell as child's parent.
        for child in children {
            var parentCells = parents[child, default: []]
            parentCells.insert(cell)
            parents[child] = parentCells
        }

        // Finally, update this cell's childrens so we can use it to remove
        // this cell from each children's parent set whenever this cell's value
        // is next updated.
        cell.children = children
    }
}

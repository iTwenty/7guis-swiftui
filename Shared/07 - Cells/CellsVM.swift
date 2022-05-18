//
//  CellsVM.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 18/05/22.
//

import Foundation

class CellsVM: ObservableObject {
    let rows = 11
    let cols = 14
    private let solver = CellSolver()
    private var parents = [Cell: Set<Cell>]()

    @Published var cellsGrid: [[Cell]]

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
        self.cellsGrid = c
    }

    private func recompute(cell: Cell?) {
        guard let cell = cell else { return }
        var newChildren = Set<Cell>()
        do {
            let (val, children) = try solver.solve(cell, grid: cellsGrid)
            cell.value = val
            cell.valueString = "\(val)"
            newChildren = children
        } catch CellFormulaError.notAFormula {
            cell.value = Int(cell.rawString)
            cell.valueString = cell.rawString
        } catch let error as CellFormulaError {
            cell.value = nil
            cell.valueString = error.rawValue
        } catch {
            cell.value = nil
            cell.valueString = "error"
        }
        updateDeps(for: cell, children: newChildren)
        parents[cell]?.forEach { recompute(cell: $0) }
    }

    private func updateDeps(for cell: Cell, children: Set<Cell>) {
        for oldChild in cell.children {
            parents[oldChild]?.remove(cell)
            if parents[oldChild]?.isEmpty ?? false {
                parents.removeValue(forKey: oldChild)
            }
        }

        for child in children {
            var parentCells = parents[child, default: []]
            parentCells.insert(cell)
            parents[child] = parentCells
        }
        cell.children = children
        print(parents)
    }
}

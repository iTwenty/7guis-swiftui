//
//  CellSolver.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 16/05/22.
//

import Foundation
import MathParser

enum CellFormulaError: String, Error {
    case notAFormula = "Not a formula"
    case invalidFormula = "Invalid formula"
    case cellOutOfRange = "Cell out of range"
}

class CellSolver {
    /// Regex matches strings like "A1", "B22" etc.
    private static let regex = try! NSRegularExpression(pattern: #"(?<cell>[A-Z]{1}[0-9]+)"#)


    /// Solves the cell's formula, or throws an appropriate error.
    /// - Parameters:
    ///   - cell: Cell whose formula to solve
    ///   - grid: Array of all cells in spreadsheet. Used for resolving cell references in the formula
    /// - Returns: A tuple consisting of formula's resolved value and a set of all cell references in the
    /// formula.
    ///
    /// Throws in following cases -
    /// 1. Cell's formula doesn't begin with "=". Throws .notAFormula.
    /// 2. Cell's formula contains ref to a cell outside the bounds of spreadsheet. Throws .cellOutOfRange.
    /// 3. Cell's formula contains "=", but is not valid. Throws .invalidFormula.
    func solve(_ cell: Cell, grid: [[Cell]]) throws -> (Double, Set<Cell>) {
        guard cell.rawString.starts(with: "=") else {
            throw CellFormulaError.notAFormula
        }
        let formula = String(cell.rawString.dropFirst())
        var replacedFormula = formula
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
            replacedFormula = replacedFormula.replacingOccurrences(of: cellStr, with: String(childCell.value ?? 0))
        }
        do {
            let value = try replacedFormula.evaluate()
            return (value, children)
        } catch {
            throw CellFormulaError.invalidFormula
        }
    }
}


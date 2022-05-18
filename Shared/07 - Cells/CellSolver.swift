//
//  CellSolver.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 16/05/22.
//

import Foundation

enum CellFormulaError: String, Error {
    case notAFormula = "Not a formula"
    case invalidFormula = "Invalid formula"
    case cellOutOfRange = "Cell out of range"
}

class CellSolver {
    private static let regex = try! NSRegularExpression(pattern: #"(?<cell>[A-Z]{1}[0-9]+)"#)

    func solve(_ cell: Cell, grid: [[Cell]]) throws -> (Int, Set<Cell>) {
        guard cell.rawString.starts(with: "=") else {
            throw CellFormulaError.notAFormula
        }
        let formula = String(cell.rawString.dropFirst())
        guard !formula.isEmpty else {
            throw CellFormulaError.invalidFormula
        }
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
        let expression = NSExpression(format: replacedFormula)
        let val = expression.expressionValue(with: nil, context: nil)
        guard let val = val as? Int else {
            throw CellFormulaError.invalidFormula
        }
        return (val, children)
    }
}


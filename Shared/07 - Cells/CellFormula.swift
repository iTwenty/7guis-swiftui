//
//  CellFormula.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 16/05/22.
//

import Foundation

enum CellFormulaError: String, Error {
    case invalidFormula = "Invalid formula"
    case cellOutOfRange = "Cell out of range"
}

class CellFormula {
    private static let pattern = #"(?<cell>[A-Z]{1}[0-9]+)"#
    private static let regex = try! NSRegularExpression(pattern: pattern)

    static func solve(_ formula: String, grid: [[Cell]]) throws -> Int {
        var newFormula = formula
        let range = NSRange(formula.startIndex..<formula.endIndex, in: formula)
        let matches = regex.matches(in: formula, options: [], range: range)
        for match in matches {
            let cellStrRange = Range(match.range(withName: "cell"), in: formula)!
            let cellStr = String(formula[cellStrRange])
            let row = Int(cellStr.dropFirst())!
            let col = Int(cellStr.first!.asciiValue! - 64)
            guard row < grid.count, col < grid[0].count else {
                throw CellFormulaError.cellOutOfRange
            }
            newFormula = newFormula.replacingOccurrences(of: cellStr, with: String(grid[row][col].value ?? 0))
        }
        let expression = NSExpression(format: newFormula)
        let val = expression.expressionValue(with: nil, context: nil)
        guard let val = val as? Int else {
            throw CellFormulaError.invalidFormula
        }
        return val
    }
}


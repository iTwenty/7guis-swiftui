//
//  Cell.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 18/05/22.
//

import Foundation

enum CellType: Hashable {
    case empty, rowHeader(String), colHeader(String), data

    static func from(row: Int, col: Int) -> CellType {
        if row == 0, col == 0 { return .empty }
        if row == 0 { return .colHeader((String(UnicodeScalar(col + 64)!))) }
        if col == 0 { return .rowHeader("\(row)") }
        else { return .data }
    }
}

class Cell: Identifiable, Hashable, CustomStringConvertible {
    let row, col: Int
    let type: CellType
    // String as entered by user. Displayed when this cell is selected cell
    var rawString: String
    // String representing the "parsed" value of rawString. Displayed when
    // this cell is highlighted cell. Can be
    // 1. same as rawString if rawString is not a formula
    // 2. parsed value of rawString if rawString is a valid formula
    // 3. error if rawString is an invalid formula
    var valueString: String
    // int value of the cell, or nil if rawString is either non-int or
    // invalid formula
    var value: Int?
    var children: Set<Cell>

    init(row: Int, col: Int) {
        self.row = row
        self.col = col
        self.type = CellType.from(row: row, col: col)
        self.rawString = ""
        self.valueString = ""
        children = []
     }

    // Protocol conformances
    var id: String { "\(row) \(col)" }
    static func == (lhs: Cell, rhs: Cell) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    var description: String { "\((String(UnicodeScalar(col + 64)!)))\(row)" }
}

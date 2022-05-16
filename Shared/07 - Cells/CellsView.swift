//
//  CellsView.swift
//  seven-guis (iOS)
//
//  Created by Jaydeep Joshi on 12/05/22.
//

import SwiftUI

enum CellType: Hashable {
    case empty, rowHeader(String), colHeader(String), data

    static func from(row: Int, col: Int) -> CellType {
        if row == 0, col == 0 { return .empty }
        if row == 0 { return .colHeader((String(UnicodeScalar(col + 64)!))) }
        if col == 0 { return .rowHeader("\(row)") }
        else { return .data }
    }
}

class Cell: Identifiable, Hashable {
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

    init(row: Int, col: Int) {
        self.row = row
        self.col = col
        self.type = CellType.from(row: row, col: col)
        self.rawString = ""
        self.valueString = ""
     }

    func recompute(grid: [[Cell]]) {
        guard rawString.starts(with: "=") else {
            value = Int(rawString)
            valueString = rawString
            return
        }
        do {
            value = try CellFormula.solve(String(rawString.dropFirst()), grid: grid)
            valueString = "\(value!)" // value guaranteed to be non nil here
        } catch let error as CellFormulaError {
            value = nil
            valueString = error.rawValue
        } catch {
            value = nil
            valueString = "error"
        }
    }

    // Protocol conformances
    var id: String { "\(row) \(col)" }
    static func == (lhs: Cell, rhs: Cell) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

class CellsVM: ObservableObject {
    let rows = 11
    let cols = 14
    @Published var cellsGrid: [[Cell]]

    // Single tapping a cell highlights it
    // When highlighted cell changes, we recompute the old highlighted cell
    @Published var highlightedCell: Cell? {
        didSet {
            oldValue?.recompute(grid: cellsGrid)
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
}

struct CellsView: View {
    @StateObject var vm = CellsVM()

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            rowViews
        }
    }

    @ViewBuilder private var rowViews: some View {
        VStack(spacing: 0) {
            ForEach($vm.cellsGrid, id: \.self) { $row in
                cellViews($row)
            }
        }
    }

    @ViewBuilder private func cellViews(_ row: Binding<[Cell]>) -> some View {
        HStack(spacing: 0) {
            ForEach(row) { $cell in
                let alignment: Alignment = (cell.type == .data ? .leading : .center)
                CellView(vm: vm, cell: $cell)
                    .frame(width: 100, height: 30, alignment: alignment)
                    .border(Color.gray, width: 0.5)
            }
        }
    }
}

struct CellView: View {
    @ObservedObject var vm: CellsVM
    @Binding var cell: Cell
    @FocusState var focused: Bool

    var body: some View {
        switch cell.type {
        case .empty:
            Text("")
        case .rowHeader(let title):
            Text(title)
        case .colHeader(let title):
            Text(title)
        case .data:
            dataView()
        }
    }

    @ViewBuilder
    private func dataView() -> some View {
        let highlighted = vm.highlightedCell == cell
        let selected = vm.selectedCell == cell

        ZStack {
            Text(cell.valueString)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(selected ? 0 : 1)
                .background(Color.primary.opacity(highlighted ? 0.1 : 0))
            TextField("", text: $cell.rawString)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(selected ? 1 : 0)
                .focused($focused)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .highPriorityGesture(doubleTapGesture())
        .simultaneousGesture(singleTapGesture())
        .onChange(of: focused) {
            if $0 {
                vm.highlightedCell = cell
                vm.selectedCell = cell
            }
        }
    }

    private func doubleTapGesture() -> some Gesture {
        TapGesture(count: 2).onEnded {
            vm.highlightedCell = cell
            vm.selectedCell = cell
            focused = true
        }
    }

    private func singleTapGesture() -> some Gesture {
        TapGesture().onEnded {
            if cell == vm.highlightedCell {
                focused = true
            } else {
                vm.highlightedCell = cell
                vm.selectedCell = nil
                focused = false
                NSApp.keyWindow?.makeFirstResponder(nil)
            }
        }
    }
}

struct CellsView_Previews: PreviewProvider {
    static var previews: some View {
        CellsView()
    }
}

//
//  CellsView.swift
//  seven-guis (iOS)
//
//  Created by Jaydeep Joshi on 12/05/22.
//

import SwiftUI

enum CellType: Hashable {
    case empty, rowHeader(Character), colHeader(Character), data

    static func from(row: Int, col: Int) -> CellType {
        if row == 0, col == 0 {
            return .empty
        } else if row == 0 {
            return .colHeader((Character(UnicodeScalar(col + 64)!)))
        } else if col == 0 {
            return .rowHeader(Character("\(row-1)"))
        } else {
            return .data
        }
    }
}

class Cell: Identifiable, Hashable {
    let row, col: Int
    let type: CellType
    var rawValue: String
    var computedValue: String

    init(row: Int, col: Int) {
        self.row = row
        self.col = col
        self.type = CellType.from(row: row, col: col)
        self.rawValue = ""
        self.computedValue = ""
    }

    func recompute(grid: [[Cell]]) {
        guard !rawValue.isEmpty else {
            computedValue = ""
            return
        }
        let expression = NSExpression(format: rawValue)
        let value = expression.expressionValue(with: nil, context: nil)
        guard let intValue = value as? Int else {
            computedValue = "error"
            return
        }
        computedValue = String(intValue)
    }

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
            VStack(spacing: 0) {
                ForEach($vm.cellsGrid, id: \.self) { $row in
                    HStack(spacing: 0) {
                        ForEach($row) { $cell in
                            CellView(vm: vm, cell: $cell)
                                .frame(width: 100, height: 30, alignment: (cell.type == .data ? .leading : .center))
                                .border(Color.gray)
                        }
                    }
                }
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
        case .rowHeader(let char):
            Text("\(char)" as String)
        case .colHeader(let char):
            Text("\(char)" as String)
        case .data:
            dataView()
        }
    }

    @ViewBuilder
    private func dataView() -> some View {
        let highlighted = vm.highlightedCell == cell
        let selected = vm.selectedCell == cell

        ZStack {
            Text(cell.computedValue)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(selected ? 0 : 1)
                .background(Color.primary.opacity(highlighted ? 0.1 : 0))
            TextField("", text: $cell.rawValue)
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

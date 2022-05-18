//
//  CellsView.swift
//  seven-guis (iOS)
//
//  Created by Jaydeep Joshi on 12/05/22.
//

import SwiftUI

struct CellsView: View {
    @StateObject var vm = CellsVM()

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            rowViews
        }
    }

    @ViewBuilder private var rowViews: some View {
        VStack(spacing: 0) {
            ForEach($vm.grid, id: \.self) { $row in
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

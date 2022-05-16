//
//  SevenGuisApp.swift
//  Shared
//
//  Created by Jaydeep Joshi on 08/05/22.
//

import SwiftUI

var tasks = ["01 - Counter",
             "02 - Temperature Converter",
             "03 - Flight Booker",
             "04 - Timer",
             "05 - CRUD",
             "06 - Circle Drawer",
             "07 - Cells"]

@main
struct SevenGuisApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                List(tasks, id: \.self) { task in
                    NavigationLink(task) {
                        view(for: task)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func view(for task: String) -> some View {
        switch task {
        case tasks[0]: CounterView()
        case tasks[1]: TempConverterView()
        case tasks[2]: FlightBookerView()
        case tasks[3]: TimerView()
        case tasks[4]: CrudView()
        case tasks[5]: CircleDrawerView()
        case tasks[6]: CellsView()
        default: Text("No task found!")
        }
    }
}

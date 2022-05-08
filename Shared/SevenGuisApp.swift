//
//  SevenGuisApp.swift
//  Shared
//
//  Created by Jaydeep Joshi on 08/05/22.
//

import SwiftUI

var tasks = ["01 - Counter",
             "02 - Temperature Converter"]

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
        default: Text("No task found!")
        }
    }
}

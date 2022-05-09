//
//  CrudView.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 09/05/22.
//

import SwiftUI

class Name: Identifiable, ExpressibleByStringLiteral, CustomStringConvertible {
    var fst = "", lst = ""
    var visible = true
    var id = UUID()

    init(_ firstName: String, _ lastName: String) {
        self.fst = firstName
        self.lst = lastName
    }

    required init(stringLiteral value: StringLiteralType) {
        let split = value.components(separatedBy: " ")
        guard split.count == 2 else {
            fatalError("Invalid name: \(value)")
        }
        (fst, lst) = (split[0], split[1])
    }

    var description: String { "\(fst) \(lst) : \(visible)" }
}

class CrudVM: ObservableObject {
    @Published var lstFilter: String
    @Published var names: [Name]
    @Published var selectedIndex: Int?

    init() {
        lstFilter = ""
        names = ["Emil Hans", "Mustermann Max", "Roman Tisch"]
    }

    func updateNameVisibilities() {
        names.forEach { name in
            name.visible = name.lst.localizedLowercase.starts(with: lstFilter.localizedLowercase)
        }
        objectWillChange.send()
    }

    func create(_ firstName: String, _ lastName: String) {
        names.append(Name(firstName, lastName))
        updateNameVisibilities()
    }

    func delete() {
        names.remove(at: selectedIndex!)
        selectedIndex = nil
        updateNameVisibilities()
    }

    func update(_ firstName: String, _ lastName: String) {
        let updated = names[selectedIndex!]
        updated.fst = firstName
        updated.lst = lastName
        names[selectedIndex!] = updated
        updateNameVisibilities()
    }
}

struct CrudView: View {
    @StateObject var vm = CrudVM()
    @State var selectedFirstName = ""
    @State var selectedLastName = ""

    var body: some View {
        VStack {
            TextField("Filter by last name", text: $vm.lstFilter)
                .onChange(of: vm.lstFilter) { _ in
                    vm.updateNameVisibilities()
                }
            HStack(alignment: .top) {
                List(vm.names.indices, id: \.self, selection: $vm.selectedIndex) { index in
                    let name = vm.names[index]
                    if name.visible {
                        Text("\(name.lst), \(name.fst)")
                    }
                }
                VStack {
                    TextField("First Name", text: $selectedFirstName)
                    TextField("Last Name", text: $selectedLastName)
                }
            }
            HStack {
                Button("Create") {
                    vm.create(selectedFirstName, selectedLastName)
                    selectedFirstName = ""
                    selectedLastName = ""
                }.disabled(selectedFirstName.isEmpty || selectedLastName.isEmpty)
                Button("Update") {
                    vm.update(selectedFirstName, selectedLastName)
                    selectedFirstName = ""
                    selectedLastName = ""
                }.disabled(vm.selectedIndex == nil || selectedFirstName.isEmpty || selectedLastName.isEmpty)
                Button("Delete") {
                    vm.delete()
                }.disabled(vm.selectedIndex == nil)
            }
        }
        .frame(width: 400, height: 400)
        .padding()
        .border(Color.secondary)
    }
}

struct CrudView_Previews: PreviewProvider {
    static var previews: some View {
        CrudView()
    }
}

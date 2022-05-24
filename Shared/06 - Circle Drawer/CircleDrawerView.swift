//
//  CircleDrawerView.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 10/05/22.
//

import SwiftUI

struct CircleDrawerView: View {
    @StateObject var vm = CircleDrawerVM()

    var body: some View {
        VStack {
            HStack {
                Button("Undo") {
                    vm.undo()
                }.disabled(vm.undoStack.isEmpty)
                Button("Redo") {
                    vm.redo()
                }.disabled(vm.redoStack.isEmpty)
            }
            GeometryReader { _ in
                ZStack {
                    ForEach($vm.circles) { circle in
                        let size = CGFloat(circle.wrappedValue.diameter)
                        CircleView(vm: vm, circle: circle)
                            .frame(width: size, height: size)
                            .position(circle.wrappedValue.center)
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(tapGesture())
            .frame(width: 400, height: 400)
            .border(Color.secondary)
        }
    }

    private func tapGesture() -> some Gesture {
        // SwiftUI's tap gesture doesn't inform us about tap location.
        // Workaround is to use a drag gesture with minimumDistance of 0.
        // Caveat is that the gesture will also be invoked if user drags,
        // and the location we get will be where user ended the drag.
        DragGesture(minimumDistance: 0)
            .onEnded { value in
                vm.addCircle(at: value.location)
            }
    }
}

struct CircleView: View {
    let vm: CircleDrawerVM
    @State var active = false
    @State var showAdjustPopover = false
    @Binding var circle: Circle

    var body: some View {
        SwiftUI.Circle()
            .stroke(Color.red, lineWidth: 2)
            .background(background)
            .onHover {
                self.active = $0
                vm.isAnyCircleActive = $0
            }
            .contextMenu {
                Button("Adjust Diameter") { showAdjustPopover = true }
            }.popover(isPresented: $showAdjustPopover) {
                VStack {
                    Text("Adjust diameter of circle at \(circle.centerDescription)")
                    Slider(value: $circle.diameter, in: 10...100) { editing in
                        if editing {
                            vm.diameterChangeStarted(circle)
                        } else {
                            vm.diameterChangeEnded(circle)
                        }
                    }
                }.padding()
            }
    }

    private var background: some View {
        Color.gray.opacity(active ? 0.5 : 0.0).clipShape(SwiftUI.Circle())
    }
}

struct CircleDrawerView_Previews: PreviewProvider {
    static var previews: some View {
        CircleDrawerView()
    }
}

//
//  CircleDrawerView.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 10/05/22.
//

import SwiftUI

class Circle: Identifiable, Hashable {
    var diameter: Double = 40
    var center: CGPoint
    var id: CGPoint {
        center
    }

    init(center: CGPoint) {
        self.center = center
    }

    static func == (lhs: Circle, rhs: Circle) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var centerDescription: String {
        let xDesc = String(format: "%.1f", center.x)
        let yDesc = String(format: "%.1f", center.y)
        return "(\(xDesc), \(yDesc))"
    }
}

enum UserAction {
    case addCircle(center: CGPoint)
    case changeDiameter(center: CGPoint, from: Double, to: Double)
}

class CircleDrawerVM: ObservableObject {
    @Published var circles = [Circle]()
    @Published var undoStack = [UserAction]()
    @Published var redoStack = [UserAction]()
    // We don't want user to be able to add circles when he hovering over any
    // existing circle. This boolean tracks if mouse is hovering above a circle
    var isAnyCircleActive = false
    // Since we want user to be able to undo diameter changes, we need to save
    // the diameter before the change. UI allows only one circle's diameter to
    // be changed at a time. So we can use a single Double value representing
    // the old diameter of the circle being changed.
    private var oldDiameter: Double?

    func addCircle(at center: CGPoint) {
        if isAnyCircleActive {
            return
        }
        redoStack.removeAll()
        privateAddCircle(at: center)
        undoStack.append(.addCircle(center: center))
    }

    private func privateAddCircle(at center: CGPoint) {
        circles.append(Circle(center: center))
    }

    func diameterChangeStarted(_ circle: Circle) {
        redoStack.removeAll()
        oldDiameter = circle.diameter
    }

    func diameterChangeEnded(_ circle: Circle) {
        guard let old = oldDiameter else { return }
        let new = circle.diameter
        undoStack.append(.changeDiameter(center: circle.center, from: old, to: new))
    }

    func undo() {
        guard let last = undoStack.popLast() else { return }
        switch last {
        case .addCircle(let center):
            circles.removeAll { $0.center == center }
        case .changeDiameter(let center, let from, _):
            guard let c = circles.first(where: { $0.center == center }) else { return }
            c.diameter = from
        }
        redoStack.append(last)
    }

    func redo() {
        guard let last = redoStack.popLast() else { return }
        switch last {
        case .addCircle(let center):
            privateAddCircle(at: center)
        case .changeDiameter(let center, _, let to):
            guard let c = circles.first(where: { $0.center == center }) else { return }
            c.diameter = to
        }
        undoStack.append(last)
    }
}

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
            GeometryReader { proxy in
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
            .stroke(Color.red)
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

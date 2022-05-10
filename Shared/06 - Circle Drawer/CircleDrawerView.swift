//
//  CircleDrawerView.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 10/05/22.
//

import SwiftUI

class Circle: Identifiable, Hashable {
    var id = UUID()
    var diameter: Double = 40
    var center: CGPoint

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
    case addCircle(id: UUID)
    case changeDiameter(id: UUID, from: Double, to: Double)
}

class CircleDrawerVM: ObservableObject {
    @Published var circles = [Circle]()

    func addCircle(at center: CGPoint) {
        let circle = Circle(center: center)
        circles.append(circle)
    }

    func changeDiameter(id: UUID, to new: Double) {
        guard let c = circles.first(where: { $0.id == id }) else {
            return
        }
        c.diameter = new
    }
}

struct CircleDrawerView: View {
    @StateObject var vm = CircleDrawerVM()

    var body: some View {
        VStack {
            HStack {
                Button("Undo") {}
                Button("Redo") {}
            }
            GeometryReader { proxy in
                ZStack {
                    ForEach($vm.circles) { circle in
                        let size = CGFloat(circle.wrappedValue.diameter)
                        CircleView(circle: circle)
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
                print(value.location)
                vm.addCircle(at: value.location)
            }
    }
}

struct CircleView: View {
    @State var active = false
    @State var showAdjustPopover = false
    @Binding var circle: Circle

    var body: some View {
        SwiftUI.Circle()
            .stroke(Color.red)
            .background(background)
            .onHover { self.active = $0 }
            .contextMenu {
                Button("Adjust Diameter") { showAdjustPopover = true }
            }.popover(isPresented: $showAdjustPopover) {
                VStack {
                    Text("Adjust diameter of circle at \(circle.centerDescription)")
                    Slider(value: $circle.diameter, in: 10...100)
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

//
//  CircleDrawerVM.swift
//  seven-guis
//
//  Created by jaydeep on 20/05/22.
//

import Foundation

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

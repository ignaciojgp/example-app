//
//  TodoItem.swift
//  example-app
//

import Foundation

struct TodoItem: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }

    /// "checkmark.circle.fill" si está completada; si no, "circle".
    var symbolName: String {
        isCompleted ? "checkmark.circle.fill" : "circle"
    }

    /// "completada" / "pendiente": es el accessibilityValue del botón de completar.
    var accessibilityStateValue: String {
        isCompleted ? "completada" : "pendiente"
    }
}

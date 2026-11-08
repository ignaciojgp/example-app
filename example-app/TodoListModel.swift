//
//  TodoListModel.swift
//  example-app
//

import Foundation
import Observation

@Observable
final class TodoListModel {
    private(set) var items: [TodoItem]
    var draftTitle: String

    init(items: [TodoItem] = [], draftTitle: String = "") {
        self.items = items
        self.draftTitle = draftTitle
    }

    /// Recorta los espacios y saltos de línea del inicio y del final.
    static func normalized(_ title: String) -> String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// true si `normalized(draftTitle)` no está vacío (habilita addTaskButton).
    var canAddDraft: Bool {
        !Self.normalized(draftTitle).isEmpty
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    /// Agrega al final si el título normalizado no está vacío. Devuelve si se agregó.
    @discardableResult
    func add(title: String) -> Bool {
        let trimmed = Self.normalized(title)
        guard !trimmed.isEmpty else { return false }
        items.append(TodoItem(title: trimmed))
        return true
    }

    /// Agrega el borrador; si se agregó, vacía `draftTitle`.
    func addDraft() {
        if add(title: draftTitle) {
            draftTitle = ""
        }
    }

    /// Alterna `isCompleted` de la tarea con ese id; si el id no existe, no hace nada.
    func toggle(id: TodoItem.ID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isCompleted.toggle()
    }

    /// Elimina por posiciones y conserva el orden del resto.
    func remove(atOffsets offsets: IndexSet) {
        for index in offsets.sorted(by: >) where items.indices.contains(index) {
            items.remove(at: index)
        }
    }
}

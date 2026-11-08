//
//  TodoListView.swift
//  example-app
//

import SwiftUI

struct TodoListView: View {
    @Bindable var model: TodoListModel

    var body: some View {
        content
            .safeAreaInset(edge: .bottom) {
                inputBar
            }
    }

    @ViewBuilder
    private var content: some View {
        if model.isEmpty {
            ContentUnavailableView(
                "Sin tareas",
                systemImage: "checklist",
                description: Text("Agrega tu primera tarea con el campo de abajo.")
            )
            .accessibilityIdentifier("emptyState")
        } else {
            List {
                ForEach(Array(model.items.enumerated()), id: \.element.id) { index, item in
                    row(for: item, at: index)
                }
            }
        }
    }

    private func row(for item: TodoItem, at index: Int) -> some View {
        HStack {
            Button {
                model.toggle(id: item.id)
            } label: {
                Image(systemName: item.symbolName)
                    .imageScale(.large)
                    .foregroundStyle(item.isCompleted ? Color.accentColor : Color.secondary)
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("toggleTask_\(index)")
            .accessibilityLabel(item.title)
            .accessibilityValue(item.accessibilityStateValue)

            Text(item.title)
                .strikethrough(item.isCompleted)
                .foregroundStyle(item.isCompleted ? .secondary : .primary)
                .accessibilityIdentifier("taskTitle_\(index)")
        }
        .swipeActions(edge: .trailing) {
            Button("Eliminar", role: .destructive) {
                model.remove(atOffsets: [index])
            }
        }
    }

    private var inputBar: some View {
        HStack {
            TextField("Nueva tarea", text: $model.draftTitle)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .onSubmit { model.addDraft() }
                .accessibilityIdentifier("newTaskField")

            Button("Agregar") {
                model.addDraft()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!model.canAddDraft)
            .accessibilityIdentifier("addTaskButton")
        }
        .padding()
        .background(.bar)
    }
}

#Preview("Vacía") {
    NavigationStack {
        TodoListView(model: TodoListModel())
            .navigationTitle("Tareas")
    }
}

#Preview("Con tareas") {
    NavigationStack {
        TodoListView(model: TodoListModel(items: [
            TodoItem(title: "Comprar leche"),
            TodoItem(title: "Pan", isCompleted: true)
        ]))
        .navigationTitle("Tareas")
    }
}

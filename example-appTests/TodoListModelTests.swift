//
//  TodoListModelTests.swift
//  example-appTests
//

import Foundation
import Testing
@testable import example_app

@MainActor
struct TodoListModelTests {

    @Test func newModelIsEmpty() {
        let model = TodoListModel()
        #expect(model.items.isEmpty)
        #expect(model.isEmpty)
    }

    @Test func addAppendsIncompleteTask() {
        let model = TodoListModel()
        #expect(model.add(title: "Comprar leche"))
        #expect(model.items.count == 1)
        #expect(model.items[0].title == "Comprar leche")
        #expect(!model.items[0].isCompleted)
        #expect(!model.isEmpty)
    }

    @Test(arguments: ["", "   ", "\n\t "])
    func addRejectsBlankTitles(title: String) {
        let empty = TodoListModel()
        #expect(!empty.add(title: title))
        #expect(empty.items.isEmpty)

        let withOne = TodoListModel(items: [TodoItem(title: "A")])
        #expect(!withOne.add(title: title))
        #expect(withOne.items.count == 1)
    }

    @Test func addTrimsTitle() {
        let model = TodoListModel()
        model.add(title: "  Pan  ")
        #expect(model.items[0].title == "Pan")
    }

    @Test func addPreservesInsertionOrder() {
        let model = TodoListModel()
        model.add(title: "A")
        model.add(title: "B")
        model.add(title: "C")
        #expect(model.items.map(\.title) == ["A", "B", "C"])
    }

    @Test func toggleFlipsCompletion() throws {
        let model = TodoListModel()
        model.add(title: "A")
        let id = try #require(model.items.first?.id)
        model.toggle(id: id)
        #expect(model.items[0].isCompleted)
        model.toggle(id: id)
        #expect(!model.items[0].isCompleted)
    }

    @Test func toggleUnknownIdDoesNothing() {
        let model = TodoListModel()
        model.add(title: "A")
        let before = model.items
        model.toggle(id: UUID())
        #expect(model.items == before)
    }

    @Test func removeSecondKeepsFirstAndThird() {
        let model = TodoListModel()
        model.add(title: "A")
        model.add(title: "B")
        model.add(title: "C")
        let firstId = model.items[0].id
        let thirdId = model.items[2].id

        model.remove(atOffsets: [1])

        #expect(model.items.count == 2)
        #expect(model.items.map(\.title) == ["A", "C"])
        #expect(model.items.map(\.id) == [firstId, thirdId])
    }

    @Test func addDraftClearsDraftOnSuccess() {
        let model = TodoListModel(draftTitle: "Leche")
        model.addDraft()
        #expect(model.items.map(\.title) == ["Leche"])
        #expect(model.draftTitle.isEmpty)
    }

    @Test func addDraftKeepsDraftWhenBlank() {
        let model = TodoListModel(draftTitle: "   ")
        model.addDraft()
        #expect(model.items.isEmpty)
        #expect(model.draftTitle == "   ")
    }

    @Test func canAddDraftReflectsTrimmedDraft() {
        let model = TodoListModel()
        #expect(!model.canAddDraft)
        model.draftTitle = "  "
        #expect(!model.canAddDraft)
        model.draftTitle = " x "
        #expect(model.canAddDraft)
    }

    @Test func itemPresentationReflectsCompletion() throws {
        let model = TodoListModel()
        model.add(title: "A")
        #expect(model.items[0].symbolName == "circle")
        #expect(model.items[0].accessibilityStateValue == "pendiente")

        let id = try #require(model.items.first?.id)
        model.toggle(id: id)
        #expect(model.items[0].symbolName == "checkmark.circle.fill")
        #expect(model.items[0].accessibilityStateValue == "completada")
    }
    // MARK: - Casos borde (QA)

    @Test func addPreservesInnerWhitespaceAndAllowsDuplicates() {
        let model = TodoListModel()
        #expect(model.add(title: "\n Comprar  leche \t"))
        #expect(model.add(title: "Comprar  leche"))
        #expect(model.items.map(\.title) == ["Comprar  leche", "Comprar  leche"])
        #expect(model.items[0].id != model.items[1].id)
    }

    @Test func toggleOnlyAffectsTargetTask() throws {
        let model = TodoListModel()
        model.add(title: "A")
        model.add(title: "B")
        model.add(title: "C")
        model.toggle(id: model.items[1].id)
        #expect(model.items.map(\.isCompleted) == [false, true, false])
        #expect(model.items.map(\.title) == ["A", "B", "C"])
    }

    @Test func removeMultipleOffsetsKeepsOrder() {
        let model = TodoListModel()
        ["A", "B", "C", "D"].forEach { model.add(title: $0) }
        model.remove(atOffsets: IndexSet([0, 2]))
        #expect(model.items.map(\.title) == ["B", "D"])
    }

    @Test func removeOutOfRangeOrEmptyOffsetsDoesNothing() {
        let model = TodoListModel()
        model.add(title: "A")
        model.remove(atOffsets: IndexSet([5]))
        model.remove(atOffsets: IndexSet())
        #expect(model.items.map(\.title) == ["A"])
    }

    @Test func removeLastTaskLeavesModelEmpty() {
        let model = TodoListModel()
        model.add(title: "A")
        model.remove(atOffsets: [0])
        #expect(model.isEmpty)
    }
}

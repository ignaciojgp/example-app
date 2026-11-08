//
//  TodoListUITests.swift
//  example-appUITests
//

import XCTest

final class TodoListUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    /// Toca el campo y espera a que tenga el foco del teclado antes de escribir (evita fallos de typeText bajo carga).
    @MainActor
    private func focusField(_ field: XCUIElement) {
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        if !waitUntil(NSPredicate(format: "hasKeyboardFocus == true"), on: field, timeout: 10) {
            field.tap()
            XCTAssertTrue(waitUntil(NSPredicate(format: "hasKeyboardFocus == true"), on: field, timeout: 10))
        }
    }

    @MainActor
    private func addTask(_ title: String, in app: XCUIApplication) {
        let field = app.textFields["newTaskField"]
        focusField(field)
        field.typeText(title)
        let addButton = app.buttons["addTaskButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        XCTAssertTrue(app.staticTexts[title].waitForExistence(timeout: 5))
    }

    @MainActor
    private func waitUntil(_ predicate: NSPredicate, on element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    @MainActor
    func testLaunchShowsEmptyState() throws {
        let app = launchApp()
        XCTAssertTrue(app.descendants(matching: .any)["emptyState"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Tareas"].exists)
        XCTAssertFalse(app.staticTexts["Hello, world!"].exists)
    }

    @MainActor
    func testAddTaskShowsRowAndClearsField() throws {
        let app = launchApp()
        addTask("Comprar leche", in: app)

        let field = app.textFields["newTaskField"]
        let value = field.value as? String ?? ""
        XCTAssertTrue(value.isEmpty || value == field.placeholderValue, "Valor inesperado del campo: \(value)")
        XCTAssertTrue(waitUntil(NSPredicate(format: "exists == false"), on: app.descendants(matching: .any)["emptyState"]))
    }

    @MainActor
    func testAddButtonDisabledWhenFieldBlank() throws {
        let app = launchApp()
        let addButton = app.buttons["addTaskButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        XCTAssertFalse(addButton.isEnabled)

        let field = app.textFields["newTaskField"]
        focusField(field)
        field.typeText("   ")
        XCTAssertFalse(addButton.isEnabled)

        field.typeText("a")
        XCTAssertTrue(waitUntil(NSPredicate(format: "isEnabled == true"), on: addButton))
    }

    @MainActor
    func testToggleMarksTaskCompleted() throws {
        let app = launchApp()
        addTask("Tarea uno", in: app)

        let toggle = app.buttons["toggleTask_0"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertEqual(toggle.value as? String, "pendiente")
        toggle.tap()
        XCTAssertTrue(waitUntil(NSPredicate(format: "value == %@", "completada"), on: toggle))
    }

    @MainActor
    func testSwipeDeleteRemovesRow() throws {
        let app = launchApp()
        addTask("Borrar me", in: app)

        let title = app.staticTexts["Borrar me"]
        title.swipeLeft()
        let deleteButton = app.buttons["Eliminar"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()

        XCTAssertTrue(waitUntil(NSPredicate(format: "exists == false"), on: title))
        XCTAssertTrue(app.descendants(matching: .any)["emptyState"].waitForExistence(timeout: 5))
    }
    /// QA: con tres filas, eliminar la del medio deja la primera y la tercera (el cierre usa el índice).
    @MainActor
    func testSwipeDeleteMiddleRowKeepsOthers() throws {
        let app = launchApp()
        addTask("Uno", in: app)
        addTask("Dos", in: app)
        addTask("Tres", in: app)

        let middle = app.staticTexts["Dos"]
        let middleCell = app.cells.containing(.staticText, identifier: "Dos").firstMatch
        let swipeTarget = middleCell.exists ? middleCell : middle
        swipeTarget.swipeLeft()
        let deleteButton = app.buttons["Eliminar"]
        if !deleteButton.waitForExistence(timeout: 5) {
            swipeTarget.swipeLeft()
        }
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()

        XCTAssertTrue(waitUntil(NSPredicate(format: "exists == false"), on: middle))
        XCTAssertTrue(app.staticTexts["Uno"].exists)
        XCTAssertTrue(app.staticTexts["Tres"].exists)
        XCTAssertEqual(app.staticTexts["taskTitle_0"].label, "Uno")
        XCTAssertEqual(app.staticTexts["taskTitle_1"].label, "Tres")
    }
}

import XCTest

final class BrainRushUITests: XCTestCase {
    func testScoresTheInkColorNotTheWord() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["開始"].waitForExistence(timeout: 5))
        app.buttons["開始"].tap()
        let prompt = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'stroop-answer-'")
        ).firstMatch
        XCTAssertTrue(prompt.waitForExistence(timeout: 5))
        let answer = prompt.identifier.replacingOccurrences(of: "stroop-answer-", with: "")
        XCTAssertTrue(app.staticTexts["得点 0"].exists)

        app.buttons["stroop-choice-\(answer)"].tap()
        XCTAssertTrue(app.staticTexts["得点 10"].waitForExistence(timeout: 2))
    }
}

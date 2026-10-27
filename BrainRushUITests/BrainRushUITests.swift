import XCTest

final class BrainRushUITests: XCTestCase {
    private func waitUntilChoicesUnlock(_ app: XCUIApplication) {
        let choice = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'stroop-choice-'")).element(boundBy: 0)
        let unlocked = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in choice.exists && choice.isEnabled },
            object: nil
        )
        XCTAssertEqual(XCTWaiter.wait(for: [unlocked], timeout: 3), .completed)
    }

    private func openHomeMenu(_ app: XCUIApplication) {
        let cat = app.buttons["home-cat"]
        XCTAssertTrue(cat.waitForExistence(timeout: 5))
        cat.tap()
        let accept = app.buttons["home-accept"]
        XCTAssertTrue(accept.waitForExistence(timeout: 6))
        accept.tap()
        XCTAssertTrue(app.buttons["stroop-start"].waitForExistence(timeout: 5))
    }

    private func pickLanguage(_ app: XCUIApplication, _ id: String) {
        let labels = [
            "japanese": "日本語",
            "chinese": "简体",
            "english": "English",
            "burmese": "မြန်မာ",
        ]
        app.buttons["stroop-settings"].tap()
        let name = labels[id] ?? id
        let item = app.buttons[name]
        XCTAssertTrue(item.waitForExistence(timeout: 2))
        item.tap()
    }

    private func startQuiz(_ app: XCUIApplication) {
        openHomeMenu(app)
        app.buttons["stroop-start"].tap()
        let go = app.buttons["stroop-name-go"]
        XCTAssertTrue(go.waitForExistence(timeout: 5))
        go.tap()
    }

    func testLanguageSwitchPreservesQuestionAndMistakeReview() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "chinese"]
        app.launch()
        startQuiz(app)
        let prompt = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'stroop-answer-'" )).firstMatch
        XCTAssertTrue(prompt.waitForExistence(timeout: 5))
        let promptID = prompt.identifier
        let chineseRule = prompt.label
        let choices = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'stroop-choice-'"))
        let choiceIDs = choices.allElementsBoundByIndex.map(\.identifier)
        pickLanguage(app, "english")
        XCTAssertTrue(app.descendants(matching: .any)[promptID].exists)
        XCTAssertNotEqual(prompt.label, chineseRule)
        XCTAssertEqual(choices.allElementsBoundByIndex.map(\.identifier), choiceIDs)
        XCTAssertTrue(app.staticTexts["Score 0"].exists)

        let answer = String(promptID.dropFirst("stroop-answer-".count))
        let wrongID = choiceIDs.first { $0 != "stroop-choice-\(answer)" }!
        app.buttons[wrongID].tap()
        let next = app.buttons["stroop-review-next"]
        XCTAssertTrue(next.waitForExistence(timeout: 3))
        let timer = app.descendants(matching: .any)["stroop-timer"].label
        for language in ["japanese", "chinese", "burmese", "english"] {
            pickLanguage(app, language)
            XCTAssertTrue(app.descendants(matching: .any)[promptID].exists)
            XCTAssertFalse(app.buttons[wrongID].isEnabled)
            XCTAssertEqual(choices.allElementsBoundByIndex.map(\.identifier), choiceIDs)
            XCTAssertTrue(next.exists)
        }
        XCTAssertEqual(app.descendants(matching: .any)["stroop-timer"].label, timer)
        XCTAssertTrue(app.staticTexts["Correct answer"].exists)
        XCTAssertTrue(app.staticTexts["Your choice"].exists)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Language switch during review"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        next.tap()
        XCTAssertFalse(next.exists)
        waitUntilChoicesUnlock(app)
    }

    func testScoresTheInkColorNotTheWord() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "japanese"]
        app.launch()

        openHomeMenu(app)

        XCTAssertTrue(app.buttons["開始"].waitForExistence(timeout: 5))
        app.buttons["開始"].tap()
        XCTAssertTrue(app.buttons["stroop-name-go"].waitForExistence(timeout: 5))
        app.buttons["stroop-name-go"].tap()
        let prompt = app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'stroop-answer-'")
        ).firstMatch
        XCTAssertTrue(prompt.waitForExistence(timeout: 5))
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Cat quiz — iPhone layout"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        let answer = prompt.identifier.replacingOccurrences(of: "stroop-answer-", with: "")
        XCTAssertTrue(app.staticTexts["得点 0"].exists)

        app.buttons["stroop-choice-\(answer)"].tap()
        XCTAssertTrue(app.staticTexts["得点 10"].waitForExistence(timeout: 2))
    }

    func testWrongAnswerStaysUntilAcknowledgedAndFinalHeartStillExplains() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "chinese"]
        app.launch()
        startQuiz(app)

        for miss in 1...3 {
            let prompt = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'stroop-answer-'" )).firstMatch
            XCTAssertTrue(prompt.waitForExistence(timeout: 5))
            let promptID = prompt.identifier
            let answer = String(promptID.dropFirst("stroop-answer-".count))
            let choices = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'stroop-choice-'"))
            let wrong = choices.allElementsBoundByIndex.first { $0.identifier != "stroop-choice-\(answer)" }!
            wrong.tap()

            let next = app.buttons["stroop-review-next"]
            XCTAssertTrue(next.waitForExistence(timeout: 3))
            guard next.exists else { return }
            let timer = app.descendants(matching: .any)["stroop-timer"]
            let frozenTimer = timer.label
            Thread.sleep(forTimeInterval: 1.2)
            XCTAssertTrue(app.descendants(matching: .any)[promptID].exists)
            XCTAssertEqual(timer.label, frozenTimer)
            XCTAssertFalse(wrong.isEnabled)
            XCTAssertTrue(app.staticTexts["你的选择"].exists)
            XCTAssertTrue(app.staticTexts["正确答案"].exists)
            XCTAssertFalse(app.buttons["stroop-result-back"].exists)
            if miss == 1 {
                let screenshot = XCTAttachment(screenshot: app.screenshot())
                screenshot.name = "Wrong answer explanation"
                screenshot.lifetime = .keepAlways
                add(screenshot)
            }
            if !next.isHittable { app.swipeUp() }
            next.tap()
        }
        XCTAssertFalse(app.buttons["stroop-result-back"].exists)
        waitUntilChoicesUnlock(app)
    }

    func testTimeoutExplainsWithoutInventingASelectedAnswer() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "chinese"]
        app.launch()
        startQuiz(app)
        XCTAssertTrue(app.buttons["stroop-review-next"].waitForExistence(timeout: 35))
        XCTAssertTrue(app.staticTexts["时间到了，看看这一题"].exists)
        XCTAssertTrue(app.staticTexts["正确答案"].exists)
        XCTAssertFalse(app.staticTexts["你的选择"].exists)
    }
}

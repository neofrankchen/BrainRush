import XCTest

final class BrainRushUITests: XCTestCase {
    func testLanguageSwitchPreservesQuestionAndMistakeReview() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "chinese"]
        app.launch()
        app.buttons["stroop-start"].tap()
        let prompt = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'stroop-answer-'" )).firstMatch
        XCTAssertTrue(prompt.waitForExistence(timeout: 5))
        let promptID = prompt.identifier
        let chineseRule = prompt.label
        let choices = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'stroop-choice-'"))
        let choiceIDs = choices.allElementsBoundByIndex.map(\.identifier)
        let english = app.buttons["language-english"]
        XCTAssertTrue(english.waitForExistence(timeout: 2))
        guard english.exists else { return }
        english.tap()
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
            app.buttons["language-\(language)"].tap()
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
        XCTAssertTrue(choices.element(boundBy: 0).isEnabled)
    }

    func testScoresTheInkColorNotTheWord() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "japanese"]
        app.launch()

        XCTAssertTrue(app.buttons["開始"].waitForExistence(timeout: 5))
        app.buttons["開始"].tap()
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
        app.buttons["stroop-start"].tap()

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
        XCTAssertTrue(app.buttons["stroop-result-back"].waitForExistence(timeout: 5))
    }

    func testTimeoutExplainsWithoutInventingASelectedAnswer() {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "chinese"]
        app.launch()
        app.buttons["stroop-start"].tap()
        XCTAssertTrue(app.buttons["stroop-review-next"].waitForExistence(timeout: 14))
        XCTAssertTrue(app.staticTexts["时间到了，看看这一题"].exists)
        XCTAssertTrue(app.staticTexts["正确答案"].exists)
        XCTAssertFalse(app.staticTexts["你的选择"].exists)
    }
}

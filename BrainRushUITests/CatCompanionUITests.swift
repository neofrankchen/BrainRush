import XCTest

final class CatCompanionUITests: XCTestCase {
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "chinese"]
        app.launch()
        return app
    }

    private func openMenu(_ app: XCUIApplication) {
        let cat = app.buttons["home-cat"]
        XCTAssertTrue(cat.waitForExistence(timeout: 5))
        cat.tap()
        let accept = app.buttons["home-accept"]
        XCTAssertTrue(accept.waitForExistence(timeout: 6))
        accept.tap()
        XCTAssertTrue(app.buttons["stroop-start"].waitForExistence(timeout: 4))
    }

    private func waitForReaction(_ cat: XCUIElement, _ reaction: String) -> Bool {
        let deadline = Date().addingTimeInterval(3)
        repeat {
            if cat.exists, cat.value as? String == reaction { return true }
            Thread.sleep(forTimeInterval: 0.05)
        } while Date() < deadline
        XCTFail("Expected \(reaction), got \(String(describing: cat.value))")
        return false
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testAwakeCatRespondsToPettingAndCanRoll() {
        let app = launch()
        openMenu(app)
        let cat = app.buttons["home-cat"]
        cat.tap()
        guard waitForReaction(cat, "正在享受抚摸") else { return }
        capture("Living cat - petting")
        Thread.sleep(forTimeInterval: 0.6)
        cat.tap()
        guard waitForReaction(cat, "正在蹭手") else { return }
        Thread.sleep(forTimeInterval: 0.6)
        cat.tap()
        guard waitForReaction(cat, "正在翻身") else { return }
        Thread.sleep(forTimeInterval: 0.7)
        capture("Living cat - rolling")
        XCTAssertTrue(app.buttons["stroop-start"].isHittable)
    }

    func testPettingDuringQuizDoesNotAnswerAndCorrectAnswerCelebrates() {
        let app = launch()
        openMenu(app)
        app.buttons["stroop-start"].tap()
        app.buttons["stroop-name-go"].tap()
        let cat = app.buttons["stroop-play-cat"]
        guard cat.waitForExistence(timeout: 5) else {
            XCTFail("The question cat must remain interactive")
            return
        }
        let prompt = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH 'stroop-answer-'" )).firstMatch
        XCTAssertTrue(prompt.waitForExistence(timeout: 4))
        let promptID = prompt.identifier
        cat.tap()
        guard waitForReaction(cat, "正在享受抚摸") else { return }
        XCTAssertTrue(app.staticTexts["得分 0"].exists)
        XCTAssertTrue(app.descendants(matching: .any)[promptID].exists)
        let answer = String(promptID.dropFirst("stroop-answer-".count))
        app.buttons["stroop-choice-\(answer)"].tap()
        XCTAssertTrue(waitForReaction(cat, "正在庆祝"))
        XCTAssertTrue(app.staticTexts["得分 10"].exists)
        capture("Living cat - correct answer")
    }

    func testIdleCatCanBeAwakenedAndStrokedWithoutLosingTheMenu() {
        let app = launch()
        let cat = app.buttons["home-cat"]
        XCTAssertTrue(cat.waitForExistence(timeout: 5))
        // Deliberate observation windows: the recording shows breathing and multiple blinks.
        Thread.sleep(forTimeInterval: 10)
        XCTAssertEqual(cat.value as? String, "睡觉中")
        capture("Living cat - breathing at rest")
        openMenu(app)
        Thread.sleep(forTimeInterval: 1.2)
        capture("Living cat - awake idle")
        let start = cat.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.25))
        let end = cat.coordinate(withNormalizedOffset: CGVector(dx: 0.65, dy: 0.4))
        start.press(forDuration: 0.1, thenDragTo: end)
        XCTAssertTrue(waitForReaction(cat, "正在蹭手"))
        XCTAssertTrue(app.buttons["stroop-start"].isHittable)
        capture("Living cat - stroked")
    }
}

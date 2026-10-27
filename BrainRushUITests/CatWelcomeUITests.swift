import XCTest

final class CatWelcomeUITests: XCTestCase {
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-appLanguage", "chinese"]
        app.launch()
        return app
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        // Capture settled frames, including the full screen during device rotation.
        Thread.sleep(forTimeInterval: 0.45)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @discardableResult
    private func waitForCatState(_ cat: XCUIElement, _ state: String, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if cat.exists, cat.value as? String == state { return true }
            Thread.sleep(forTimeInterval: 0.05)
        } while Date() < deadline
        XCTFail("Expected cat state: \(state), actual: \(String(describing: cat.value))")
        return false
    }

    private func captureMotion(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testDeclineTurnsAwayBeforeWalkingAndRecallTurnsBackToPlayer() {
        let app = launch()
        let cat = app.buttons["home-cat"]
        XCTAssertTrue(cat.waitForExistence(timeout: 5))
        cat.tap()
        let decline = app.buttons["home-decline"]
        XCTAssertTrue(decline.waitForExistence(timeout: 6))
        decline.tap()

        guard waitForCatState(cat, "正在转身", timeout: 4) else { return }
        captureMotion("07 Turning away")
        guard waitForCatState(cat, "正在回软垫", timeout: 3) else { return }
        captureMotion("08 Walking away toward cushion")
        cat.tap()
        XCTAssertTrue(waitForCatState(cat, "正在转过来", timeout: 2))
        XCTAssertTrue(decline.waitForExistence(timeout: 6))

        decline.tap()
        guard waitForCatState(cat, "正在转身", timeout: 4) else { return }
        cat.tap()
        XCTAssertTrue(decline.waitForExistence(timeout: 6))
        // A cancelled return must not put the newly recalled cat back to sleep.
        Thread.sleep(forTimeInterval: 2)
        XCTAssertTrue(app.buttons["home-accept"].exists)
        XCTAssertFalse(app.buttons["stroop-start"].exists)
    }

    func testLandscapeReturnFacesCushionAndSettlesToSleep() {
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        let app = launch()
        let cat = app.buttons["home-cat"]
        XCTAssertTrue(cat.waitForExistence(timeout: 5))
        cat.tap()
        let decline = app.buttons["home-decline"]
        XCTAssertTrue(decline.waitForExistence(timeout: 6))
        decline.tap()
        guard waitForCatState(cat, "正在回软垫", timeout: 5) else { return }
        captureMotion("09 Landscape walking toward cushion")
        XCTAssertTrue(waitForCatState(cat, "正在躺下", timeout: 4))
        XCTAssertTrue(waitForCatState(cat, "睡觉中", timeout: 2))
    }

    func testSleepingCatRequiresInvitationBeforeShowingMenu() {
        let app = launch()
        let cat = app.buttons["home-cat"]
        XCTAssertTrue(cat.waitForExistence(timeout: 5))
        guard cat.exists else { return }
        XCTAssertFalse(app.buttons["stroop-start"].exists)
        XCTAssertFalse(app.buttons["stroop-settings"].exists)
        XCTAssertFalse(app.buttons["home-accept"].exists)
        capture(app, "01 Sleeping cat")

        cat.tap()
        let accept = app.buttons["home-accept"]
        XCTAssertTrue(accept.waitForExistence(timeout: 6))
        XCTAssertTrue(app.buttons["home-decline"].exists)
        XCTAssertFalse(app.buttons["stroop-start"].exists)
        capture(app, "02 Invitation")
        accept.tap()
        let start = app.buttons["stroop-start"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["stroop-settings"].exists)
        capture(app, "03 Welcome menu")

        start.tap()
        XCTAssertTrue(app.buttons["stroop-name-go"].waitForExistence(timeout: 5))
        app.buttons["stroop-back"].tap()
        XCTAssertTrue(start.waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["home-accept"].exists)
    }

    func testDeclineReturnsToSleepAndReturnCanBeInterrupted() {
        let app = launch()
        let cat = app.buttons["home-cat"]
        XCTAssertTrue(cat.waitForExistence(timeout: 5))
        guard cat.exists else { return }
        cat.tap()
        let decline = app.buttons["home-decline"]
        XCTAssertTrue(decline.waitForExistence(timeout: 6))
        decline.tap()
        XCTAssertFalse(app.buttons["stroop-start"].exists)
        Thread.sleep(forTimeInterval: 1.1)
        let farewell = app.staticTexts["home-cat-speech"]
        XCTAssertTrue(farewell.exists)
        if farewell.exists { XCTAssertEqual(farewell.label, "うん、遊びたくなったら呼んでね。") }
        let asleep = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "睡觉中"), object: cat)
        XCTAssertEqual(XCTWaiter.wait(for: [asleep], timeout: 7), .completed)
        capture(app, "04 Back to sleep")

        cat.tap()
        XCTAssertTrue(decline.waitForExistence(timeout: 6))
        decline.tap()
        cat.tap()
        let accept = app.buttons["home-accept"]
        XCTAssertTrue(accept.waitForExistence(timeout: 6))
        accept.tap()
        XCTAssertTrue(app.buttons["stroop-start"].waitForExistence(timeout: 5))
    }

    func testLandscapeMenuShortcutsAndLanguageRemainUsable() {
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        let app = launch()
        let cat = app.buttons["home-cat"]
        XCTAssertTrue(cat.waitForExistence(timeout: 5))
        guard cat.exists else { return }
        cat.tap()
        let accept = app.buttons["home-accept"]
        XCTAssertTrue(accept.waitForExistence(timeout: 6))
        XCTAssertTrue(accept.isHittable)
        capture(app, "05 Landscape invitation")
        accept.tap()
        XCTAssertTrue(app.buttons["stroop-start"].waitForExistence(timeout: 5))
        for identifier in ["stroop-start", "stroop-practice", "stroop-ranking", "stroop-guide"] {
            XCTAssertTrue(app.buttons[identifier].isHittable, identifier)
        }
        capture(app, "06 Landscape menu")

        app.buttons["stroop-guide"].tap()
        XCTAssertTrue(app.buttons["关闭"].waitForExistence(timeout: 3))
        app.buttons["关闭"].tap()
        app.buttons["stroop-ranking"].tap()
        XCTAssertTrue(app.buttons["关闭"].waitForExistence(timeout: 3))
        app.buttons["关闭"].tap()

        app.buttons["stroop-settings"].tap()
        app.buttons["English"].tap()
        XCTAssertEqual(app.buttons["stroop-start"].label, "Start")
        app.buttons["stroop-practice"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["stroop-test-timer"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["stroop-name-go"].exists)
        app.buttons["stroop-back"].tap()
        XCTAssertTrue(app.buttons["stroop-start"].waitForExistence(timeout: 3))
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(app.buttons["stroop-start"].waitForExistence(timeout: 5))
    }
}

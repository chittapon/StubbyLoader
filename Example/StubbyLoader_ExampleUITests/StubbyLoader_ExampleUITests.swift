//
//  StubbyLoader_ExampleUITests.swift
//  StubbyLoader_ExampleUITests
//
//  Created by Chittapon Thongchim on 31/5/2567 BE.
//  Copyright © 2567 BE CocoaPods. All rights reserved.
//

import XCTest

final class StubbyLoader_ExampleUITests: XCTestCase {

    let bundle = Bundle(for: StubbyLoader_ExampleUITests.self)
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLocalFileViewController() throws {
        let app = XCUIApplication()
        try setup(app: app)
        app.launch()
        app.buttons.element(boundBy: 0).tap()
        let textView = app.textViews.firstMatch
        let text = textView.value as? String
        XCTAssert(text == "UITesting LocalFileViewController")
    }

    func testCustomEnvironmentViewController() throws {
        let app = XCUIApplication()
        try setup(app: app)
        app.launch()
        app.buttons.element(boundBy: 3).tap()
        
        let response = bundle.url(forAuxiliaryExecutable: "comments.json")
        let responseText = try String(contentsOf: response!)
        let textView = app.textViews.firstMatch
        let text = textView.value as? String
        XCTAssert(text == responseText)
    }
    
    func setup(app: XCUIApplication) throws {
        var env: [String: String] = [:]
        env["STUBBY_PATH"] = bundle.bundlePath
        let port = randomPort()
        env["STUBBY_PORT"] = "\(port)"
        env["TEST_PORT"] = "\(port)"
        app.launchEnvironment = env
    }
    
    func randomPort() -> Int {
        return Int.random(in: 3000..<9999)
    }
}

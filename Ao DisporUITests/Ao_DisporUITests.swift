//
//  Ao_DisporUITests.swift
//  Ao DisporUITests
//
//  Created by André Lamelas on 15/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import XCTest

class Ao_DisporUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        snapshot("0-Ecrã Inicial")
        let deQuemPrecisaSearchField = app.searchFields["De quem precisa?"]
        deQuemPrecisaSearchField.tap()
        deQuemPrecisaSearchField.typeText("Ricardo José")
        snapshot("1-A Pesquisar")
        app.typeText("\r")
    }
    
}

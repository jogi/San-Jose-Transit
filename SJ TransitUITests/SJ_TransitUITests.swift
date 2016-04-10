//
//  SJ_TransitUITests.swift
//  SJ TransitUITests
//
//  Created by Vashishtha Jogi on 4/5/16.
//  Copyright © 2016 Vashishtha Jogi. All rights reserved.
//

import XCTest

class SJ_TransitUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSnapshots() {
        
        let app = XCUIApplication()
        
        let sjTransitMapviewNavigationBar = app.navigationBars["SJ_Transit.MapView"]
        sjTransitMapviewNavigationBar.buttons["location"].tap()
        sjTransitMapviewNavigationBar.searchFields["Search by address, city, zipcode"].tap()
        
        let moreNumbersKey = app.keys["more, numbers"]
        moreNumbersKey.tap()
        moreNumbersKey.tap()
        sjTransitMapviewNavigationBar.searchFields["Search by address, city, zipcode"]
        app.typeText("95131")
        app.buttons["Search"].tap()
        
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).matchingIdentifier("Old Oakland & Mckay, 66").elementBoundByIndex(0).tap()
        
        snapshot("01Maps")
        
    }
    
}

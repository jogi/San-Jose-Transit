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
        sjTransitMapviewNavigationBar.searchFields["Search by address, city, zipcode"]
        app.typeText("San Jose")
        app.buttons["Search"].tap()
        
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).matchingIdentifier("San Fernando & 1St, 63, 81, 64, 72, 73, 65").elementBoundByIndex(0).tap()
        snapshot("01Maps")
        
        
        let tabBarsQuery = app.tabBars
        let favoritesButton = tabBarsQuery.buttons["Favorites"]
        favoritesButton.tap()
        snapshot("02Favorites")
        
        tabBarsQuery.buttons["Routes"].tap()
        
        let tablesQuery = app.tables
        let cellsQuery = tablesQuery.cells.containingType(.StaticText, identifier:"22")
        snapshot("03Routes")
        
        cellsQuery.childrenMatchingType(.StaticText).matchingIdentifier("Palo Alto - Eastridge").elementBoundByIndex(0).tap()
        snapshot("04RouteDetail")
        
        let tablesQuery2 = tablesQuery
        tablesQuery2.staticTexts["El Camino & Galvez"].tap()
        
        let moreButton = app.navigationBars["El Camino & Galvez"].buttons["more"]
        moreButton.tap()
        
        let sheetsQuery = app.sheets
        sheetsQuery.collectionViews.buttons["Change Departure Time"].tap()
        let datePickersQuery = app.datePickers
        datePickersQuery.pickerWheels.elementBoundByIndex(1).adjustToPickerWheelValue("10")
        datePickersQuery.pickerWheels.elementBoundByIndex(2).adjustToPickerWheelValue("42")
        datePickersQuery.pickerWheels.elementBoundByIndex(3).adjustToPickerWheelValue("AM")
        
        app.toolbars.buttons["Done"].tap()
        snapshot("05StopRouteTrips")
        
        tablesQuery.cells.containingType(.StaticText, identifier:"11:17 AM").staticTexts["Outbound to Eastridge"].tap()
        snapshot("06StopRouteMap")
        
        favoritesButton.tap()
        tablesQuery2.staticTexts["Santa Clara Station (0)"].tap()
        snapshot("07StopRoute")
    }
}

//
//  MonityTests.swift
//  MonityTests
//
//  Created by Niklas Kuder on 09.10.22.
//

import XCTest
@testable import Monity

final class DateTests: XCTestCase {

    func testDateExtensionStartOfMonth() throws {
        var date = Calendar.current.date(from: DateComponents(year: 2023, month: 7, day: 8))!
        var actualStartOfMonth = Calendar.current.date(from: DateComponents(year: 2023, month: 7, day: 1))!
        var startOfMonth = date.startOfThisMonth
        XCTAssertEqual(startOfMonth, actualStartOfMonth)
        
        date = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 31))!
        actualStartOfMonth = Calendar.current.date(from: DateComponents(year: 2023, month: 1, day: 1))!
        startOfMonth = date.startOfThisMonth
        XCTAssertEqual(startOfMonth, actualStartOfMonth)
        
        date = Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 1))!
        actualStartOfMonth = Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 1))!
        startOfMonth = date.startOfThisMonth
        XCTAssertEqual(startOfMonth, actualStartOfMonth)
    }
    
    func testDateExtensionEndOfMonth() throws {
        var date = Calendar.current.date(from: DateComponents(year: 2023, month: 7, day: 8))!
        var actualEndOfMonth = Calendar.current.date(from: DateComponents(year: 2023, month: 7, day: 31))!
        var endOfMonth = date.endOfThisMonth
        XCTAssertEqual(endOfMonth, actualEndOfMonth)
        
        date = Calendar.current.date(from: DateComponents(year: 2023, month: 7, day: 31))!
        actualEndOfMonth = Calendar.current.date(from: DateComponents(year: 2023, month: 7, day: 31))!
        endOfMonth = date.endOfThisMonth
        XCTAssertEqual(endOfMonth, actualEndOfMonth)
        
        date = Calendar.current.date(from: DateComponents(year: 2023, month: 4, day: 1))!
        actualEndOfMonth = Calendar.current.date(from: DateComponents(year: 2023, month: 4, day: 30))!
        endOfMonth = date.endOfThisMonth
        XCTAssertEqual(endOfMonth, actualEndOfMonth)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

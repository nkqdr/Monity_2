//
//  CategoryRetroTest.swift
//  MonityTests
//
//  Created by Niklas Kuder on 30.06.24.
//

import XCTest
@testable import Monity

final class CategoryRetroTest: XCTestCase {
    let store = PersistenceController.preview.container
    var transactions: [Transaction] = []
    var calendar: Calendar = Calendar.current
    var todayTestComponents = DateComponents(year: 2024, month: 6, day: 16)
    var today: Date = Date()
    var category1: TransactionCategory?
    var category2: TransactionCategory?


    override func setUp() {
        self.today = self.calendar.date(from: self.todayTestComponents)!
        let viewContext = self.store.newBackgroundContext()
        
        viewContext.performAndWait {
            self.category1 = TransactionCategory(context: viewContext)
            self.category1!.name = "TestCategory"
            
            self.category2 = TransactionCategory(context: viewContext)
            self.category2!.name = "SecondCategory"
            
            let t1 = Transaction(context: viewContext)
            t1.amount = 100
            t1.isExpense = true
            t1.date = self.calendar.date(byAdding: DateComponents(day: -1), to: today)
            t1.category = self.category1
            
            let t2 = Transaction(context: viewContext)
            t2.amount = 2.51
            t2.isExpense = true
            t2.date = self.calendar.date(byAdding: DateComponents(day: -10), to: today)
            t2.category = self.category2
            
            let t3 = Transaction(context: viewContext)
            t3.amount = 1000
            t3.isExpense = false
            t3.date = self.calendar.date(byAdding: DateComponents(day: -5), to: today)
            t3.category = self.category1

            
            try? viewContext.save()
        }
    }

    func testPropertiesGetAssignedCorrectly() throws {
        let sut = CategoryRetroDataPoint(
            category: self.category1!,
            timeframe: .pastYear,
            isForExpenses: true,
            now: self.today
        )
        XCTAssertEqual(sut.category, self.category1)
        XCTAssertEqual(sut.total, 100)
        XCTAssertEqual(sut.average, 100)
        XCTAssertEqual(sut.numTransactions, 1)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

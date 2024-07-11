//
//  CategoryRetroTest.swift
//  MonityTests
//
//  Created by Niklas Kuder on 30.06.24.
//

import XCTest
@testable import Monity

final class CategoryRetroTest: XCTestCase {
    let persistenceController = PersistenceController.preview
    var transactions: [Transaction] = []
    var calendar: Calendar = Calendar.current
    var today: Date = Date().removeTimeStamp!
    var category1: TransactionCategory?
    var category2: TransactionCategory?


    override func setUp() {
        let viewContext = self.persistenceController.managedObjectContext
        
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
    
    override func tearDown() {
        TransactionStorage(managedObjectContext: self.persistenceController.managedObjectContext).deleteAll()
    }

    func testPropertiesGetAssignedCorrectly() throws {
        let sut = CategoryRetroDataPoint(
            category: self.category1!,
            timeframe: .pastYear,
            isForExpenses: true,
            controller: self.persistenceController
        )
        XCTAssertEqual(sut.category, self.category1)
        XCTAssertEqual(sut.total, 100)
        XCTAssertEqual(sut.averagePerMonth, 100 / 12)
        XCTAssertEqual(sut.numTransactions, 1)
        
        let sut2 = CategoryRetroDataPoint(
            category: self.category1!,
            timeframe: .pastYear,
            isForExpenses: false,
            controller: self.persistenceController
        )
        XCTAssertEqual(sut2.category, self.category1)
        XCTAssertEqual(sut2.total, 1000)
        XCTAssertEqual(sut2.averagePerMonth, 1000 / 12)
        XCTAssertEqual(sut2.numTransactions, 1)
    }
    
    func testRetroDPShouldIgnoreTooOldTransactions() {
        let viewContext = self.persistenceController.managedObjectContext
        viewContext.performAndWait {
            let t1 = Transaction(context: viewContext)
            t1.category = self.category1
            t1.amount = 500
            t1.isExpense = true
            t1.date = self.calendar.date(byAdding: DateComponents(month: -1, day: -1), to: today)
            
            let t2 = Transaction(context: viewContext)
            t2.category = self.category1
            t2.amount = 700
            t2.isExpense = true
            t2.date = self.calendar.date(byAdding: DateComponents(year: -1, day: -1), to: today)
            
            try? viewContext.save()
        }
        
        let sut = CategoryRetroDataPoint(
            category: self.category1!,
            timeframe: .total,
            isForExpenses: true,
            controller: self.persistenceController
        )
        XCTAssertEqual(sut.total, 1300)
        XCTAssertEqual(sut.averagePerMonth, 1300 / 12) // The earliest transaction is 12 months back
        XCTAssertEqual(sut.numTransactions, 3)
        
        let sut2 = CategoryRetroDataPoint(
            category: self.category1!,
            timeframe: .pastYear,
            isForExpenses: true,
            controller: self.persistenceController
        )
        XCTAssertEqual(sut2.total, 600)
        XCTAssertEqual(sut2.averagePerMonth, 600 / 12)
        XCTAssertEqual(sut2.numTransactions, 2)
        
        let sut3 = CategoryRetroDataPoint(
            category: self.category1!,
            timeframe: .pastMonth,
            isForExpenses: true,
            controller: self.persistenceController
        )
        XCTAssertEqual(sut3.total, 100)
        XCTAssertEqual(sut3.averagePerMonth, 100)
        XCTAssertEqual(sut3.numTransactions, 1)
    }
    
    func testRetroDPShouldBeUpdatedForNewTransaction() {
        let sut = CategoryRetroDataPoint(
            category: self.category1!,
            timeframe: .total,
            isForExpenses: true,
            controller: self.persistenceController
        )
        XCTAssertEqual(sut.total, 100)
//        XCTAssertEqual(sut.average, 100)
        XCTAssertEqual(sut.numTransactions, 1)
        
        let viewContext = self.persistenceController.managedObjectContext
        viewContext.performAndWait {
            let t1 = Transaction(context: viewContext)
            t1.category = self.category1
            t1.amount = 500
            t1.isExpense = true
            t1.date = self.calendar.date(byAdding: DateComponents(month: -1, day: -1), to: today)
            
            try? viewContext.save()
        }
        
        XCTAssertEqual(sut.total, 600)
//        XCTAssertEqual(sut.average, 300)
        XCTAssertEqual(sut.numTransactions, 2)
    }

}

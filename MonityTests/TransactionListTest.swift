//
//  TransactionListTest.swift
//  MonityTests
//
//  Created by Niklas Kuder on 06.07.24.
//

import XCTest
@testable import Monity

final class TransactionListTest: XCTestCase {
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
            t1.text = "Something"
            
            let t2 = Transaction(context: viewContext)
            t2.amount = 2.51
            t2.isExpense = true
            t2.date = self.calendar.date(byAdding: DateComponents(month: -2), to: today)
            t2.category = self.category2
            t2.text = "Something else"
            
            let t3 = Transaction(context: viewContext)
            t3.amount = 1000
            t3.isExpense = false
            t3.date = self.calendar.date(byAdding: DateComponents(day: -3), to: today)
            t3.category = self.category1
            t3.text = "Another one"

            
            try? viewContext.save()
        }
    }
    
    func testDateGrouping() {
        let yearGroup = TransactionDateGroupedList(
            groupingGranularity: .year,
            controller: self.persistenceController
        )
        let monthGroup = TransactionDateGroupedList(
            groupingGranularity: .month,
            controller: self.persistenceController
        )
        let dayGroup = TransactionDateGroupedList(
            groupingGranularity: .day,
            controller: self.persistenceController
        )
        
        
        let e = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            XCTAssertEqual(yearGroup.groupedTransactions.count, 1)
            XCTAssertEqual(monthGroup.groupedTransactions.count, 2)
            XCTAssertEqual(dayGroup.groupedTransactions.count, 3)
            e.fulfill()
        }
        wait(for: [e], timeout: 10.0)
    }
    
    func testSearchForCategory() {
        let dayGroup = TransactionDateGroupedList(
            groupingGranularity: .day,
            controller: self.persistenceController
        )
        let e1 = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(dayGroup.groupedTransactions.count, 3)
            e1.fulfill()
        }
        wait(for: [e1], timeout: 10.0)
        
        dayGroup.searchText = "Second"
        
        let e2 = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(dayGroup.groupedTransactions.count, 1)
            e2.fulfill()
        }
        wait(for: [e2], timeout: 10.0)
    }
    
    func testSearchForText() {
        let dayGroup = TransactionDateGroupedList(
            groupingGranularity: .day,
            controller: self.persistenceController
        )
        let e1 = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(dayGroup.groupedTransactions.count, 3)
            e1.fulfill()
        }
        wait(for: [e1], timeout: 10.0)
        
        dayGroup.searchText = "Something"
        let e2 = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(dayGroup.groupedTransactions.count, 2)
            e2.fulfill()
        }
        wait(for: [e2], timeout: 10.0)
        
        dayGroup.searchText = "Another"
        let e3 = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(dayGroup.groupedTransactions.count, 1)
            e3.fulfill()
        }
        wait(for: [e3], timeout: 10.0)
    }

}

//
//  SavingsCalculationTest.swift
//  MonityTests
//
//  Created by Niklas Kuder on 23.11.23.
//

import XCTest

final class SavingsCalculationTest: XCTestCase {
    let store = PersistenceController(inMemory: true).container
    var savings: [SavingsEntry] = []
    
    override func setUp() {
        let viewContext = self.store.viewContext
        
        viewContext.performAndWait {
            let category = SavingsCategory(context: viewContext)
            category.name = "TestCategory"
            
            let category2 = SavingsCategory(context: viewContext)
            category2.name = "SecondCategory"
            
            for idx in 0..<15 {
                let entry = SavingsEntry(context: viewContext)
                entry.amount = Double(1000 / (idx+1))
                entry.date = Calendar.current.date(byAdding: DateComponents(month: idx * -1), to: Date())
                if idx % 3 == 0 {
                    entry.category = category
                } else {
                    entry.category = category2
                }
                self.savings.append(entry)
            }
            
            try? viewContext.save()
        }
    }

    func testLineChartDataStaysCorrectEvenIfSomeEntriesFromTheBeginningAreNotShown() throws {
        let fetchController = SavingsFetchController(since: Date.distantPast, managedObjectContext: store.viewContext)
        let results = fetchController.items.value
        
        let result = LineChartDataBuilder.generateSavingsLineChartData(for: self.savings, granularity: .day)
        XCTAssertEqual(result.count, 15)
        XCTAssertEqual(result.first!.value, 66)
        XCTAssertEqual(result[2].value, 147)
        XCTAssertEqual(result.last!.value, 1500)
        
        let smallResult = LineChartDataBuilder.generateSavingsLineChartData(
            for: self.savings,
            lowerBound: Calendar.current.date(byAdding: DateComponents(month: -5), to: Date())!,
            granularity: .day
        )
        XCTAssertEqual(smallResult.count, 5)
        XCTAssertEqual(smallResult.first!.value, 342)
        XCTAssertEqual(smallResult[2].value, 583)
        XCTAssertEqual(result.last!.value, 1500)

        let smallestResult = LineChartDataBuilder.generateSavingsLineChartData(
            for: self.savings,
            lowerBound: Calendar.current.date(byAdding: DateComponents(month: -1), to: Date())!,
            granularity: .day
        )
        XCTAssertEqual(smallestResult.count, 1)
        XCTAssertEqual(smallestResult.first!.value, 1500)
    }

}

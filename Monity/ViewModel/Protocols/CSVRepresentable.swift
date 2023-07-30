//
//  CSVRepresentable.swift
//  Monity
//
//  Created by Niklas Kuder on 30.10.22.
//

import Foundation
import CoreData

protocol CSVDecodable {
    associatedtype CSVDataDype
    static func decodeFromCSV(csvRow: String) -> CSVDataDype
}

protocol CSVEncodable {
    var commaSeparatedString: String { get }
}

protocol CSVRepresentable: CSVDecodable, CSVEncodable { }

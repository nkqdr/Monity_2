//
//  CSVRepresentable.swift
//  Monity
//
//  Created by Niklas Kuder on 30.10.22.
//

import Foundation
import CoreData

protocol CSVDecodable {
    associatedtype CSVDataType
    static func decodeFromCSV(csvRow: String) -> CSVDataType
}

protocol CSVEncodable {
    var commaSeparatedString: String { get }
}

protocol CSVRepresentable: CSVDecodable, CSVEncodable { }

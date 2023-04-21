//
//  SavingsEntryManager.swift
//  Monity
//
//  Created by Niklas Kuder on 08.04.23.
//

import Foundation

class SavingsEntryManager: ObservableObject {
    @Published var showSheet: Bool = false
    @Published var editor = SavingsEditor(entry: nil)
}

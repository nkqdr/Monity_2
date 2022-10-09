//
//  AddTransactionViewModel.swift
//  Monity
//
//  Created by Niklas Kuder on 09.10.22.
//

import Foundation

class AddTransactionViewModel: ObservableObject {
    @Published var isExpense: Bool = true
    @Published var selectedCategory: String = "Test"
    @Published var givenAmount: String = ""
    @Published var description: String = ""
    //@Published var tag: String = ""
    
}

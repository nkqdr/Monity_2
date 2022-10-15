//
//  SettingsSystemView.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct Settings_SystemView: View {
    @StateObject private var content = SettingsSystemViewModel()
    @State private var importSummary: ImportCSVSummary? // This is needed because an error occurs when directly using the value in the ViewModel
    @State private var showDeleteAllConfirmation: Bool = false
    
    var body: some View {
        List {
            dataSection
            importSection
//            exportSection
        }
        .sync($content.importSummary, with: $importSummary)
        .sheet(isPresented: $content.showFilePicker) {
            DocumentPicker(fileContent: $content.csvFileContent)
        }
        .sheet(item: $importSummary) { summary in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Import Summary")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                        Text(summary.resourceName)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Rows:")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(summary.rowsAmount, format: .number)
                            .fontWeight(.bold)
                            .font(.headline)
                    }
                }
                .padding()
                ScrollView {
                    ForEach(summary.rows, id: \.self) { row in
                        ImportSummaryRow(summary: summary, row: row)
                    }
                    .padding()
                }
                HStack {
                    Button("Cancel", role: .destructive) {
                        content.importSummary = nil
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                    Button("Import") {
                        content.importCSV()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
//            .presentationDetents([.medium])
        }
        .alert("Could not read this file", isPresented: $content.showInvalidFileAlert) {
            Button("Try again") {
                content.showInvalidFileAlert.toggle()
            }
        } message: {
            Text("Please make sure to use a csv file with the correct format.")
        }
        .confirmationDialog("Are you sure you want to delete all App-Data?", isPresented: $showDeleteAllConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                content.deleteAllData()
            }
        } message: {
            Text("This cannot be undone!")
        }
        .navigationTitle("System")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var dataSection: some View {
        Section(header: Text("Saved Data"), footer: Text("Manage all data you have ever saved in this app.")) {
            HStack {
                Text("Registered transactions")
                Spacer()
                Text(content.registeredTransactions, format: .number)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Registered savings entries")
                Spacer()
                Text(content.registeredSavingsEntries, format: .number)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Used storage")
                Spacer()
                Text(content.storageUsedString)
                    .foregroundColor(.secondary)
            }
            HStack {
                Spacer()
                Button("Delete all data", role: .destructive) {
                    showDeleteAllConfirmation.toggle()
                }
                .buttonStyle(.borderless)
                Spacer()
            }
        }
    }
    
    var importSection: some View {
        Section(header: Text("Import Data"), footer: Text("Read data from .csv files and import it into Monity.")) {
            HStack {
                Spacer()
                Button("Select CSV") {
                    content.showFilePicker.toggle()
                }
                .buttonStyle(.borderless)
                Spacer()
            }
        }
    }
    
    var exportSection: some View {
        Section(header: Text("Export Data"), footer: Text("Export your App-Data into .csv format and save it on your device.")) {
            HStack {
                Button("Transactions", action: content.exportTransactionsCSV)
                    .buttonStyle(.borderless)
                Spacer()
                Button("Savings", action: content.exportSavingsCSV)
                    .buttonStyle(.borderless)
            }
        }
    }
}

struct Settings_SystemView_Previews: PreviewProvider {
    static var previews: some View {
        Settings_SystemView()
    }
}

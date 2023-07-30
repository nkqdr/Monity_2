//
//  MoreSystemView.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI

struct StoredItemsTile: View {
    @State private var showDeleteConfirmation: Bool = false
    var label: LocalizedStringKey
    var amount: Int
    var deleteConfirmationLabel: LocalizedStringKey
    var deleteConfirmationMessage: LocalizedStringKey = "This cannot be undone!"
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(label)+Text(":")
            Spacer()
            Text(amount, format: .number)
                .foregroundColor(.secondary)
        }
        .contextMenu {
            Button(role: .destructive) {
                showDeleteConfirmation.toggle()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog(deleteConfirmationLabel, isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text(deleteConfirmationMessage)
        }
    }
}

struct ExportOptionSheet: View {
    @ObservedObject private var dataExporter: DataExporter = DataExporter()
    @State private var exportHasErrors: Bool = false
    @State private var exportWasSuccessful: Bool = false
    @Binding var isOpen: Bool
    
    var body: some View {
        VStack {
            Toggle(isOn: $dataExporter.exportTransactions) {
                Text("Export Transactions")
            }
            Toggle(isOn: $dataExporter.exportRecurringTransactions) {
                Text("Export Recurring Expenses")
            }
            Toggle(isOn: $dataExporter.exportSavings) {
                Text("Export Savings")
            }
            Spacer()
            HStack {
                Button("Cancel", role: .destructive) {
                    isOpen = false
                }
                .buttonStyle(.borderless)
                Spacer()
                Button("Export to CSV") {
                    let val = dataExporter.triggerExport()
                    if val {
                        exportWasSuccessful = true
                    } else {
                        exportHasErrors = true
                    }
                }
                .disabled(dataExporter.disableExportButton)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .alert("Exporting error", isPresented: $exportHasErrors) {
            Button("Try again", role: .cancel) {
                isOpen = false
            }
        } message: {
            Text("Something didn't work.")
        }
        .alert("Export successful!", isPresented: $exportWasSuccessful) {
            Button("OK", role: .cancel) {
                isOpen = false
            }
        } message: {
            Text("You can find the .csv files in your Documents directory.")
        }
    }
}

struct More_SystemView: View {
    @StateObject private var content = SettingsSystemViewModel()
    @State private var showDeleteAllConfirmation: Bool = false
    @State private var showSelectorSheet: Bool = false
    // These are needed because an error occurs when directly using the value in the ViewModel
    @State private var importSummary: ImportCSVSummary?
    @State private var exportHasErrors: Bool = false
    @State private var exportWasSuccessful: Bool = false
    
    func buildImportSummaryView(_ summary: ImportCSVSummary) -> some View {
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
    }
    
    var body: some View {
        List {
            dataSection
            importSection
            exportSection
        }
        .sync($content.importSummary, with: $importSummary)
        .sheet(isPresented: $content.showFilePicker) {
            DocumentPicker(fileContent: $content.csvFileContent)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showSelectorSheet) {
            ExportOptionSheet(isOpen: $showSelectorSheet)
                .presentationDetents([.height(220)])
        }
        .sheet(item: $importSummary) { summary in
            buildImportSummaryView(summary)
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
            StoredItemsTile(
                label: "Transactions",
                amount: content.totalTransactionCount,
                deleteConfirmationLabel: "Are you sure you want to delete all transaction data?") {
                    content.deleteTransactionData()
                }
            StoredItemsTile(
                label: "Savings entries",
                amount: content.totalSavingsCount,
                deleteConfirmationLabel: "Are you sure you want to delete all savings data?") {
                    content.deleteSavingsData()
                }
            StoredItemsTile(
                label: "Recurring expenses",
                amount: content.totalRecurringTransactionCount,
                deleteConfirmationLabel: "Are you sure you want to delete all recurring expenses data?") {
                    content.deleteRecurringTransactionData()
                }
            HStack {
                Text("Used storage:")
                    .foregroundColor(.secondary)
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
                Spacer()
                Button("Select Data") {
                    showSelectorSheet.toggle()
                }
                .buttonStyle(.borderless)
                Spacer()
            }
        }
    }
}

struct Settings_SystemView_Previews: PreviewProvider {
    static var previews: some View {
        More_SystemView()
    }
}

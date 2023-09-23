//
//  MoreSystemView.swift
//  Monity
//
//  Created by Niklas Kuder on 14.10.22.
//

import SwiftUI
import UniformTypeIdentifiers

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

struct ImportSummaryView: View {
    var summary: ImportCSVSummary
    var onImport: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Import Summary")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                    Text(summary.resourceName)
                        .font(.headline)
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
                    ImportSummaryRow(resource: summary.resource, row: row)
                }
                .padding()
            }
            HStack {
                Button("Cancel", role: .destructive) {
                    onCancel()
                }
                .buttonStyle(.borderless)
                Spacer()
                Button("Import") {
                    onImport()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

fileprivate struct CSVFile: FileDocument {
    // tell the system we support only plain text
    static var readableContentTypes = [UTType.commaSeparatedText]
    static var writableContentTypes = [UTType.commaSeparatedText]

    // by default our document is empty
    var text = ""

    // a simple initializer that creates new, empty documents
    init(initialText: String = "") {
        text = initialText
    }

    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
    
}

fileprivate struct ExportSection: View {
    @ObservedObject private var dataExporter: DataExporter = DataExporter()
    @State private var showExporter: Bool = false
    @State private var fileContents: String = ""
    @State private var fileName: String = ""
    @State private var showErrorMessage: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        Section(header: Text("Export Data"), footer: Text("Export your App-Data into .csv format and save it on your device.")) {
            Button {
                let res = dataExporter.getTransactionCSVContent()
                fileContents = res.0
                fileName = res.1
                showExporter = true
            } label: {
                Label("Transactions", systemImage: "square.and.arrow.up")
            }
            Button {
                let res = dataExporter.getRecurringTransactionsCSVContent()
                fileContents = res.0
                fileName = res.1
                showExporter = true
            } label: {
                Label("Recurring expenses", systemImage: "square.and.arrow.up")
            }
            Button {
                let res = dataExporter.getSavingsCSVContent()
                fileContents = res.0
                fileName = res.1
                showExporter = true
            } label: {
                Label("Savings", systemImage: "square.and.arrow.up")
            }
        }
        .fileExporter(isPresented: $showExporter, document: CSVFile(initialText: fileContents), contentType: .commaSeparatedText, defaultFilename: fileName) { result in
            switch (result) {
            case .success:
                return
            case .failure(let error):
                showErrorMessage = true
                errorMessage = error.localizedDescription
            }
        }
        .alert("Export failed!", isPresented: $showErrorMessage) {
            Button("OK", role: .cancel) {
               
            }
        } message: {
            Text("The export failed with this message: \(errorMessage)")
        }
    }
}

struct More_SystemView: View {
    @StateObject private var content = SettingsSystemViewModel()
    @State private var showDeleteAllConfirmation: Bool = false
    // These are needed because an error occurs when directly using the value in the ViewModel
    @State private var importSummary: ImportCSVSummary?
    
    var body: some View {
        List {
            dataSection
            importSection
            ExportSection()
        }
        .sync($content.importSummary, with: $importSummary)
        .sheet(isPresented: $content.showFilePicker) {
            DocumentPicker(fileContent: $content.csvFileContent)
                .ignoresSafeArea()
        }
        .sheet(item: $importSummary) { summary in
            ImportSummaryView(summary: summary, onImport: {
                content.importCSV()
            }, onCancel: {
                content.importSummary = nil
            })
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
            Button {
                content.showFilePicker.toggle()
            } label: {
                Label("Select CSV", systemImage: "doc")
            }
        }
    }
}

struct Settings_SystemView_Previews: PreviewProvider {
    static var previews: some View {
        More_SystemView()
    }
}

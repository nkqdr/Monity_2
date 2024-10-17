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
    @Binding var summary: ImportCSVSummary?
    
    @ViewBuilder
    var loadingScreen: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
    
    @ViewBuilder
    func SummaryView(summary: ImportCSVSummary) -> some View {
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
                    Text("Entries:")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(summary.rowsAmount, format: .number)
                        .fontWeight(.bold)
                        .font(.headline)
                }
            }
            .padding()
            GeometryReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(summary.rows) { row in
                            ImportSummaryRow(resource: summary.resource, row: row.rowContent)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: proxy.size.height - 80)
            }
        }
    }
    
    var body: some View {
        if let summary {
            SummaryView(summary: summary)
        } else {
            loadingScreen
        }
    }
}


fileprivate struct ImportCSVWizard: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var csvImporter = CSVImporter()
    @State private var selectedStructurePreview: CSVValidHeaders = CSVValidHeaders.transactionCSV
    @State private var currentlySelectedPageIndex: Int = 0
    @State private var showAvailableFormatsView: Bool = false
    
    private var tableColumns: [Substring] {
        selectedStructurePreview.rawValue.split(separator: ",")
    }
    
    @ViewBuilder
    var firstPage: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("⤵️").font(.largeTitle).padding(.bottom, 10).padding(.top, 50)
                    Text("Import CSV data")
                        .font(.title.bold())
                        .padding(.bottom, 30)
                    Text("Import data seamlessly from previous versions of Monity or any compatible app. As long as the file meets our import standards, your financial data integration is hassle-free.")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    HStack {
                        if csvImporter.isReading {
                            ProgressView()
                        } else if let summary = csvImporter.importSummary, !csvImporter.importHasError {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.green)
                            VStack(alignment: .leading) {
                                Text("File successfully read")
                                Group {
                                    Text("Type of data: ") + Text(summary.resourceName)
                                }
                                .font(.footnote).foregroundStyle(.secondary)
                            }
                            Spacer()
                        } else if csvImporter.importHasError {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.red)
                            VStack(alignment: .leading) {
                                Text("File could not be read")
                                Text("Please ensure that the selected file has the correct format.").font(.footnote).foregroundStyle(.secondary)
                            }
                            .multilineTextAlignment(.leading)
                            Spacer()
                        } else {
                            Text("Please select a .csv file").font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .padding()
                    Button {
                        csvImporter.showDocumentPicker.toggle()
                    } label: {
                        Label("Select CSV", systemImage: "doc")
                    }
                    .buttonStyle(.bordered)
                    .disabled(csvImporter.isReading)
                }
            }
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAvailableFormatsView.toggle()
                    } label: {
                        Label("Help", systemImage: "questionmark.circle")
                    }
                }
            }
        }
        .multilineTextAlignment(.center)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                firstPage
                    .frame(width: UIScreen.main.bounds.width)
                ZStack {
                    if csvImporter.importProgress == 0 {
                        ImportSummaryView(summary: $csvImporter.importSummary)
                    } else if csvImporter.importProgress < 1 || !csvImporter.importComplete {
                        VStack(spacing: 50) {
                            ProgressView()
                            ProgressView(value: csvImporter.importProgress.round(to: 2)) {
                                Text(csvImporter.importProgress.round(to: 2), format: .percent)
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding()
                    } else if csvImporter.importComplete {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 80))
                            .transition(.scale)
                            .foregroundStyle(.green)
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
            }
            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
            .offset(x: UIScreen.main.bounds.width * -CGFloat(currentlySelectedPageIndex), y: 0)
            .animation(.easeInOut, value: currentlySelectedPageIndex)
            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: csvImporter.importComplete)
            .animation(.easeInOut, value: csvImporter.importProgress)
            
            // MARK: Buttons
            HStack {
                Button {
                    Haptics.shared.play(.soft)
                    if currentlySelectedPageIndex == 0 {
                        dismiss()
                    } else {
                        withAnimation {
                            currentlySelectedPageIndex -= 1
                        }
                    }
                } label: {
                    Image(systemName: currentlySelectedPageIndex == 0 ? "xmark" : "chevron.backward")
                        .padding(5)
                }
                .buttonStyle(.bordered)
                .tint(currentlySelectedPageIndex == 0 ? .red : nil)
                .disabled(csvImporter.isReading || csvImporter.importProgress > 0)
                Spacer()
                Button {
                    Haptics.shared.play(.soft)
                    if currentlySelectedPageIndex == 0 {
                        withAnimation {
                            currentlySelectedPageIndex += 1
                        }
                    } else {
                        withAnimation {
                            csvImporter.importCSV(dismissFunc: {
                                dismiss()
                            })
                        }
                    }
                } label: {
                    Group {
                        if currentlySelectedPageIndex == 0 {
                            Image(systemName: "chevron.forward")
                        } else {
                            Label("Import", systemImage: "chevron.forward")
                        }
                    }
                    .padding(5)
                }
                .buttonStyle(.bordered)
                .disabled(
                    csvImporter.importSummary == nil
                    || csvImporter.importProgress > 0
                    || (currentlySelectedPageIndex == 1 && csvImporter.importSummary?.rowsAmount == 0))
                .tint(currentlySelectedPageIndex == 1 ? .green : nil)
            }
            .padding()
        }
        .alert("Could not read this file", isPresented: $csvImporter.showInvalidFileAlert) {
            Button("Try again") {
                csvImporter.showInvalidFileAlert.toggle()
            }
        } message: {
            Text("Please make sure to use a csv file with the correct format.")
        }
        .fileImporter(isPresented: $csvImporter.showDocumentPicker, allowedContentTypes: [.commaSeparatedText]) { result in
            switch result {
                case .success(let fileURL):
                    let gotAccess = fileURL.startAccessingSecurityScopedResource()
                    if !gotAccess { return }
                    do {
                        csvImporter.csvFileContent = try String(contentsOf: fileURL, encoding: .utf8)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                    fileURL.stopAccessingSecurityScopedResource()
              case .failure(let error):
                    print(error)
              }
                
        }
        .sheet(isPresented: $showAvailableFormatsView) {
            AvailableCSVFormatsView()
        }
    }
}

fileprivate struct AvailableCSVFormatsView: View {
    var body: some View {
        ScrollView {
            VStack {
                Group {
                    HStack(alignment: .top) {
                        Text("ℹ️").font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text("How to import .csv files").font(.headline).bold()
                            Text("You can import three essential data types: Transactions, Savings Entries, and Recurring Expenses.")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                Group {
                    Text("Below, you'll find the valid CSV headers for each category. Simply match your file's headers to these standards for seamless integration.")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                
                ForEach(CSVValidHeaders.allCases, id: \.hashValue) { headers in
                    let cols = headers.rawValue.split(separator: ",")
                    let types = headers.types.split(separator: ",")
                    VStack(alignment: .leading) {
                        Text(headers.resourceName).font(.subheadline.bold())
                            .padding(.horizontal)
                        Grid(alignment: .leading) {
                            ForEach(Array(cols.enumerated()), id: \.0) { i, col in
                                let type = types[i]
                                GridRow {
                                    Text(col).font(.footnote.monospaced())
                                    Spacer()
                                    Text(type).font(.footnote.monospaced())
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.top, 20)
            }
            .padding()
            .padding(.top, 50)
        }
        .scrollIndicators(.hidden)
    }
}

struct More_SystemView: View {
    @StateObject private var content = SettingsSystemViewModel()
    @State private var showDeleteAllConfirmation: Bool = false
    
    var body: some View {
        List {
            dataSection
            importSection
            exportSection
        }
        
        .sheet(isPresented: $content.showFilePicker) {
            ImportCSVWizard()
                .interactiveDismissDisabled()
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
                Label("Select CSV", systemImage: "square.and.arrow.down")
            }
        }
    }
    
    var exportSection: some View {
        Section(header: Text("Export Data"), footer: Text("Export your App-Data into .csv format and save it on your device.")) {
            ShareLink(
                "Create Backup",
                item: ZipBackup(),
                preview: SharePreview("Backup")
            )
        }
    }
}

struct Settings_SystemView_Previews: PreviewProvider {
    static var previews: some View {
        AvailableCSVFormatsView()
    }
}

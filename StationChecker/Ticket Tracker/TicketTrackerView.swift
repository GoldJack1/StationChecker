import SwiftUI
import UniformTypeIdentifiers

struct TicketTrackerView: View {
    @State private var tickets: [TicketRecord] = []
    @State private var showImporter = false
    @State private var showAddTicketForm = false

    var body: some View {
        NavigationView {
            VStack {
                if tickets.isEmpty {
                    Text("No tickets available. Import, add, or create a new ticket.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(tickets.indices, id: \.self) { index in
                            NavigationLink(
                                destination: TicketDetailView(
                                    origin: tickets[index].origin,
                                    destination: tickets[index].destination,
                                    price: tickets[index].price,
                                    ticketType: tickets[index].ticketType,
                                    outboundDate: tickets[index].outboundDate,
                                    returnDate: tickets[index].returnDate,
                                    wasDelayed: tickets[index].wasDelayed,
                                    delayDuration: tickets[index].delayDuration,
                                    compensation: tickets[index].compensation,
                                    loyaltyProgram: tickets[index].loyaltyProgram,
                                    onSave: { updatedTicket in
                                        tickets[index] = updatedTicket
                                        saveTicketsToDisk()
                                    }
                                )
                            ) {
                                TicketCard(ticket: tickets[index])
                            }
                        }
                        .onDelete(perform: deleteTickets)
                    }
                    .listStyle(PlainListStyle())
                }

                HStack {
                    Button("Import CSV") {
                        showImporter = true
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Export CSV") {
                        exportCSV()
                    }
                    .buttonStyle(.bordered)

                    Button("Clear All") {
                        clearAllTickets()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle("Ticket Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTicketForm = true }) {
                        Label("Add Ticket", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTicketForm) {
                TicketFormView { newTicket in
                    tickets.append(newTicket)
                    saveTicketsToDisk()
                }
            }
            .onAppear(perform: loadTicketsFromDisk)
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                handleFilePicker(result: result)
            }
        }
    }

    private func handleFilePicker(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            guard fileURL.startAccessingSecurityScopedResource() else { return }
            defer { fileURL.stopAccessingSecurityScopedResource() }

            let importedTickets = TicketDataManager.shared.parseTickets(from: fileURL)
            if !importedTickets.isEmpty {
                tickets.append(contentsOf: importedTickets)
                saveTicketsToDisk()
                print("[TicketTrackerView] Imported \(importedTickets.count) tickets.")
            }
        case .failure(let error):
            print("[TicketTrackerView] File picker error: \(error.localizedDescription)")
        }
    }

    private func exportCSV() {
        let csvContent = TicketDataManager.shared.exportTicketsToCSV(tickets: tickets)

        // Create a temporary file to hold the CSV content
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("tickets.csv")

        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)

            // Use a coordinator to present the document picker
            let coordinator = DocumentPickerCoordinator()
            let picker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
            picker.delegate = coordinator
            picker.allowsMultipleSelection = false

            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootController = scene.windows.first?.rootViewController {
                rootController.present(picker, animated: true)
            }
        } catch {
            print("Error writing CSV file: \(error.localizedDescription)")
        }
    }

    private func saveTicketsToDisk() {
        TicketDataManager.shared.saveTicketsToDisk(tickets)
    }

    private func loadTicketsFromDisk() {
        tickets = TicketDataManager.shared.loadTicketsFromDisk()
    }

    private func deleteTickets(at offsets: IndexSet) {
        tickets.remove(atOffsets: offsets)
        saveTicketsToDisk()
    }

    private func clearAllTickets() {
        tickets.removeAll()
        saveTicketsToDisk()
    }
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let savedURL = urls.first else { return }
        print("File successfully saved to: \(savedURL)")
    }
}

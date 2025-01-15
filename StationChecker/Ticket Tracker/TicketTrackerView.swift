import SwiftUI
import UniformTypeIdentifiers

struct TicketTrackerView: View {
    @State private var tickets: [TicketRecord] = []
    @State private var filteredTickets: [TicketRecord] = []
    @State private var showStatisticsSheet: Bool = false
    @State private var searchText: String = ""
    @State private var isFilterSheetPresented: Bool = false
    @State private var showImporter = false
    @State private var showAddTicketForm = false

    @State private var selectedTOC: String = ""
    @State private var selectedClassType: String = ""
    @State private var selectedTicketType: String = ""
    @State private var selectedDelayMinutes: String = ""
    @State private var selectedLoyaltyProgram: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()

    let sortOptions = ["Newest - Oldest Date", "Oldest - Newest Date", "Price High - Price Low", "Price Low - Price High"]
    @State private var sortBy: String = "Newest - Oldest Date"

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                searchBarAndSortMenu()
                ticketListView()
            }
            .navigationTitle("Ticket Tracker")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showImporter = true }) {
                        Image(systemName: "tray.and.arrow.down")
                            .foregroundColor(.primary)
                            .accessibilityLabel("Import CSV")
                    }
                    Button(action: { exportCSV() }) {
                        Image(systemName: "tray.and.arrow.up")
                            .foregroundColor(.primary)
                            .accessibilityLabel("Export CSV")
                    }
                    Button(action: { clearAllTickets() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.primary)
                            .accessibilityLabel("Clear All Tickets")
                    }
                    Button(action: { showStatisticsSheet = true }) {
                        Image(systemName: "chart.bar")
                            .foregroundColor(.primary)
                            .accessibilityLabel("Statistics")
                    }
                    Button(action: { showAddTicketForm = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.primary)
                            .accessibilityLabel("Add Ticket")
                    }
                }
            }
            .sheet(isPresented: $isFilterSheetPresented) {
                TicketFilterSheet(
                    tickets: $tickets,
                    filteredTickets: $filteredTickets,
                    selectedTOC: $selectedTOC,
                    selectedClassType: $selectedClassType,
                    selectedTicketType: $selectedTicketType,
                    selectedDelayMinutes: $selectedDelayMinutes,
                    selectedLoyaltyProgram: $selectedLoyaltyProgram,
                    startDate: $startDate,
                    endDate: $endDate,
                    isPresented: $isFilterSheetPresented
                )
            }
            .sheet(isPresented: $showStatisticsSheet) {
                TicketStatisticsSheet(tickets: tickets)
            }
            .sheet(isPresented: $showAddTicketForm) {
                TicketFormView { newTicket in
                    tickets.append(newTicket)
                    filterAndSortTickets()
                    saveTicketsToDisk()
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                handleFilePicker(result: result)
            }
            .onAppear {
                loadTicketsFromDisk()
                filterAndSortTickets()
            }
        }
    }

    // MARK: - UI Components

    private func searchBarAndSortMenu() -> some View {
        HStack {
            // Search Bar
            TextField("Search...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .onChange(of: searchText) { _ in
                    filterAndSortTickets()
                }

            // Sort Menu
            Menu {
                ForEach(sortOptions, id: \.self) { option in
                    Button(option) {
                        sortBy = option
                        filterAndSortTickets()
                    }
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.trailing, 8)

            // Filter Button
            Button(action: {
                isFilterSheetPresented = true
            }) {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 8)
    }

    private func ticketListView() -> some View {
        Group {
            if filteredTickets.isEmpty {
                Text("No tickets available. Import, add, or create a new ticket.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) { // Adjust spacing between cards
                        ForEach(filteredTickets.indices, id: \.self) { index in
                            ticketRow(for: index)
                        }
                    }
                    .padding(.vertical) // Optional: Add top/bottom padding for the scroll area
                }
            }
        }
    }

    func ticketRow(for index: Int) -> some View {
        NavigationLink(destination: TicketDetailView(
            ticket: $filteredTickets[index],
            onUpdate: { updatedTicket in
                updateTicket(updatedTicket)
            }
        )) {
            TicketCard(ticket: filteredTickets[index])
                .padding(.vertical, 8) // Add vertical padding
        }
        .buttonStyle(PlainButtonStyle()) // Remove default NavigationLink styling
    }
    
    // MARK: - Helper Methods

    func filterAndSortTickets() {
        filteredTickets = tickets.filter { ticket in
            searchText.isEmpty || ticket.origin.contains(searchText) || ticket.destination.contains(searchText)
        }

        switch sortBy {
        case "Newest - Oldest Date":
            filteredTickets.sort { $0.outboundDate > $1.outboundDate }
        case "Oldest - Newest Date":
            filteredTickets.sort { $0.outboundDate < $1.outboundDate }
        case "Price High - Price Low":
            filteredTickets.sort { parsePrice($0.price) > parsePrice($1.price) }
        case "Price Low - Price High":
            filteredTickets.sort { parsePrice($0.price) < parsePrice($1.price) }
        default:
            break
        }
    }

    func parsePrice(_ price: String) -> Double {
        let sanitized = price.replacingOccurrences(of: "£", with: "").trimmingCharacters(in: .whitespaces)
        return Double(sanitized) ?? 0.0
    }

    func saveTicketsToDisk() {
        TicketDataManager.shared.saveTicketsToDisk(tickets)
    }

    func loadTicketsFromDisk() {
        tickets = TicketDataManager.shared.loadTicketsFromDisk()
    }

    func updateTicket(_ updatedTicket: TicketRecord) {
        if let index = tickets.firstIndex(where: { $0.id == updatedTicket.id }) {
            tickets[index] = updatedTicket
            saveTicketsToDisk()
            filterAndSortTickets()
        }
    }

    func deleteTickets(at offsets: IndexSet) {
        tickets.remove(atOffsets: offsets)
        saveTicketsToDisk()
        filterAndSortTickets()
    }

    func clearAllTickets() {
        tickets.removeAll()
        saveTicketsToDisk()
        filterAndSortTickets()
    }

    func handleFilePicker(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            guard fileURL.startAccessingSecurityScopedResource() else { return }
            defer { fileURL.stopAccessingSecurityScopedResource() }

            tickets = TicketDataManager.shared.parseCSV(fileURL: fileURL)
            saveTicketsToDisk()
            filterAndSortTickets()
        case .failure(let error):
            print("File picker error: \(error.localizedDescription)")
        }
    }

    func exportCSV() {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("tickets.csv")
        TicketDataManager.shared.exportCSV(tickets: tickets, to: fileURL)

        let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL])
        documentPicker.delegate = DocumentPickerCoordinator.shared
        documentPicker.allowsMultipleSelection = false

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(documentPicker, animated: true)
        }
    }
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    static let shared = DocumentPickerCoordinator()

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let selectedURL = urls.first {
            print("CSV file saved to: \(selectedURL.path)")
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}

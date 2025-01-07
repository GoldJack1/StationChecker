import SwiftUI

struct TicketTrackerView: View {
    @State private var tickets: [TicketRecord] = TicketDataManager.shared.loadTickets()
    @State private var filteredTickets: [TicketRecord] = []
    @State private var searchQuery: String = ""
    @State private var showFilePicker = false
    @State private var showAddTicketForm = false
    @State private var showStatisticsView = false
    @State private var showDataOptionsSheet = false
    @State private var errorMessage: String? = nil

    // Add a filter for delayRepay (used as an example of visited tickets)
    @State private var showOnlyVisited: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with Search Bar and Buttons
            VStack(spacing: 0) {
                HStack {
                    Text("Ticket Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: { showAddTicketForm = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .padding(10)
                            .background(Circle().fill(Color(.systemGray5)))
                            .foregroundColor(.primary)
                    }
                    Button(action: { showStatisticsView = true }) {
                        Image(systemName: "chart.bar")
                            .font(.title3)
                            .padding(10)
                            .background(Circle().fill(Color(.systemGray5)))
                            .foregroundColor(.primary)
                    }
                    Button(action: { showDataOptionsSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .padding(10)
                            .background(Circle().fill(Color(.systemGray5)))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 5)
                .background(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }

            // Content with Tickets List and Filter
            VStack {
                // Search Bar
                TextField("Search Tickets", text: $searchQuery)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .cornerRadius(25)
                    .onChange(of: searchQuery) { oldValue, newValue in
                        filterTickets()
                    }
                    .padding(.horizontal)

                // Filter Buttons
                HStack {
                    Toggle("Show Visited Tickets", isOn: $showOnlyVisited)
                        .onChange(of: showOnlyVisited) { _ in filterTickets() }
                }
                .padding(.horizontal)

                // Filtered List
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if filteredTickets.isEmpty {
                    Text("No tickets to display.\nImport a CSV file to get started.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(filteredTickets) { ticket in
                        TicketCard(ticket: ticket)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Optional: Load or refresh ticket data
            filterTickets()
        }
        .sheet(isPresented: $showAddTicketForm) {
            TicketAddForm(onAddTicket: { newTicket in
                tickets.append(newTicket)
                TicketDataManager.shared.saveTicketsToDisk(tickets)
            })
        }
        .sheet(isPresented: $showStatisticsView) {
            TicketStatisticsView(tickets: tickets)
        }
        .sheet(isPresented: $showDataOptionsSheet) {
            TicketDataOptionsSheet(
                onImport: { dataType in
                    showFilePicker = true
                },
                onExport: { dataType in
                    // Implement export functionality here
                },
                onClearData: {
                    tickets.removeAll()
                    TicketDataManager.shared.saveTicketsToDisk(tickets)
                },
                onAddTicket: {
                    showAddTicketForm = true
                }
            )
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result: result)
        }
    }

    private func filterTickets() {
        filteredTickets = tickets.filter { ticket in
            var isValid = true

            // Apply search query filtering
            if !searchQuery.isEmpty {
                isValid = isValid && (ticket.origin.localizedCaseInsensitiveContains(searchQuery) ||
                                      ticket.destination.localizedCaseInsensitiveContains(searchQuery) ||
                                      ticket.ticketType.localizedCaseInsensitiveContains(searchQuery))
            }

            // Apply 'Visited' filter: Show tickets with non-zero delayRepay (as an example)
            if showOnlyVisited {
                isValid = isValid && ticket.delayRepay != "£0.00"
            }

            return isValid
        }
    }

    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            guard fileURL.startAccessingSecurityScopedResource() else { return }
            defer { fileURL.stopAccessingSecurityScopedResource() }

            let importedTickets = TicketDataManager.shared.importTickets(from: fileURL)
            if !importedTickets.isEmpty {
                tickets.append(contentsOf: importedTickets)
                TicketDataManager.shared.saveTicketsToDisk(tickets)
                filterTickets()
            }
        case .failure(let error):
            print("[TicketTrackerView] File import failed: \(error.localizedDescription)")
        }
    }
}

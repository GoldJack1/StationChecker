import SwiftUI

struct TicketStatisticsSheet: View {
    let tickets: [TicketRecord]

    @State private var inputMiles: String = UserDefaults.standard.string(forKey: "inputMiles") ?? ""
    @State private var inputChains: String = UserDefaults.standard.string(forKey: "inputChains") ?? ""
    @State private var costPerMile: Double? = UserDefaults.standard.double(forKey: "costPerMile") == 0 ? nil : UserDefaults.standard.double(forKey: "costPerMile")

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    statisticsSection()
                    distributionSection()
                    costPerRailMileSection()
                }
                .padding()
            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Ticket Statistics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismissSheet()
                    }
                }
            }
        }
    }

    // MARK: - Statistics Section
    private func statisticsSection() -> some View {
        VStack(spacing: 16) {
            Text("Overview")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                StatisticRow(label: "Total Tickets", value: "\(tickets.count)", color: .blue)
                StatisticRow(label: "Total Spent", value: "£\(String(format: "%.2f", totalSpent()))", color: .green)
                StatisticRow(label: "Compensation Received", value: "£\(String(format: "%.2f", totalCompensation()))", color: .orange)
                StatisticRow(label: "Adjusted Total (Spent - Compensation)", value: "£\(String(format: "%.2f", adjustedTotalSpent()))", color: .purple)
                StatisticRow(label: "Virgin Points Earned", value: "\(totalVirginPoints())", color: .purple)
                StatisticRow(label: "LNER Perks", value: "£\(String(format: "%.2f", totalLNERPerks()))", color: .red)
                StatisticRow(label: "Club Avanti Journeys", value: "\(totalClubAvantiJourneys())", color: .pink)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        }
    }

    // MARK: - Distribution Section
    private func distributionSection() -> some View {
        VStack(spacing: 16) {
            Text("Distributions")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                if !ticketsByTOC.isEmpty {
                    PieChartView(
                        slices: ticketsByTOC.map { toc, count in
                            let color = Color(hex: tocColors[toc] ?? "#888888") ?? .gray
                            return (color: color, value: Double(count), label: toc)
                        },
                        title: "TOC Distribution"
                    )
                }

                if !ticketsByType.isEmpty {
                    PieChartView(
                        slices: ticketsByType.map { type, count in
                            return (color: .random(), value: Double(count), label: type)
                        },
                        title: "Ticket Types"
                    )
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        }
    }

    // MARK: - Cost Per Rail Mile Section
    private func costPerRailMileSection() -> some View {
        VStack(spacing: 16) {
            Text("Cost Per Rail Mile")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                HStack {
                    TextField("Miles", text: $inputMiles)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: inputMiles) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "inputMiles")
                        }

                    TextField("Chains", text: $inputChains)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: inputChains) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "inputChains")
                        }
                }

                Button(action: calculateCostPerMile) {
                    Text("Calculate")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                if let costPerMile = costPerMile {
                    Text("£\(String(format: "%.2f", costPerMile))")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.green)
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        }
    }

    // MARK: - Helper Methods
    private func calculateCostPerMile() {
        guard let miles = Double(inputMiles),
              let chains = Double(inputChains),
              miles >= 0, chains >= 0, chains < 80 else {
            costPerMile = nil
            UserDefaults.standard.removeObject(forKey: "costPerMile")
            return
        }

        // Convert chains to fraction of a mile
        let totalMileage = miles + (chains / 80)
        let totalSpent = adjustedTotalSpent()

        costPerMile = totalMileage > 0 ? totalSpent / totalMileage : nil
        UserDefaults.standard.set(costPerMile, forKey: "costPerMile")
    }

    private func totalSpent() -> Double {
        tickets.reduce(0) { $0 + parsePrice($1.price) }
    }

    private func totalCompensation() -> Double {
        tickets.reduce(0) { $0 + parsePrice($1.compensation) }
    }

    private func adjustedTotalSpent() -> Double {
        totalSpent() - totalCompensation()
    }

    private func totalVirginPoints() -> Int {
        tickets.compactMap { Int($0.loyaltyProgram?.virginPoints ?? "") }.reduce(0, +)
    }

    private func totalLNERPerks() -> Double {
        tickets.compactMap { Double($0.loyaltyProgram?.lnerCashValue ?? "") }.reduce(0, +)
    }

    private func totalClubAvantiJourneys() -> Int {
        tickets.compactMap { Int($0.loyaltyProgram?.clubAvantiJourneys ?? "") }.reduce(0, +)
    }

    private func parsePrice(_ price: String) -> Double {
        Double(price.replacingOccurrences(of: "£", with: "").trimmingCharacters(in: .whitespaces)) ?? 0.0
    }

    private func dismissSheet() {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    private var ticketsByTOC: [String: Int] {
        Dictionary(grouping: tickets, by: { $0.toc ?? "Unknown" })
            .mapValues { $0.count }
    }

    private var ticketsByType: [String: Int] {
        Dictionary(grouping: tickets, by: { $0.ticketType })
            .mapValues { $0.count }
    }
}

struct StatisticRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(label + ":")
                .font(.headline)
                .foregroundColor(color)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 5)
    }
}

struct PieChartView: View {
    let slices: [(color: Color, value: Double, label: String)]
    let title: String

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 8)
            
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<slices.count, id: \.self) { index in
                        PieSliceView(
                            startAngle: self.angle(for: index),
                            endAngle: self.angle(for: index + 1),
                            color: self.slices[index].color
                        )
                    }
                }
                .aspectRatio(1, contentMode: .fit)
            }
            .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(slices, id: \.label) { slice in
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(slice.color)
                            .frame(width: 16, height: 16)
                        Text("\(slice.label): \(Int(slice.value))")
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
    }

    private func angle(for index: Int) -> Angle {
        let total = slices.reduce(0) { $0 + $1.value }
        let startValue = slices.prefix(index).reduce(0) { $0 + $1.value }
        return .degrees((startValue / total) * 360)
    }
}

struct PieSliceView: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color

    var body: some View {
        Path { path in
            let center = CGPoint(x: 100, y: 100)
            let radius: CGFloat = 100
            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
        .fill(color)
    }
}

extension Color {
    static func random() -> Color {
        Color(
            red: Double.random(in: 0.2...0.8),
            green: Double.random(in: 0.2...0.8),
            blue: Double.random(in: 0.2...0.8)
        )
    }
}

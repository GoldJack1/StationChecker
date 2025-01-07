//
//  TicketAddForm.swift
//  StationChecker
//
//  Created by Jack Wingate on 07/01/2025.
//


import SwiftUI

struct TicketAddForm: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var origin = ""
    @State private var destination = ""
    @State private var ticketType = ""
    @State private var travelClass = ""
    @State private var price = ""
    @State private var delayRepay = ""
    @State private var outboundDate = ""
    @State private var returnDate = ""
    @State private var delayMins = ""

    var onAddTicket: ((TicketRecord) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ticket Information")) {
                    TextField("Origin", text: $origin)
                    TextField("Destination", text: $destination)
                    TextField("Ticket Type", text: $ticketType)
                    TextField("Travel Class", text: $travelClass)
                    TextField("Price", text: $price)
                    TextField("Delay Repay", text: $delayRepay)
                    TextField("Outbound Date", text: $outboundDate)
                    TextField("Return Date", text: $returnDate)
                    TextField("Delay Mins", text: $delayMins)
                }
                
                Button(action: {
                    let newTicket = TicketRecord(
                        origin: origin,
                        destination: destination,
                        rangerRover: nil,
                        ticketType: ticketType,
                        travelClass: travelClass,
                        price: price,
                        delayRepay: delayRepay,
                        outboundDate: outboundDate,
                        returnDate: returnDate,
                        delayMins: delayMins
                    )
                    onAddTicket?(newTicket)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Add Ticket")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Add Ticket")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
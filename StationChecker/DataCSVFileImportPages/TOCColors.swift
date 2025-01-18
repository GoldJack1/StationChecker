import SwiftUI

// Dictionary mapping TOC names to their HEX color codes
let tocColors: [String: String] = [
    "Standard": "#868686",
    "First": "#9800F0",
    "Greater Anglia": "#d70428",
    "ScotRail": "#1e467d",
    "Avanti West Coast": "#004354",
    "c2c": "#b7007c",
    "Caledonian Sleeper": "#1d2e35",
    "Chiltern Railways": "#00bfff",
    "CrossCountry": "#660f21",
    "East Midlands Railway": "#713563",
    "Great Western Railway": "#0a493e",
    "Hull Trains": "#de005c",
    "Thameslink/Great Northern": "#ff5aa4",
    "Heathrow Express": "#532e63",
    "Island Line": "#1e90ff",
    "Transport For Wales": "#ff0000",
    "LNER": "#ce0e2d",
    "Northern": "#034DE2",
    "TransPennine Express": "#09a4ec",
    "Merseyrail": "#fff200",
    // Add more TOCs and their colors as needed
]

// Extension to initialize Color with a HEX string
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

// Function to get a Color for a TOC
func colorForTOC(_ toc: String?) -> Color? {
    guard let toc = toc, let hex = tocColors[toc] else {
        return nil // Return nil if TOC or HEX code is not found
    }
    return Color(hex: hex)
}

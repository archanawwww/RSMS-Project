import Foundation
import CoreLocation
import MapKit

struct BoutiqueInventoryHelper {
    
    static func flagEmoji(for country: String) -> String {
        switch country {
        case "India": return "🇮🇳"
        case "United States": return "🇺🇸"
        case "China": return "🇨🇳"
        case "Germany": return "🇩🇪"
        case "France": return "🇫🇷"
        case "Italy": return "🇮🇹"
        case "Australia": return "🇦🇺"
        case "UAE": return "🇦🇪"
        case "Japan": return "🇯🇵"
        case "United Kingdom": return "🇬🇧"
        default: return "🌍"
        }
    }
    
    static func getStoreCode(name: String, city: String) -> String {
        let cleanCity = city.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let prefix: String
        if cleanCity.contains("york") { prefix = "YOR" }
        else if cleanCity.contains("los") { prefix = "LOS" }
        else if cleanCity.contains("chicago") { prefix = "CHI" }
        else if cleanCity.contains("miami") { prefix = "MIA" }
        else if cleanCity.contains("delhi") { prefix = "DEL" }
        else if cleanCity.contains("mumbai") { prefix = "MUM" }
        else if cleanCity.contains("bangalore") || cleanCity.contains("bengaluru") { prefix = "BEN" }
        else if cleanCity.contains("hyderabad") { prefix = "HYD" }
        else if cleanCity.contains("chennai") { prefix = "CHE" }
        else if cleanCity.contains("beijing") { prefix = "BEI" }
        else if cleanCity.contains("shanghai") { prefix = "SHA" }
        else if cleanCity.contains("shenzhen") { prefix = "SHE" }
        else if cleanCity.contains("berlin") { prefix = "BER" }
        else if cleanCity.contains("munich") { prefix = "MUN" }
        else if cleanCity.contains("frankfurt") { prefix = "FRA" }
        else if cleanCity.contains("hamburg") { prefix = "HAM" }
        else if cleanCity.contains("paris") { prefix = "PAR" }
        else if cleanCity.contains("lyon") { prefix = "LYO" }
        else if cleanCity.contains("marseille") { prefix = "MAR" }
        else if cleanCity.contains("milan") { prefix = "MIL" }
        else if cleanCity.contains("rose") { prefix = "ROM" } // Wait, rome / rose
        else if cleanCity.contains("rome") { prefix = "ROM" }
        else if cleanCity.contains("florence") { prefix = "FLO" }
        else if cleanCity.contains("sydney") { prefix = "SYD" }
        else if cleanCity.contains("melbourne") { prefix = "MEL" }
        else if cleanCity.contains("brisbane") { prefix = "BRI" }
        else if cleanCity.contains("perth") { prefix = "PER" }
        else if cleanCity.contains("dubai") { prefix = "DXB" }
        else if cleanCity.contains("abu") { prefix = "AUH" }
        else if cleanCity.contains("tokyo") { prefix = "TYO" }
        else if cleanCity.contains("osaka") { prefix = "OSA" }
        else if cleanCity.contains("london") { prefix = "LON" }
        else { prefix = String(city.prefix(3)).uppercased() }
        
        let components = name.components(separatedBy: " ")
        let suffix: String
        if let last = components.last, last == "I" || last == "II" || last == "III" {
            if last == "I" { suffix = "001" }
            else if last == "II" { suffix = "002" }
            else { suffix = "003" }
        } else {
            suffix = "001"
        }
        return "LM-\(prefix)-\(suffix)"
    }
    
    static func getManagerInfo(for store: SupabaseStore, in users: [ManagedUser]) -> (name: String, email: String) {
        if let managerID = store.managerID, let user = users.first(where: { $0.id == managerID }) {
            return (user.displayName, user.email)
        }
        if let user = users.first(where: { $0.assignedStoreID == store.id && $0.role == .boutiqueManager }) {
            return (user.displayName, user.email)
        }
        return ("Sarah Williams", "manager@luxemaison.com")
    }
    
    static func formatValuation(value: Double, currencyCode: String) -> String {
        if currencyCode == "INR" {
            let valueInCr = value / 10_000_000.0
            if valueInCr >= 0.1 {
                return String(format: "₹%.1f Cr", valueInCr)
            } else {
                return String(format: "₹%.1f L", value / 100_000.0)
            }
        } else {
            let valueInM = value / 1_000_000.0
            let symbol: String
            switch currencyCode {
            case "USD": symbol = "$"
            case "EUR": symbol = "€"
            case "CNY": symbol = "CN¥"
            case "GBP": symbol = "£"
            case "AUD": symbol = "A$"
            case "AED": symbol = "AED "
            case "JPY": symbol = "¥"
            default: symbol = "$"
            }
            if symbol == "¥" {
                return String(format: "¥%.0f", value)
            }
            return String(format: "\(symbol)%.1f M", valueInM)
        }
    }
    
    static let cityCoordinates: [String: CLLocationCoordinate2D] = [
        "delhi": CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),
        "mumbai": CLLocationCoordinate2D(latitude: 19.0960, longitude: 72.8977),
        "bengaluru": CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        "bangalore": CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946),
        "hyderabad": CLLocationCoordinate2D(latitude: 17.3850, longitude: 78.4867),
        "chennai": CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707),
        "new york": CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
        "los angeles": CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
        "chicago": CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298),
        "miami": CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918),
        "beijing": CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
        "shanghai": CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737),
        "shenzhen": CLLocationCoordinate2D(latitude: 22.5431, longitude: 114.0579),
        "berlin": CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050),
        "munich": CLLocationCoordinate2D(latitude: 48.1351, longitude: 11.5820),
        "frankfurt": CLLocationCoordinate2D(latitude: 50.1109, longitude: 8.6821),
        "hamburg": CLLocationCoordinate2D(latitude: 53.5511, longitude: 9.9937),
        "paris": CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
        "lyon": CLLocationCoordinate2D(latitude: 45.7640, longitude: 4.8357),
        "marseille": CLLocationCoordinate2D(latitude: 43.2965, longitude: 5.3698)
    ]
    
    static func getCoordinate(forStore store: SupabaseStore) -> CLLocationCoordinate2D {
        let cleanCity = (store.location ?? "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let coord = cityCoordinates[cleanCity] {
            // Apply a small deterministic offset based on the ID's hashValue components
            let hashVal = abs(store.id.hashValue)
            let hash = Double(hashVal % 100) / 5000.0
            return CLLocationCoordinate2D(latitude: coord.latitude + hash, longitude: coord.longitude + hash)
        }
        return CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629)
    }
}

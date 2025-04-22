//
//  PlugInfo.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 08/03/2025.
//

import Foundation

struct PlugInfo: Identifiable, Hashable {
    let id = UUID()
    let country: String
    let flag: String
    let voltage: String
    let frequency: String
    let plugTypes: [PlugType]
    let additionalInfo: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PlugInfo, rhs: PlugInfo) -> Bool {
        lhs.id == rhs.id
    }
    
    static let allCountries: [PlugInfo] = [
        // Europe
        PlugInfo(
            country: "United Kingdom",
            flag: "🇬🇧",
            voltage: "230V",
            frequency: "50Hz",
            plugTypes: [.typeG],
            additionalInfo: "Uses Type G three-pin rectangular blade plugs. Voltage converters may be needed for 110-120V devices."
        ),
        PlugInfo(
            country: "France",
            flag: "🇫🇷",
            voltage: "230V",
            frequency: "50Hz",
            plugTypes: [.typeC, .typeE],
            additionalInfo: "Primarily uses Type C and Type E plugs. Type E has an additional grounding pin."
        ),
        PlugInfo(
            country: "Germany",
            flag: "🇩🇪",
            voltage: "230V",
            frequency: "50Hz",
            plugTypes: [.typeC, .typeF],
            additionalInfo: "Uses Type C and Type F (Schuko) plugs. Schuko provides grounding through side clips."
        ),
        PlugInfo(
            country: "Italy",
            flag: "🇮🇹",
            voltage: "230V",
            frequency: "50Hz",
            plugTypes: [.typeC, .typeF, .typeL],
            additionalInfo: "Uses multiple plug types. Type L is specific to Italy with three round pins in-line."
        ),
        
        // North America
        PlugInfo(
            country: "United States",
            flag: "🇺🇸",
            voltage: "120V",
            frequency: "60Hz",
            plugTypes: [.typeA, .typeB],
            additionalInfo: "Most devices use Type A (two-pin) or Type B (three-pin) plugs. Voltage converters needed for 220-240V devices."
        ),
        PlugInfo(
            country: "Canada",
            flag: "🇨🇦",
            voltage: "120V",
            frequency: "60Hz",
            plugTypes: [.typeA, .typeB],
            additionalInfo: "Similar to US standards. Uses Type A and B plugs. Voltage converters needed for 220-240V devices."
        ),
        PlugInfo(
            country: "Mexico",
            flag: "🇲🇽",
            voltage: "127V",
            frequency: "60Hz",
            plugTypes: [.typeA, .typeB],
            additionalInfo: "Uses Type A and B plugs like the US. Some areas may have different voltages."
        ),
        
        // Asia
        PlugInfo(
            country: "Japan",
            flag: "🇯🇵",
            voltage: "100V",
            frequency: "50/60Hz",
            plugTypes: [.typeA, .typeB],
            additionalInfo: "Eastern Japan uses 50Hz, Western Japan uses 60Hz. Voltage converters needed for 220-240V devices."
        ),
        PlugInfo(
            country: "China",
            flag: "🇨🇳",
            voltage: "220V",
            frequency: "50Hz",
            plugTypes: [.typeA, .typeC, .typeI],
            additionalInfo: "Multiple plug types accepted. Type A, C, and I are common."
        ),
        PlugInfo(
            country: "South Korea",
            flag: "🇰🇷",
            voltage: "220V",
            frequency: "60Hz",
            plugTypes: [.typeC, .typeF],
            additionalInfo: "Primarily uses Type C and F plugs. Some older buildings may have Type A outlets."
        ),
        PlugInfo(
            country: "India",
            flag: "🇮🇳",
            voltage: "230V",
            frequency: "50Hz",
            plugTypes: [.typeC, .typeD, .typeM],
            additionalInfo: "Type C and D are most common. Some older installations use Type M."
        ),
        
        // Oceania
        PlugInfo(
            country: "Australia",
            flag: "🇦🇺",
            voltage: "230V",
            frequency: "50Hz",
            plugTypes: [.typeI],
            additionalInfo: "Uses Type I plugs with three flat pins in a triangular pattern."
        ),
        PlugInfo(
            country: "New Zealand",
            flag: "🇳🇿",
            voltage: "230V",
            frequency: "50Hz",
            plugTypes: [.typeI],
            additionalInfo: "Uses Type I plugs similar to Australia. Voltage converters needed for 110-120V devices."
        ),
        
        // South America
        PlugInfo(
            country: "Brazil",
            flag: "🇧🇷",
            voltage: "127/220V",
            frequency: "60Hz",
            plugTypes: [.typeC, .typeN],
            additionalInfo: "Voltage varies by region. Type N is standard but Type C is also common."
        ),
        PlugInfo(
            country: "Argentina",
            flag: "🇦🇷",
            voltage: "220V",
            frequency: "50Hz",
            plugTypes: [.typeC, .typeI],
            additionalInfo: "Type C and I are most common. Some areas may use different plug types."
        ),
        
        // Middle East
        PlugInfo(
            country: "Israel",
            flag: "🇮🇱",
            voltage: "230V",
            frequency: "50Hz",
            plugTypes: [.typeC, .typeH],
            additionalInfo: "Type C and H are standard. Type H is unique to Israel."
        ),
        PlugInfo(
            country: "UAE",
            flag: "🇦🇪",
            voltage: "230V",
            frequency: "50Hz",
            plugTypes: [.typeC, .typeG],
            additionalInfo: "Type G (British standard) is most common, but Type C is also widely used."
        ),
        
        // Africa
        PlugInfo(
            country: "South Africa",
            flag: "🇿🇦",
            voltage: "230V",
            frequency: "50Hz",
            plugTypes: [.typeC, .typeM, .typeN],
            additionalInfo: "Type M is standard but Type C and N are also used. Older buildings may have different sockets."
        ),
        PlugInfo(
            country: "Egypt",
            flag: "🇪🇬",
            voltage: "220V",
            frequency: "50Hz",
            plugTypes: [.typeC, .typeF],
            additionalInfo: "Type C and F are most common. Some places may use Type G."
        )
    ]
}

// Update PlugType to include new types
enum PlugType: String, CaseIterable, Hashable {
    case typeA = "Type A"
    case typeB = "Type B"
    case typeC = "Type C"
    case typeD = "Type D"
    case typeE = "Type E"
    case typeF = "Type F"
    case typeG = "Type G"
    case typeH = "Type H"
    case typeI = "Type I"
    case typeJ = "Type J"
    case typeK = "Type K"
    case typeL = "Type L"
    case typeM = "Type M"
    case typeN = "Type N"
    
    var description: String {
        switch self {
        case .typeA:
            return "Two flat parallel pins (Ungrounded)"
        case .typeB:
            return "Two flat parallel pins with ground pin"
        case .typeC:
            return "Two round pins (Euro plug)"
        case .typeD:
            return "Three round pins in triangular pattern"
        case .typeE:
            return "Two round pins with female ground contact"
        case .typeF:
            return "Two round pins with side grounding clips (Schuko)"
        case .typeG:
            return "Three rectangular pins in triangular pattern (British)"
        case .typeH:
            return "Three round pins in triangular pattern (Israel)"
        case .typeI:
            return "Three flat pins in triangular pattern (Australia/China)"
        case .typeJ:
            return "Three round pins in triangular pattern (Swiss)"
        case .typeK:
            return "Two round pins with side grounding contact"
        case .typeL:
            return "Three round pins in line (Italian)"
        case .typeM:
            return "Three round pins in triangular pattern (South African)"
        case .typeN:
            return "Three round pins (Brazilian)"
        }
    }
}

//
//  TimeZoneService.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 08/03/2025.
//

import Foundation

class TimeZoneService: ObservableObject {
    static let shared = TimeZoneService()
    
    let timeZones: [TimeZone] = TimeZone.knownTimeZoneIdentifiers
        .compactMap { TimeZone(identifier: $0) }
        .sorted { $0.secondsFromGMT() < $1.secondsFromGMT() }
    
    func formatTimeZone(_ timeZone: TimeZone) -> String {
        let offset = timeZone.secondsFromGMT()
        let hours = abs(offset) / 3600
        let minutes = (abs(offset) % 3600) / 60
        let sign = offset >= 0 ? "+" : "-"
        
        let cityName = timeZone.identifier.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? ""
        return "\(cityName) (GMT\(sign)\(hours):\(String(format: "%02d", minutes)))"
    }
    
    func convertTime(_ date: Date, from source: TimeZone, to target: TimeZone) -> Date {
        let sourceOffset = source.secondsFromGMT(for: date)
        let targetOffset = target.secondsFromGMT(for: date)
        let difference = targetOffset - sourceOffset
        return date.addingTimeInterval(TimeInterval(difference))
    }
    
    func calculateJetLag(from source: TimeZone, to target: TimeZone) -> Int {
        let hourDifference = (target.secondsFromGMT() - source.secondsFromGMT()) / 3600
        return abs(hourDifference)
    }
}

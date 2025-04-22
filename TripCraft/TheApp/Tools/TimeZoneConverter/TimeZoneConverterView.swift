//
//  TimeZoneConverterView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 03/03/2025.
//

import SwiftUI

struct TimeZoneConverterView: View {
    @State private var sourceTime = Date()
    @State private var sourceTimeZone = TimeZone.current
    @State private var targetTimeZone = TimeZone(identifier: "UTC")!
    @State private var showingTimeZonePicker = false
    @State private var isSelectingSource = true
    
    private let timeZoneService = TimeZoneService.shared
    
    var convertedTime: Date {
        timeZoneService.convertTime(sourceTime, from: sourceTimeZone, to: targetTimeZone)
    }
    
    var jetLagHours: Int {
        timeZoneService.calculateJetLag(from: sourceTimeZone, to: targetTimeZone)
    }
    
    var body: some View {
        List {
            // Time Selection Section
            Section {
                DatePicker("Select Time", selection: $sourceTime)
                    .datePickerStyle(.graphical)
            } header: {
                Label("Source Time", systemImage: "clock")
            }
            
            // Time Zones Section
            Section {
                TimeZoneRow(
                    title: "From",
                    timeZone: sourceTimeZone,
                    action: { selectTimeZone(isSource: true) }
                )
                
                TimeZoneRow(
                    title: "To",
                    timeZone: targetTimeZone,
                    action: { selectTimeZone(isSource: false) }
                )
            } header: {
                Label("Time Zones", systemImage: "globe")
            }
            
            // Result Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "arrow.2.circlepath")
                            .foregroundColor(.blue)
                        Text("Converted Time:")
                            .foregroundColor(.secondary)
                        Text(convertedTime.formatted(date: .complete, time: .complete))
                            .bold()
                    }
                    
                    if jetLagHours > 0 {
                        HStack {
                            Image(systemName: "bed.double")
                                .foregroundColor(.orange)
                            Text("Time Difference:")
                                .foregroundColor(.secondary)
                            Text("\(jetLagHours) hours")
                                .bold()
                        }
                    }
                }
            } header: {
                Label("Result", systemImage: "checkmark.circle")
            }
        }
        .navigationTitle("Time Zone Converter")
        .sheet(isPresented: $showingTimeZonePicker) {
            TimeZonePickerView(
                selection: isSelectingSource ? $sourceTimeZone : $targetTimeZone,
                timeZones: timeZoneService.timeZones,
                formatTimeZone: timeZoneService.formatTimeZone
            )
        }
    }
    
    private func selectTimeZone(isSource: Bool) {
        isSelectingSource = isSource
        showingTimeZonePicker = true
    }
}

struct TimeZoneRow: View {
    let title: String
    let timeZone: TimeZone
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.primary)
                    Text(TimeZoneService.shared.formatTimeZone(timeZone))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
}

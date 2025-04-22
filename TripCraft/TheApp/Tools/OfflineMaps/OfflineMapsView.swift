//
//  OfflineMapsView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 10/03/2025.
//

import SwiftUI

struct OfflineMapsView: View {
    @State private var searchText = ""
    private let maps: [OfflineMap] = OfflineMapService.shared.availableMaps
    
    var filteredMaps: [OfflineMap] {
        if searchText.isEmpty {
            return maps
        }
        return maps.filter {
            $0.cityName.localizedCaseInsensitiveContains(searchText) ||
            $0.country.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredMaps) { map in
                NavigationLink(destination: OfflineMapDetailView(map: map)) {
                    OfflineMapRow(map: map)
                }
            }
        }
        .navigationTitle("City Maps")
        .searchable(text: $searchText, prompt: "Search cities")
    }
}

struct OfflineMapRow: View {
    let map: OfflineMap
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(map.cityName)
                .font(.headline)
            Text("\(map.country) • \(map.region)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

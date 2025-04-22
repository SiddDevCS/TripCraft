//
//  LocationPicker.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import SwiftUI
import MapKit

struct LocationPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var location: Location?
    
    @StateObject private var viewModel = LocationPickerViewModel()
    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3361, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search location", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchText) { newValue in
                        viewModel.searchLocations(query: newValue)
                    }
                
                if !viewModel.searchResults.isEmpty {
                    // Search results
                    List(viewModel.searchResults, id: \.self) { result in
                        Button {
                            selectLocation(result)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(result.title)
                                    .foregroundColor(.primary)
                                Text(result.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else {
                    // Map
                    Map(coordinateRegion: $region, showsUserLocation: true)
                        .edgesIgnoringSafeArea(.bottom)
                }
            }
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func selectLocation(_ result: MKLocalSearchCompletion) {
        Task {
            if let location = await viewModel.getLocation(from: result) {
                self.location = Location(
                    name: result.title,
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                dismiss()
            }
        }
    }
}

class LocationPickerViewModel: NSObject, ObservableObject {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    private var searchCompleter = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .pointOfInterest
    }
    
    func searchLocations(query: String) {
        searchCompleter.queryFragment = query
    }
    
    func getLocation(from result: MKLocalSearchCompletion) async -> CLLocationCoordinate2D? {
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            return response.mapItems.first?.placemark.coordinate
        } catch {
            print("Error getting location: \(error)")
            return nil
        }
    }
}

extension LocationPickerViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error getting search results: \(error)")
    }
}

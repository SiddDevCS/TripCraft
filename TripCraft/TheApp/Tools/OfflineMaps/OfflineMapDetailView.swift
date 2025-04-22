//
//  OfflineMapDetailView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 10/03/2025.
//

import SwiftUI
import MapKit

struct OfflineMapDetailView: View {
    let map: OfflineMap
    @State private var region: MKCoordinateRegion
    @State private var mapType: MKMapType = .standard
    
    init(map: OfflineMap) {
        self.map = map
        _region = State(initialValue: MKCoordinateRegion(
            center: map.coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Map Type Picker
            Picker("Map Type", selection: $mapType) {
                Text("Standard").tag(MKMapType.standard)
                Text("Satellite").tag(MKMapType.satellite)
                Text("Hybrid").tag(MKMapType.hybrid)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Map View
            Map(coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: nil,
                annotationItems: [map]) { location in
                MapMarker(coordinate: location.coordinates,
                         tint: .red)
            }
            .mapStyle(mapType == .standard ? .standard :
                     mapType == .satellite ? .imagery : .hybrid)
            
            // Info Panel
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(map.cityName)
                            .font(.title2)
                            .bold()
                        Text(map.country)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                // Location Info
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.red)
                    Text("Lat: \(String(format: "%.4f", map.coordinates.latitude))")
                    Text("Long: \(String(format: "%.4f", map.coordinates.longitude))")
                        .foregroundColor(.secondary)
                }
                
                // Zoom Controls
                HStack(spacing: 20) {
                    Button(action: zoomIn) {
                        Image(systemName: "plus.magnifyingglass")
                            .font(.title2)
                    }
                    Button(action: zoomOut) {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.title2)
                    }
                    Button(action: resetZoom) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                    }
                }
                .padding(.top)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("Map View")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func zoomIn() {
        withAnimation {
            region.span.latitudeDelta *= 0.5
            region.span.longitudeDelta *= 0.5
        }
    }
    
    private func zoomOut() {
        withAnimation {
            region.span.latitudeDelta *= 2
            region.span.longitudeDelta *= 2
        }
    }
    
    private func resetZoom() {
        withAnimation {
            region = MKCoordinateRegion(
                center: map.coordinates,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
}

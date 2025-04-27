//
//  OfflineMapService.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 10/03/2025.
//

import Foundation
import CoreLocation

class OfflineMapService {
    static let shared = OfflineMapService()
    let availableMaps: [OfflineMap]
    
    init() {
        self.availableMaps = [
            // Europe
            OfflineMap(
                cityName: "Paris",
                country: "France",
                region: "Europe",
                coordinates: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
            ),
            OfflineMap(
                cityName: "London",
                country: "United Kingdom",
                region: "Europe",
                coordinates: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
            ),
            OfflineMap(
                cityName: "Rome",
                country: "Italy",
                region: "Europe",
                coordinates: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964)
            ),
            OfflineMap(
                cityName: "Barcelona",
                country: "Spain",
                region: "Europe",
                coordinates: CLLocationCoordinate2D(latitude: 41.3851, longitude: 2.1734)
            ),
            OfflineMap(
                cityName: "Amsterdam",
                country: "Netherlands",
                region: "Europe",
                coordinates: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041)
            ),

            // Asia
            OfflineMap(
                cityName: "Tokyo",
                country: "Japan",
                region: "Asia",
                coordinates: CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503)
            ),
            OfflineMap(
                cityName: "Singapore",
                country: "Singapore",
                region: "Asia",
                coordinates: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
            ),
            OfflineMap(
                cityName: "Bangkok",
                country: "Thailand",
                region: "Asia",
                coordinates: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018)
            ),
            OfflineMap(
                cityName: "Seoul",
                country: "South Korea",
                region: "Asia",
                coordinates: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
            ),
            OfflineMap(
                cityName: "Hong Kong",
                country: "China",
                region: "Asia",
                coordinates: CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694)
            ),

            // North America
            OfflineMap(
                cityName: "New York City",
                country: "United States",
                region: "North America",
                coordinates: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
            ),
            OfflineMap(
                cityName: "San Francisco",
                country: "United States",
                region: "North America",
                coordinates: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            ),
            OfflineMap(
                cityName: "Vancouver",
                country: "Canada",
                region: "North America",
                coordinates: CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207)
            ),
            OfflineMap(
                cityName: "Mexico City",
                country: "Mexico",
                region: "North America",
                coordinates: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)
            ),

            // South America
            OfflineMap(
                cityName: "Rio de Janeiro",
                country: "Brazil",
                region: "South America",
                coordinates: CLLocationCoordinate2D(latitude: -22.9068, longitude: -43.1729)
            ),
            OfflineMap(
                cityName: "Buenos Aires",
                country: "Argentina",
                region: "South America",
                coordinates: CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816)
            ),

            // Oceania
            OfflineMap(
                cityName: "Sydney",
                country: "Australia",
                region: "Oceania",
                coordinates: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)
            ),
            OfflineMap(
                cityName: "Melbourne",
                country: "Australia",
                region: "Oceania",
                coordinates: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631)
            ),
            OfflineMap(
                cityName: "Auckland",
                country: "New Zealand",
                region: "Oceania",
                coordinates: CLLocationCoordinate2D(latitude: -36.8509, longitude: 174.7645)
            ),

            // Middle East
            OfflineMap(
                cityName: "Dubai",
                country: "United Arab Emirates",
                region: "Middle East",
                coordinates: CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708)
            ),
            OfflineMap(
                cityName: "Istanbul",
                country: "Turkey",
                region: "Middle East",
                coordinates: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
            ),

            // Africa
            OfflineMap(
                cityName: "Cape Town",
                country: "South Africa",
                region: "Africa",
                coordinates: CLLocationCoordinate2D(latitude: -33.9249, longitude: 18.4241)
            ),
            OfflineMap(
                cityName: "Cairo",
                country: "Egypt",
                region: "Africa",
                coordinates: CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357)
            ),
            OfflineMap(
                cityName: "Marrakech",
                country: "Morocco",
                region: "Africa",
                coordinates: CLLocationCoordinate2D(latitude: 31.6295, longitude: -7.9811)
            )
        ].sorted { $0.cityName < $1.cityName }
    }
}

struct OfflineMap: Identifiable {
    let id = UUID()
    let cityName: String
    let country: String
    let region: String
    let coordinates: CLLocationCoordinate2D
}

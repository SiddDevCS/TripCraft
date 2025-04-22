//
//  PlugCompatabilityView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 03/03/2025.
//

import SwiftUI

struct PlugCompatibilityView: View {
    @State private var selectedCountry: PlugInfo?
    @State private var searchText = ""
    
    var filteredCountries: [PlugInfo] {
        if searchText.isEmpty {
            return PlugInfo.allCountries
        }
        return PlugInfo.allCountries.filter { country in
            country.country.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search countries", text: $searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Default Info Card when no country is selected
                if selectedCountry == nil {
                    VStack(spacing: 16) {
                        Image(systemName: "globe")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Select a Country")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Choose a country to view its power specifications and plug compatibility information")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Country Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(filteredCountries) { country in
                        CountryCard(
                            country: country,
                            isSelected: selectedCountry?.id == country.id,
                            action: {
                                withAnimation {
                                    selectedCountry = country
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Selected Country Details
                if let country = selectedCountry {
                    VStack(spacing: 20) {
                        // Power Specifications Card
                        VStack(spacing: 16) {
                            Text("Power Specifications")
                                .font(.headline)
                            
                            HStack(spacing: 30) {
                                VoltageView(voltage: country.voltage)
                                FrequencyView(frequency: country.frequency)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Plug Types Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Compatible Plug Types")
                                .font(.headline)
                            
                            ForEach(country.plugTypes, id: \.self) { plugType in
                                PlugTypeRow(type: plugType)
                                if plugType != country.plugTypes.last {
                                    Divider()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Additional Info Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Additional Information")
                                .font(.headline)
                            Text(country.additionalInfo)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Plug Compatibility")
    }
}

struct VoltageView: View {
    let voltage: String
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
                Text(voltage)
                    .font(.headline)
            }
            Text("Voltage")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct FrequencyView: View {
    let frequency: String
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Image(systemName: "waveform")
                    .foregroundColor(.blue)
                Text(frequency)
                    .font(.headline)
            }
            Text("Frequency")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct PlugTypeRow: View {
    let type: PlugType
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(type.rawValue)
                    .font(.headline)
                Text(type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "powerplug.fill")
                .foregroundColor(.blue)
                .font(.title2)
        }
        .padding(.vertical, 4)
    }
}

struct CountryCard: View {
    let country: PlugInfo
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(country.flag)
                    .font(.system(size: 40))
                Text(country.country)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

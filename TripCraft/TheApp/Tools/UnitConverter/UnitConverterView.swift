//
//  UnitConverterView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 25/03/2025.
//

import SwiftUI

struct UnitConverterView: View {
    @State private var selectedUnitType = 0
    @State private var inputValue = ""
    @State private var inputUnit = 0
    @State private var outputUnit = 1
    
    private let unitTypes = ["Length", "Weight", "Temperature"]
    
    private let lengthUnits = ["Kilometers", "Miles", "Meters", "Feet"]
    private let weightUnits = ["Kilograms", "Pounds", "Grams", "Ounces"]
    private let temperatureUnits = ["Celsius", "Fahrenheit"]
    
    private var currentUnits: [String] {
        switch selectedUnitType {
        case 0: return lengthUnits
        case 1: return weightUnits
        case 2: return temperatureUnits
        default: return []
        }
    }
    
    private var result: String {
        guard let value = Double(inputValue) else { return "Enter a value" }
        
        switch selectedUnitType {
        case 0: // Length
            return convertLength(value)
        case 1: // Weight
            return convertWeight(value)
        case 2: // Temperature
            return convertTemperature(value)
        default:
            return "Error"
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Unit Type")) {
                Picker("Unit Type", selection: $selectedUnitType) {
                    ForEach(0..<unitTypes.count, id: \.self) { index in
                        Text(unitTypes[index])
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section(header: Text("Input")) {
                TextField("Value", text: $inputValue)
                    .keyboardType(.decimalPad)
                
                Picker("From Unit", selection: $inputUnit) {
                    ForEach(0..<currentUnits.count, id: \.self) { index in
                        Text(currentUnits[index])
                    }
                }
            }
            
            Section(header: Text("Output")) {
                Picker("To Unit", selection: $outputUnit) {
                    ForEach(0..<currentUnits.count, id: \.self) { index in
                        Text(currentUnits[index])
                    }
                }
                
                HStack {
                    Text("Result:")
                    Spacer()
                    Text(result)
                        .bold()
                }
            }
        }
        .navigationTitle("Unit Converter")
        .onChange(of: selectedUnitType) { _ in
            inputUnit = 0
            outputUnit = 1
        }
    }
    
    private func convertLength(_ value: Double) -> String {
        let baseUnits = [1000.0, 1609.34, 1.0, 0.3048] // All converted to meters
        
        // Convert to base unit (meters)
        let meters = value * baseUnits[inputUnit]
        
        // Convert to target unit
        let result = meters / baseUnits[outputUnit]
        
        return String(format: "%.2f %@", result, currentUnits[outputUnit])
    }
    
    private func convertWeight(_ value: Double) -> String {
        let baseUnits = [1000.0, 453.592, 1.0, 28.3495] // All converted to grams
        
        // Convert to base unit (grams)
        let grams = value * baseUnits[inputUnit]
        
        // Convert to target unit
        let result = grams / baseUnits[outputUnit]
        
        return String(format: "%.2f %@", result, currentUnits[outputUnit])
    }
    
    private func convertTemperature(_ value: Double) -> String {
        if inputUnit == outputUnit {
            return String(format: "%.1f %@", value, currentUnits[outputUnit])
        }
        
        let result: Double
        if inputUnit == 0 { // Celsius to Fahrenheit
            result = (value * 9/5) + 32
        } else { // Fahrenheit to Celsius
            result = (value - 32) * 5/9
        }
        
        return String(format: "%.1f %@", result, currentUnits[outputUnit])
    }
}

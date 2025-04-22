//
//  TipCalculatorView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 10/03/2025.
//

import SwiftUI

struct TipCalculatorView: View {
    @State private var billAmount = ""
    @State private var tipPercentage = 15.0
    @State private var numberOfPeople = 2
    @State private var currency = "$"
    
    let tipPercentages = [10.0, 15.0, 18.0, 20.0, 25.0]
    let currencies = ["$", "€", "£", "¥"]
    
    var tipAmount: Double {
        guard let bill = Double(billAmount) else { return 0 }
        return bill * tipPercentage / 100
    }
    
    var totalAmount: Double {
        guard let bill = Double(billAmount) else { return 0 }
        return bill + tipAmount
    }
    
    var amountPerPerson: Double {
        totalAmount / Double(numberOfPeople)
    }
    
    var body: some View {
        Form {
            Section("Bill Amount") {
                HStack {
                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100)
                    
                    TextField("Amount", text: $billAmount)
                        .keyboardType(.decimalPad)
                }
            }
            
            Section("Tip Percentage") {
                Picker("Tip Percentage", selection: $tipPercentage) {
                    ForEach(tipPercentages, id: \.self) {
                        Text("\(Int($0))%")
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Number of People") {
                Stepper("People: \(numberOfPeople)", value: $numberOfPeople, in: 1...50)
            }
            
            Section("Summary") {
                HStack {
                    Text("Tip Amount")
                    Spacer()
                    Text("\(currency)\(tipAmount, specifier: "%.2f")")
                        .bold()
                }
                
                HStack {
                    Text("Total")
                    Spacer()
                    Text("\(currency)\(totalAmount, specifier: "%.2f")")
                        .bold()
                }
                
                HStack {
                    Text("Per Person")
                    Spacer()
                    Text("\(currency)\(amountPerPerson, specifier: "%.2f")")
                        .bold()
                }
            }
        }
        .navigationTitle("Tip Calculator")
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                     to: nil,
                                     from: nil,
                                     for: nil)
    }
}

//
//  CurrencyPickerView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 08/03/2025.
//

import SwiftUI

struct CurrencyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency: Currency
    let excludedCurrency: Currency
    @State private var searchText = ""
    
    var filteredCurrencies: [Currency] {
        let currencies = Currency.all.filter { $0 != excludedCurrency }
        if searchText.isEmpty {
            return currencies
        }
        return currencies.filter { currency in
            currency.name.localizedCaseInsensitiveContains(searchText) ||
            currency.code.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredCurrencies) { currency in
                    Button(action: {
                        selectedCurrency = currency
                        dismiss()
                    }) {
                        HStack {
                            Text(currency.flag)
                            
                            VStack(alignment: .leading) {
                                Text(currency.code)
                                    .font(.headline)
                                Text(currency.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if currency == selectedCurrency {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Currency")
            .searchable(text: $searchText, prompt: "Search currencies")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

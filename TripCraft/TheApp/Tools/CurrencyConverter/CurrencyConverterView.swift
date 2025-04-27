//
//  CurrencyConverterView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 03/03/2025.
//

import SwiftUI

struct CurrencyConverterView: View {
    @StateObject private var currencyService = CurrencyService()
    @State private var amount = ""
    @State private var fromCurrency = Currency.all[0]
    @State private var toCurrency = Currency.all[1]
    @State private var showingCurrencyPicker = false
    @State private var isSelectingFromCurrency = true
    @FocusState private var isAmountFocused: Bool
    
    var convertedAmount: Double? {
        guard let amount = Double(amount),
              let rate = currencyService.rates[toCurrency.code] else {
            return nil
        }
        return amount * rate
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Disclaimer
                Text("Note: Using estimated exchange rates for demonstration purposes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Amount Input Card
                AmountInputCard(
                    amount: $amount,
                    currency: fromCurrency,
                    isFocused: _isAmountFocused
                )
                
                // Exchange Rate Display
                ExchangeRateView(
                    fromCurrency: fromCurrency,
                    toCurrency: toCurrency,
                    rate: currencyService.rates[toCurrency.code] ?? 0
                )
                
                // Currency Selection Cards
                HStack(spacing: 16) {
                    CurrencyCard(
                        currency: fromCurrency,
                        isSource: true,
                        action: {
                            isSelectingFromCurrency = true
                            showingCurrencyPicker = true
                        }
                    )
                    
                    // Swap Button
                    Button(action: swapCurrencies) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    
                    CurrencyCard(
                        currency: toCurrency,
                        isSource: false,
                        action: {
                            isSelectingFromCurrency = false
                            showingCurrencyPicker = true
                        }
                    )
                }
                
                if let converted = convertedAmount {
                                    VStack(spacing: 16) {
                                        ResultCard(
                                            amount: converted,
                                            currency: toCurrency
                                        )
                                        
                                        // Disclaimer about estimates
                                        Text("Note: These conversion rates are estimates and may not reflect current market values")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal)
                                    }
                                }
            }
            .padding()
        }
        .navigationTitle("Currency Converter")
        .sheet(isPresented: $showingCurrencyPicker) {
            CurrencyPickerView(
                selectedCurrency: isSelectingFromCurrency ? $fromCurrency : $toCurrency,
                excludedCurrency: isSelectingFromCurrency ? toCurrency : fromCurrency
            )
        }
        .task {
            await currencyService.fetchLatestRates(base: fromCurrency.code)
        }
        .onChange(of: fromCurrency) { oldValue, newValue in
            Task {
                await currencyService.fetchLatestRates(base: newValue.code)
            }
        }
    }
    
    private func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
        
        Task {
            await currencyService.fetchLatestRates(base: fromCurrency.code)
        }
    }
}

// MARK: - Supporting Views
struct AmountInputCard: View {
    @Binding var amount: String
    let currency: Currency
    @FocusState var isFocused: Bool
    
    var body: some View {
        HStack {
            Text(currency.symbol)
                .font(.title2)
                .foregroundColor(.secondary)
            
            TextField("0.00", text: $amount)
                .font(.title2)
                .keyboardType(.decimalPad)
                .focused($isFocused)
            
            if !amount.isEmpty {
                Button(action: { amount = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CurrencyCard: View {
    let currency: Currency
    let isSource: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(isSource ? "From" : "To")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(currency.flag)
                    Text(currency.code)
                        .font(.headline)
                }
                
                Text(currency.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct ResultCard: View {
    let amount: Double
    let currency: Currency
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Converted Amount")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(currency.symbol)\(amount.formatted(.currency(code: currency.code)))")
                .font(.title)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ExchangeRateView: View {
    let fromCurrency: Currency
    let toCurrency: Currency
    let rate: Double
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Estimated Exchange Rate")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("1 \(fromCurrency.code) ≈ \(rate.formatted(.currency(code: toCurrency.code))) \(toCurrency.code)")
                .font(.subheadline)
        }
    }
}

//
//  AddItemView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 06/03/2025.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PackingListViewModel
    
    @State private var itemName = ""
    @State private var selectedCategory = PackingCategory.clothing.rawValue
    @State private var quantity = 1
    @State private var notes = ""
    @State private var priority = Priority.medium
    @State private var weight: Double?
    @State private var price: Double?
    @State private var isPurchased = false
    @State private var showingCustomCategory = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Essential Details")) {
                    TextField("Item Name", text: $itemName)
                        .required()
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(PackingCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category.rawValue)
                        }
                        ForEach(viewModel.customCategories) { category in
                            Text(category.name).tag(category.name)
                        }
                    }
                    
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                }
                
                Section(header: Text("Additional Details")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    Toggle("Already Purchased", isOn: $isPurchased)
                    
                    TextField("Weight (optional)", value: $weight, format: .number)
                        .keyboardType(.decimalPad)
                    
                    TextField("Price (optional)", value: $price, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Create Custom Category") {
                        showingCustomCategory = true
                    }
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveItem() }
                        .disabled(itemName.isEmpty)
                }
            }
            .sheet(isPresented: $showingCustomCategory) {
                AddCategoryView(viewModel: viewModel)
            }
        }
    }
    
    private func saveItem() {
        let details = PackingItemDetails(
            quantity: quantity,
            notes: notes.isEmpty ? nil : notes,
            priority: priority,
            weight: weight,
            price: price,
            purchased: isPurchased
        )
        
        let newItem = PackingItem(
            id: UUID(),
            name: itemName,
            category: selectedCategory,
            isPacked: false,
            details: details,
            isAIGenerated: false
        )
        
        viewModel.addItems([newItem])
        dismiss()
    }
}

// MARK: - Add Category View
struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PackingListViewModel
    @State private var categoryName = ""
    @State private var selectedIcon = "tag"
    @State private var selectedColor = Color.blue
    
    let icons = ["tag", "bag", "tshirt", "camera", "pills", "doc.text",
                 "creditcard", "toiletries", "shoes", "umbrella", "sunglasses"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $categoryName)
                    ColorPicker("Category Color", selection: $selectedColor)
                }
                
                Section(header: Text("Select Icon")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                                .cornerRadius(10)
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("New Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addCustomCategory(
                            name: categoryName,
                            icon: selectedIcon,
                            color: selectedColor.toHex() ?? "#007AFF"
                        )
                        dismiss()
                    }
                    .disabled(categoryName.isEmpty)
                }
            }
        }
    }
}

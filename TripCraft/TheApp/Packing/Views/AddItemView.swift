import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PackingListViewModel
    let tripId: UUID?
    
    @State private var itemName = ""
    @State private var category = PackingCategory.clothing
    @State private var quantity = 1
    @State private var priority = PackingItemDetails.Priority.medium
    @State private var notes = ""
    @State private var isPurchased = true
    @State private var showError = false
    @FocusState private var isItemNameFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name", text: $itemName)
                        .focused($isItemNameFocused)
                    
                    Picker("Category", selection: $category) {
                        ForEach(PackingCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .foregroundColor(category.color)
                                .tag(category)
                        }
                    }
                    
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(PackingItemDetails.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue)
                                .foregroundColor(priority.color)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Already Purchased", isOn: $isPurchased)
                }
                
                Section(header: Text("Additional Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Item Name Required", isPresented: $showError) {
                Button("OK") {
                    isItemNameFocused = true
                }
            } message: {
                Text("Please enter a name for your packing item.")
            }
            .onAppear {
                // Focus the name field when the view appears
                isItemNameFocused = true
            }
        }
    }
    
    private func saveItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            showError = true
            return
        }
        
        let newItem = PackingItem(
            id: UUID(),
            name: trimmedName,
            category: category.rawValue,
            isPacked: false,
            details: PackingItemDetails(
                quantity: quantity,
                priority: priority,
                purchased: isPurchased,
                notes: notes.isEmpty ? nil : notes
            ),
            isAIGenerated: false,
            tripId: tripId
        )
        
        viewModel.addItems([newItem])
        dismiss()
    }
} 
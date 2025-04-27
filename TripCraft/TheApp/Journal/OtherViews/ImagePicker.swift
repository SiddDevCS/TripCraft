//
//  ImagePicker.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var imageNames: [String]
    let viewModel: JournalViewModel
    
    // App theme color
    private let themeColor = Color.blue.opacity(0.8)
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            VStack {
                PhotosPicker(
                    selection: $selectedItems,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Select Photos", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [themeColor, themeColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                
                if !selectedItems.isEmpty {
                    ProgressView("Processing images...")
                }
            }
            .navigationTitle("Add Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { 
                        dismiss() 
                    }
                    .foregroundColor(themeColor)
                    .fontWeight(.semibold)
                }
            }
        }
        .onChange(of: selectedItems) { oldItems, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data),
                       let fileName = viewModel.saveImage(image) {
                        imageNames.append(fileName)
                    }
                }
                selectedItems.removeAll()
            }
        }
    }
}

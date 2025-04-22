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
                        .background(Color.blue)
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
                    Button("Done") { dismiss() }
                }
            }
        }
        .onChange(of: selectedItems) { items in
            Task {
                for item in items {
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

struct PhotosGridView: View {
    let imageNames: [String]
    let viewModel: JournalViewModel
    let onDelete: (String) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(imageNames, id: \.self) { imageName in
                if let image = viewModel.loadImage(named: imageName) {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button {
                            onDelete(imageName)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(4)
                    }
                }
            }
        }
    }
}

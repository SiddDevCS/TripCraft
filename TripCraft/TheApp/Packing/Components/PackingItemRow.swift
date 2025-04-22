//
//  PackingItemRow.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 06/03/2025.
//

import SwiftUI

struct PackingItemRow: View {
    let item: PackingItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(.blue)
                .onTapGesture(perform: onToggle)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .strikethrough(item.isPacked)
                
                if item.details.quantity > 1 {
                    Text("Qty: \(item.details.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

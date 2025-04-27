import SwiftUI
import Foundation

struct SelectableItemRow: View {
    let item: PackingItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(.blue)
                .font(.system(size: 22))
                .frame(width: 30, height: 30)
            
            // Item details with fixed layout
            VStack(alignment: .leading, spacing: 4) {
                // Item name with truncation
                Text(item.name)
                    .strikethrough(item.isPacked)
                    .foregroundStyle(item.isPacked ? .secondary : .primary)
                    .lineLimit(1)
                
                // Quantity info if needed
                if item.details.quantity > 1 {
                    Text("Qty: \(item.details.quantity)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .padding(.vertical, 4)
    }
} 
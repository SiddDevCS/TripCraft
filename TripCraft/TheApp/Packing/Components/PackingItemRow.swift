import SwiftUI

struct PackingItemRow: View {
    let item: PackingItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox button
            Button(action: onToggle) {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isPacked ? .blue : .gray)
                    .font(.system(size: 22))
                    .frame(width: 30, height: 30)
                    .animation(.spring(), value: item.isPacked)
            }
            
            // Item details with fixed layout
            VStack(alignment: .leading, spacing: 4) {
                // Item name with truncation
                Text(item.name)
                    .font(.body)
                    .foregroundStyle(item.isPacked ? .secondary : .primary)
                    .strikethrough(item.isPacked)
                    .lineLimit(1)
                
                // Optional notes with truncation
                if let notes = item.details.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                // Tags in a horizontal scroll if needed
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if item.details.quantity > 1 {
                            HStack(spacing: 2) {
                                Image(systemName: "number")
                                    .font(.caption2)
                                Text("Qty: \(item.details.quantity)")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 2) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.caption2)
                            Text(item.details.priority.rawValue)
                                .font(.caption)
                        }
                        .foregroundStyle(item.details.priority.color)
                        
                        if item.isAIGenerated {
                            HStack(spacing: 2) {
                                Image(systemName: "wand.and.stars")
                                    .font(.caption2)
                                Text("AI")
                                    .font(.caption)
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Cart indicator as fixed width
            if !item.details.purchased {
                Image(systemName: "cart")
                    .foregroundStyle(.orange)
                    .font(.caption)
                    .frame(width: 20)
            } else {
                Spacer()
                    .frame(width: 20)
            }
        }
        .contentShape(Rectangle())
    }
} 
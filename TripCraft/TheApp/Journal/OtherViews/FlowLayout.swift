//
//  FlowLayout.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        return CGSize(
            width: proposal.width ?? 0,
            height: rows.last?.maxY ?? 0
        )
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        
        for (index, subview) in subviews.enumerated() {
            for row in rows {
                if index < row.frames.count {
                    let frame = row.frames[index]
                    subview.place(
                        at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                        proposal: ProposedViewSize(frame.size)
                    )
                    break
                }
            }
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var currentRow = Row()
        var x: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > (proposal.width ?? 0) && !currentRow.frames.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
                x = 0
            }
            
            let y = rows.count > 0 ? rows.last!.maxY + spacing : 0
            currentRow.frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            x += size.width + spacing
        }
        
        if !currentRow.frames.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
}

struct Row {
    var frames: [CGRect] = []
    var maxY: CGFloat {
        frames.map(\.maxY).max() ?? 0
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyleFlowLayout: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

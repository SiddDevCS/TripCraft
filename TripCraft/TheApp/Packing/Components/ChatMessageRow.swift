//
//  ChatMessageRow.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 06/03/2025.
//

import SwiftUI

struct ChatMessageRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromAI {
                Image(systemName: "wand.and.stars")
                    .foregroundColor(.blue)
            }
            
            Text(message.content)
                .padding()
                .background(message.isFromAI ? Color(.systemGray6) : Color.blue)
                .foregroundColor(message.isFromAI ? .primary : .white)
                .cornerRadius(10)
            
            if !message.isFromAI {
                Spacer()
            }
        }
    }
}

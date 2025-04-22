//
//  RequiredFieldModifier.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import SwiftUI

struct RequiredField: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Text("*")
                .foregroundColor(.red)
                .font(.caption)
        }
    }
}

extension View {
    func required() -> some View {
        modifier(RequiredField())
    }
}

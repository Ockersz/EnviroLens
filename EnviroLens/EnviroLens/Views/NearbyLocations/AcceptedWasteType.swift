//
//  AcceptedWasteType.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-13.
//

import SwiftUI

struct AcceptedWasteType: View {
    let type: String
    let color: Color
    
    var body: some View {
        Text(type.replacingOccurrences(of: "-", with: " ").capitalized)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

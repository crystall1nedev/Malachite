//
//  View.swift
//  mlchtCamera
//
//  Created by Eva Isabella Luna on 3/12/26.
//

import SwiftUI

/// Common cell content view to prevent the code from becoming massive
struct CellViewUtils<Content : View>: View {
    var icon: String
    var disabled: Bool
    var dangerous: Bool
    let content: Content
    
    init(
        icon: String,
        disabled: Bool?,
        dangerous: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.disabled = disabled ?? false
        self.dangerous = dangerous
        self.content = content()
    }
    
    var body: some View {
        VStack() {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .frame(maxWidth: 20)
                    .foregroundStyle(dangerous ? .red : Color.accentColor)
                    .symbolRenderingMode(.hierarchical)
                content
                    .disabled(disabled)
            }
        }
    }
}

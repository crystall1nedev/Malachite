//
//  Content+Debug.swift
//  mlchtCamera
//
//  Created by Eva Isabella Luna on 3/12/26.
//

import SwiftUI

extension Content {
    struct Debug: View {
        @Binding var isPresented: Bool
        
        var body: some View {
            CellViewUtils(
                icon: "wrench.and.screwdriver",
                disabled: nil,
                dangerous: false)
            {
                Button("DEBUG") {
                    isPresented.toggle()
                }
            }
        }
    }
}

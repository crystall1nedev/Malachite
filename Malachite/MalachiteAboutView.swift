//
//  MalachiteAboutView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/26/23.
//

import SwiftUI

struct MalachiteAboutView: View {
    var body: some View {
        VStack {
            Text("Malachite")
                .font(.largeTitle)
                .bold()
            Image("AppIcon")
                .imageScale(.large)
            Text("Making macro magnifying magical.")
            Text("")
            Text("Designed by Eva with ❤️ in 2023")
                .bold()
        }
        .padding()
    }
}

#Preview {
    MalachiteAboutView()
}

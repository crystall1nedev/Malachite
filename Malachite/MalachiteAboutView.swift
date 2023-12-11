//
//  MalachiteAboutView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/26/23.
//

import SwiftUI

struct MalachiteAboutView: View {
    let currentVersion = MalachiteVersion()
    
    var body: some View {
        VStack {
            Text("Malachite")
                .font(.largeTitle)
                .bold()
            Image("AppIcon")
                .imageScale(.large)
            Text("Bringing camera control back to you.")
            Text("")
            Text("Designed by Eva with ❤️ in 2023")
                .bold()
            Text("")
            if currentVersion.versionBeta {
                Text("v\(currentVersion.versionMajor).\(currentVersion.versionMinor).\(currentVersion.versionMinor) beta")
                    .font(.footnote)
            } else {
                Text("v\(currentVersion.versionMajor).\(currentVersion.versionMinor).\(currentVersion.versionMinor)")
                    .font(.footnote)
            }
        }
        .padding()
    }
}

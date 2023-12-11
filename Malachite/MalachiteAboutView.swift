//
//  MalachiteAboutView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/26/23.
//

import SwiftUI

struct MalachiteAboutView: View {
    let currentVersion = MalachiteClassesObject().versions
    
    var body: some View {
        VStack {
            Text("Malachite")
                .font(.largeTitle)
                .bold()
            if currentVersion.versionBeta {
                Text("v\(currentVersion.versionMajor).\(currentVersion.versionMinor).\(currentVersion.versionMinor) beta")
                    .font(.footnote)
            } else {
                Text("v\(currentVersion.versionMajor).\(currentVersion.versionMinor).\(currentVersion.versionMinor)")
                    .font(.footnote)
            }
            Text("")
            Image("AppIcon")
                .imageScale(.large)
            Text("Bringing camera control back to you.")
            Text("")
            Text("Designed by Eva with ❤️ in 2023")
                .bold()
            Text("")
        }
        .padding()
    }
}

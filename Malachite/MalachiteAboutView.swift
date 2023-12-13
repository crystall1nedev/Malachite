//
//  MalachiteAboutView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/26/23.
//

import SwiftUI

struct MalachiteAboutAndSettingsView: View {
    @State private var watermarkSwitch = false
    @State private var watermarkText = String()
    
    let utilities = MalachiteClassesObject()
    
    var body: some View {
        
        Form {
            Section {
                HStack {
                    VStack {
                        HStack {
                            Text("Malachite")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }
                        HStack {
                            if utilities.versions.versionBeta {
                                Text("v\(utilities.versions.versionMajor).\(utilities.versions.versionMinor).\(utilities.versions.versionMinor) beta")
                                    .font(.footnote)
                                    .frame(alignment: .leading)
                            } else {
                                Text("v\(utilities.versions.versionMajor).\(utilities.versions.versionMinor).\(utilities.versions.versionMinor)")
                                    .font(.footnote)
                                    .frame(alignment: .leading)
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                    Image("icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 80, alignment: .trailing)
                        .clipShape(RoundedRectangle(cornerRadius: 17))
                }
                Text("Bringing camera control back to you.")
                Text("Designed by Eva with ❤️ in 2023")
                    .bold()
            }
            Section(header: Text("Watermark settings for captured images"), footer: Text("A fun little feature, you can enable a watermark on your images when you take them. It helps me get some recognition, and enables you to flex your cameras on others! Completely optional, totally up to you.")) {
                Toggle("Enable watermark", isOn: $watermarkSwitch)
                HStack {
                    Text("Watermark text")
                    Spacer()
                    TextField("Shot with Malachite", text: $watermarkText)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .onAppear() {
            watermarkSwitch = utilities.settings.defaults.bool(forKey: "enableWatermark")
            watermarkText = utilities.settings.defaults.string(forKey: "textForWatermark")!
        }
        .onDisappear() {
            utilities.settings.defaults.set(watermarkSwitch, forKey: "enableWatermark")
            utilities.settings.defaults.set(watermarkText, forKey: "textForWatermark")
        }
        .onChange(of: watermarkSwitch) {_ in
            utilities.settings.defaults.set(watermarkSwitch, forKey: "enableWatermark")
        }
        .onChange(of: watermarkText) {_ in
            if !watermarkText.isEmpty {
                utilities.settings.defaults.set(watermarkText, forKey: "textForWatermark")
            } else {
                utilities.settings.defaults.set("Shot with Malachite", forKey: "textForWatermark")
            }
        }
    }
}

#Preview {
    MalachiteAboutAndSettingsView()
}

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
    @State private var photoFormat = Int()
    @State private var hdrSwitch = false
    @State private var supportsHDR = Bool()
    @State private var supportsHEIC = Bool()
    @State private var supportsHEIC10Bit = Bool()
    @State private var formatFooterText = "This device isn't capable of encoding images in HEIF or HEIF 10-bit."
    
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
            Section(header: Text("Photo settings"), footer: Text(formatFooterText)) {
                Picker("Image file format", selection: $photoFormat) {
                    Text("JPEG")
                        .tag(0)
                    Text("HEIF")
                        .tag(1)
                    if supportsHEIC10Bit {
                        Text("HEIF 10-bit")
                            .tag(2)
                    }
                }
                .disabled(!supportsHEIC)
                .pickerStyle(.segmented)
                Toggle("Enable HDR", isOn: $hdrSwitch)
                    .disabled(!supportsHDR)
            }
            Section(header: Text("Watermark settings"), footer: Text("A fun little feature, you can enable a watermark on your images when you take them.")) {
                Toggle("Enable watermark", isOn: $watermarkSwitch)
                HStack {
                    Text("Watermark text")
                    Spacer()
                    TextField("Shot with Malachite", text: $watermarkText)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                }
            }
        }
        .onAppear() {
            watermarkSwitch = utilities.settings.defaults.bool(forKey: "enableWatermark")
            hdrSwitch = utilities.settings.defaults.bool(forKey: "shouldEnableHDR")
            watermarkText = utilities.settings.defaults.string(forKey: "textForWatermark")!
            
            supportsHDR = utilities.function.supportsHDR()
            supportsHEIC = utilities.function.supportsHEIC()
            supportsHEIC10Bit = utilities.function.supportsHEIC10()
            
            if supportsHEIC {
                formatFooterText = "JPEG - Better compatibility with non-Apple platforms\nHEIC - Better file size while retaining quality\nUpdate to iOS 15 or later to support HEIC 10-bit."
            }
            
            if supportsHEIC10Bit {
                formatFooterText = "JPEG - Better compatibility with non-Apple platforms\nHEIC - Better file size while retaining quality\nHEIF 10-bit - Best quality and color accuracy"
            }
            
            if !utilities.settings.defaults.bool(forKey: "shouldUseHEIF") {
                photoFormat = 0
            } else {
                if !utilities.settings.defaults.bool(forKey: "shouldUseHEIFEDR") {
                    photoFormat = 1
                } else {
                    photoFormat = 2
                }
            }
        }
        .onDisappear() {
            utilities.settings.defaults.set(watermarkSwitch, forKey: "enableWatermark")
            utilities.settings.defaults.set(hdrSwitch, forKey: "shouldUseHDR")
            
            if !watermarkText.isEmpty {
                utilities.settings.defaults.set(watermarkText, forKey: "textForWatermark")
            } else {
                utilities.settings.defaults.set("Shot with Malachite", forKey: "textForWatermark")
            }
            
            if photoFormat == 0 {
                utilities.settings.defaults.set("0", forKey: "shouldUseHEIF")
                utilities.settings.defaults.set(false, forKey: "shouldUseHEIF")
                utilities.settings.defaults.set(false, forKey: "shouldUseHEIFEDR")
            } else if photoFormat == 1 {
                utilities.settings.defaults.set(true, forKey: "shouldUseHEIF")
                utilities.settings.defaults.set(false, forKey: "shouldUseHEIFEDR")
            } else if photoFormat == 2 {
                utilities.settings.defaults.set(true, forKey: "shouldUseHEIF")
                utilities.settings.defaults.set(true, forKey: "shouldUseHEIFEDR")
                
            }
        }
        .onChange(of: watermarkSwitch) {_ in
            utilities.settings.defaults.set(watermarkSwitch, forKey: "enableWatermark")
        }
        .onChange(of: hdrSwitch) { _ in
            utilities.settings.defaults.set(hdrSwitch, forKey: "shouldEnableHDR")
        }
        .onChange(of: watermarkText) {_ in
            watermarkText = String(watermarkText.prefix(65))
            if !watermarkText.isEmpty {
                utilities.settings.defaults.set(watermarkText, forKey: "textForWatermark")
            } else {
                utilities.settings.defaults.set("Shot with Malachite", forKey: "textForWatermark")
            }
        }
        .onChange(of: photoFormat) {_ in
            if photoFormat == 0 {
                utilities.settings.defaults.set(false, forKey: "shouldUseHEIF")
                utilities.settings.defaults.set(false, forKey: "shouldUseHEIFEDR")
            } else if photoFormat == 1 {
                utilities.settings.defaults.set(true, forKey: "shouldUseHEIF")
                utilities.settings.defaults.set(false, forKey: "shouldUseHEIFEDR")
            } else if photoFormat == 2 {
                utilities.settings.defaults.set(true, forKey: "shouldUseHEIF")
                utilities.settings.defaults.set(true, forKey: "shouldUseHEIFEDR")
                
            }
        }
        .navigationTitle("Settings")
    }
       
    
}

#Preview {
    MalachiteAboutAndSettingsView()
}

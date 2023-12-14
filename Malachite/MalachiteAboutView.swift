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
    @State private var supportsHEIC = false
    @State private var supportsHEIC10Bit = false
    @State private var formatPickerText = "This device isn't capable of encoding images in HEIF or HEIF 10-bit."
    
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
            Section(header: Text("Photo settings")) {
                Picker("Image file format", selection: $photoFormat) {
                    Text("JPEG")
                        .tag(0)
                    Text("HEIF")
                        .tag(1)
                        .disabled(!supportsHEIC)
                    Text("HEIF 10-bit")
                        .tag(2)
                        .disabled(!supportsHEIC10Bit)
                }
                .disabled(!supportsHEIC && !supportsHEIC10Bit)
                .pickerStyle(.segmented)
                Text(formatPickerText)
                if supportsHEIC && !supportsHEIC10Bit {
                    Text("You'll need to update to iOS 15 or later in order to use HEIF 10-bit.")
                }
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
            watermarkText = utilities.settings.defaults.string(forKey: "textForWatermark")!
            
            if utilities.function.supportedImageCaptureTypes.contains("public.heic") {
                supportsHEIC = true
                formatPickerText = "Choose JPEG for better compatibility with non-Apple platforms, or go with HEIC for better file size."
            }
            
            if #available(iOS 15.0, *) {
                supportsHEIC10Bit = true
                formatPickerText = "Choose JPEG for better compatibility with non-Apple platforms, HEIC for better file size, or HEIF 10-bit for the best quality and color accuracy."
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

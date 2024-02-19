//
//  MalachiteAboutView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/26/23.
//

import SwiftUI
import UIKit

struct MalachiteAboutAndSettingsView: View {
    @State private var watermarkSwitch = false
    @State private var watermarkText = String()
    @State private var photoFormat = Int()
    @State private var previewAspect = Int()
    @State private var shouldStabilize = Bool()
    @State private var hdrSwitch = false
    @State private var supportsHDR = Bool()
    @State private var supportsHEIC = Bool()
    @State private var supportsHEIC10Bit = Bool()
    @State private var formatFooterText = "This device isn't capable of encoding images in HEIF"
    @State private var exposureUnlimiterSwitch = false
    
    var utilities = MalachiteClassesObject()
    var dismissAction: (() -> Void)
    
    var body: some View {
        
        Form {
            aboutSection
            previewSettingsSection
            photoSettingsSection
            watermarkSettingsSection
        }
        .onAppear() {
            watermarkText = utilities.settings.defaults.string(forKey: "wtrmark.text")!
            
            watermarkSwitch = utilities.settings.defaults.bool(forKey: "wtrmark.enabled")
            hdrSwitch = utilities.settings.defaults.bool(forKey: "format.hdr.enabled")
            exposureUnlimiterSwitch = utilities.settings.defaults.bool(forKey: "capture.exposure.unlimited")
            shouldStabilize = utilities.settings.defaults.bool(forKey: "capture.stblz.enabled")
            
            supportsHDR = utilities.function.supportsHDR
            supportsHEIC = utilities.function.supportsHEIC()
            supportsHEIC10Bit = utilities.function.supportsHEIC10()
            
            if supportsHEIC {
                formatFooterText = "JPEG - Better compatibility with non-Apple platforms\nHEIC - Better file size while retaining quality"
            }
            
            if !supportsHDR {
                formatFooterText = formatFooterText + "\nThis device cannot capture HDR images in its current capture mode."
            }
            
            if !utilities.settings.defaults.bool(forKey: "format.type.heif") {
                photoFormat = 0
            } else {
                photoFormat = 1
            }
            
            if !utilities.settings.defaults.bool(forKey: "format.preview.fill") {
                previewAspect = 0
            } else {
                previewAspect = 1
            }
        }
        .onDisappear() {
            utilities.settings.defaults.set(watermarkSwitch, forKey: "wtrmark.enabled")
            utilities.settings.defaults.set(hdrSwitch, forKey: "format.hdr.enabled")
            utilities.settings.defaults.set(exposureUnlimiterSwitch, forKey: "capture.exposure.unlimited")
            utilities.settings.defaults.set(shouldStabilize, forKey: "capture.stblz.enabled")
            
            if !watermarkText.isEmpty {
                utilities.settings.defaults.set(watermarkText, forKey: "wtrmark.text")
            } else {
                utilities.settings.defaults.set("Shot with Malachite", forKey: "wtrmark.text")
            }
            
            if photoFormat == 0 {
                utilities.settings.defaults.set(false, forKey: "format.type.heif")
            } else {
                utilities.settings.defaults.set(true, forKey: "format.type.heif")
            }
            
            if previewAspect == 0 {
                utilities.settings.defaults.set(false, forKey: "format.preview.fill")
            } else {
                utilities.settings.defaults.set(true, forKey: "format.preview.fill")
            }
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, object: nil)
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, object: nil)
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, object: nil)
        }
        .navigationTitle("Settings")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    NSLog("[bre] bre")
                    self.dismissAction()
                } label: {
                    Text("Done")
                }
            }
        })
    }
    
    var aboutSection: some View {
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
    }
    
    var previewSettingsSection: some View {
        Section(header: Text("Preview settings"), footer: Text("Use Fit if you wish to see your entire viewport. Use Fill if you want a more immersive and honed-in experience.")) {
            Picker("Aspect ratio", selection: $previewAspect) {
                Text("Fit")
                    .tag(0)
                Text("Fill")
                    .tag(1)
            }
            .pickerStyle(.segmented)
            Toggle("Enable preview stabilization", isOn: $shouldStabilize)
        }
        .onChange(of: previewAspect) {_ in
            
            if previewAspect == 0 {
                utilities.settings.defaults.set(false, forKey: "format.preview.fill")
            } else {
                utilities.settings.defaults.set(true, forKey: "format.preview.fill")
            }
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, object: nil)
        }
        .onChange(of: shouldStabilize) {_ in
            utilities.settings.defaults.set(shouldStabilize, forKey: "capture.stblz.enabled")
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, object: nil)
        }
    }
    
    var photoSettingsSection: some View {
        Section(header: Text("Photo settings"), footer: Text(formatFooterText)) {
            Picker("Image file format", selection: $photoFormat) {
                Text("JPEG")
                    .tag(0)
                Text("HEIF")
                    .tag(1)
            }
            .disabled(!supportsHEIC)
            Toggle("Enable HDR", isOn: $hdrSwitch)
                .disabled(!supportsHDR)
            Toggle("Enable maximum exposure", isOn: $exposureUnlimiterSwitch)
        }
        .onChange(of: photoFormat) {_ in
            if photoFormat == 0 {
                utilities.settings.defaults.set(false, forKey: "format.type.heif")
            } else if photoFormat == 1 {
                utilities.settings.defaults.set(true, forKey: "format.type.heif")
            } else if photoFormat == 2 {
                utilities.settings.defaults.set(true, forKey: "format.type.heif")
                
            }
        }
        .onChange(of: hdrSwitch) { _ in
            utilities.settings.defaults.set(hdrSwitch, forKey: "shouldEnableHDR")
        }
        .onChange(of: exposureUnlimiterSwitch) { _ in
            NSLog("[Settings View] Lol")
            utilities.settings.defaults.set(exposureUnlimiterSwitch, forKey: "capture.exposure.unlimited")
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, object: nil)
        }
    }
    
    var watermarkSettingsSection: some View {
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
        .onChange(of: watermarkSwitch) {_ in
            utilities.settings.defaults.set(watermarkSwitch, forKey: "wtrmark.enabled")
        }
        .onChange(of: watermarkText) {_ in
            watermarkText = String(watermarkText.prefix(65))
            if !watermarkText.isEmpty {
                utilities.settings.defaults.set(watermarkText, forKey: "wtrmark.text")
            } else {
                utilities.settings.defaults.set("Shot with Malachite", forKey: "wtrmark.text")
            }
        }
    }
}

//
//  MalachiteSettingsView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/26/23.
//

import SwiftUI

struct MalachiteSettingsView: View {
    /// A State variable used for determining whether or not watermarking is enabled.
    @State private var watermarkSwitch = false
    /// A State variable used for determining the current watermark string.
    @State private var watermarkText = String()
    /// A State variable used for determining the active photo format.
    @State private var photoFormat = Int()
    /// A State variable used for determining the current aspect ratio for the ``cameraPreview``.
    @State private var previewAspect = Int()
    /// A State variable used for determining whether or not to stabilize the ``cameraPreview``.
    @State private var shouldStabilize = Bool()
    /// A State variable used for determining whether or not to capture in HDR.
    @State private var hdrSwitch = false
    /// A State variable used for determining whether or not the device supports HDR capture in its current mode.
    @State private var supportsHDR = Bool()
    /// A State variable used for determining whether or not the device supports HEIC capture.
    @State private var supportsHEIC = Bool()
    /// A State variable used for presenting the user with a footer based on capabilities.
    @State private var formatFooterText = "This device isn't capable of encoding images in HEIF"
    /// A State variable used for determining whether or not to uncap the exposure slider.
    @State private var exposureUnlimiterSwitch = false
    
    /// A variable to hold the existing instance of ``MalachiteClassesObject``.
    var utilities = MalachiteClassesObject()
    /// A variable used to hold the function for dismissing with the toolbar item.
    var dismissAction: (() -> Void)
    
    /**
     A variable used to hold the entire view.
     
     SwiftUI is weird...
     Currently holds:
     - Other variables to avoid type counting time issues.
     - Handles initialization of variables required to show current settings.
     - Navigation title of "Settings"
     - Toolbar item for dismissing the view.
     */
    var body: some View {
        
        Form {
            aboutSection
            previewSettingsSection
            photoSettingsSection
            watermarkSettingsSection
            debugSettingsSection
        }
        .onAppear() {
            watermarkText = utilities.settings.defaults.string(forKey: "wtrmark.text")!
            
            watermarkSwitch = utilities.settings.defaults.bool(forKey: "wtrmark.enabled")
            hdrSwitch = utilities.settings.defaults.bool(forKey: "format.hdr.enabled")
            exposureUnlimiterSwitch = utilities.settings.defaults.bool(forKey: "capture.exposure.unlimited")
            shouldStabilize = utilities.settings.defaults.bool(forKey: "capture.stblz.enabled")
            
            supportsHDR = utilities.function.supportsHDR
            supportsHEIC = utilities.function.supportsHEIC()
            
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
                    self.dismissAction()
                } label: {
                    Text("Done")
                }
            }
        })
    }
    
    /// A variable to hold the about section.
    var aboutSection: some View {
        Section {
            HStack {
                Text("About Malachite")
                    .bold()
                Spacer()
                NavigationLink("", destination: MalachiteAboutView(utilities: utilities, dismissAction: dismissAction))
                    .frame(width: 10)
            }
        }
    }
    
    /// A variable to hold the preview settings section.
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
    
    /// A variable to hold the photo settings section.
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
    
    /// A variable to hold the watermark settings section.
    var watermarkSettingsSection: some View {
        Section(header: Text("Watermark settings"), footer: Text("A fun little feature, you can enable a watermark on your images when you take them.")) {
            Toggle("Enable watermark", isOn: $watermarkSwitch)
            HStack {
                Text("Watermark text")
                Spacer()
                TextField("Shot with Malachite", text: $watermarkText)
                    .multilineTextAlignment(.trailing)
                    .autocorrectionDisabled()
                    .keyboardType(.twitter)
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
    
    /// A variable to hold the debug settings section. Only available with debug builds.
    var debugSettingsSection: some View {
        Section(header: Text("Debug settings"), footer: Text("Only available in debug builds, these settings are used to debug various parts of Malachite.")) {
            Button {
                NSLog("[Preferences] Resetting all preferences, relaunch the app to complete!")
                utilities.settings.resetAllSettings()
            } label: {
                HStack {
                    if #available(iOS 17.0, *) {
                        Text("Reset all settings")
                            .foregroundStyle(.red)
                    } else {
                        Text("Reset all settings")
                            .foregroundColor(.red)
                    }
                    Spacer()
                    if #available(iOS 15.0, *) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    } else {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            if utilities.games.gameCenterEnabled {
                Button {
                    NSLog("[Preferences] Resetting all preferences, relaunch the app to complete!")
                    utilities.games.achievements.resetAchievements()
                } label: {
                    HStack {
                        if #available(iOS 17.0, *) {
                            Text("Reset Game Center achievements")
                                .foregroundStyle(.red)
                        } else {
                            Text("Reset Game Center achievements")
                                .foregroundColor(.red)
                        }
                        Spacer()
                        if #available(iOS 15.0, *) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        } else {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
}

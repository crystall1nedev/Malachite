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
    /// A State variable used for determining what megapixel count to shoot in.
    @State private var megapixelCount = Int()
    /// A State variable used for determining whether or not to capture in HDR.
    @State private var hdrSwitch = false
    /// A State variable used for determining whether or not the device supports HDR capture in its current mode.
    @State private var supportsHDR = Bool()
    /// A State variable used for determining whether or not the device supports HEIC capture.
    @State private var supportsHEIC = Bool()
    /// A State variable used for presenting the user with a footer based on capabilities.
    @State private var formatFooterText = ""
    /// A State variable used for determining whether or not to uncap the exposure slider.
    @State private var exposureUnlimiterSwitch = false
    @State var presentingModal = false
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
        MalachiteNagivationViewUtils() { guts }
    }
    
    var guts: some View {
        Form {
            aboutSection
            previewSettingsSection
            photoSettingsSection
            watermarkSettingsSection
            debugSettingsSection
        }
        .onAppear() {
            watermarkText = utilities.settings.defaults.string(forKey: "wtrmark.text") ?? ""
            
            watermarkSwitch = utilities.settings.defaults.bool(forKey: "wtrmark.enabled")
            hdrSwitch = utilities.settings.defaults.bool(forKey: "capture.hdr.enabled")
            exposureUnlimiterSwitch = utilities.settings.defaults.bool(forKey: "capture.exposure.unlimited")
            shouldStabilize = utilities.settings.defaults.bool(forKey: "preview.stblz.enabled")
            
            supportsHDR = utilities.function.supportsHDR
            supportsHEIC = utilities.function.supportsHEIC()
            
            if !supportsHEIC {
                formatFooterText = "settings.footer.photo.heif".localized
            }
            
            if !supportsHDR {
                formatFooterText = formatFooterText + "settings.footer.photo.hdr".localized
            }
            
            switch utilities.settings.defaults.integer(forKey: "capture.size.mp") {
            case 12:
                megapixelCount = 1
            case 48:
                megapixelCount = 2
            default:
                megapixelCount = 0
            }
            
            if !utilities.settings.defaults.bool(forKey: "capture.type.heif") {
                photoFormat = 0
            } else {
                photoFormat = 1
            }
            
            if !utilities.settings.defaults.bool(forKey: "preview.size.fill") {
                previewAspect = 0
            } else {
                previewAspect = 1
            }
        }
        .onDisappear() {
            utilities.settings.defaults.set(watermarkSwitch, forKey: "wtrmark.enabled")
            utilities.settings.defaults.set(hdrSwitch, forKey: "capture.hdr.enabled")
            utilities.settings.defaults.set(exposureUnlimiterSwitch, forKey: "capture.exposure.unlimited")
            utilities.settings.defaults.set(shouldStabilize, forKey: "preview.stblz.enabled")
            
            if !watermarkText.isEmpty {
                utilities.settings.defaults.set(watermarkText, forKey: "wtrmark.text")
            } else {
                utilities.settings.defaults.set("Shot with Malachite", forKey: "wtrmark.text")
            }
            
            if MalachiteClassesObject().versionType == "INTERNAL" {
                switch megapixelCount {
                case 1:
                    utilities.settings.defaults.set(12, forKey: "capture.size.mp")
                case 2:
                    utilities.settings.defaults.set(48, forKey: "capture.size.mp")
                default:
                    utilities.settings.defaults.set(8, forKey: "capture.size.mp")
                }
            }
            
            if photoFormat == 0 {
                utilities.settings.defaults.set(false, forKey: "capture.type.heif")
            } else {
                utilities.settings.defaults.set(true, forKey: "capture.type.heif")
            }
            
            if previewAspect == 0 {
                utilities.settings.defaults.set(false, forKey: "preview.size.fill")
            } else {
                utilities.settings.defaults.set(true, forKey: "preview.size.fill")
            }
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, object: nil)
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, object: nil)
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, object: nil)
            if MalachiteClassesObject().versionType == "INTERNAL" {
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.megaPixelSwitchNotification.name, object: nil)
            }
        }
        .navigationTitle("view.title.settings")
        .toolbar(content: {
            ToolbarItemGroup(placement: .topBarLeading) {
                NavigationLink(destination: MalachiteSettingsDetailView(dismissAction: dismissAction)) {
                    Image(systemName: "questionmark.circle")
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    self.dismissAction()
                } label: {
                    Text("action.done_button")
                }
            }
        })
    }
    
    /// A variable to hold the about section.
    var aboutSection: some View {
        Section {
            MalachiteCellViewUtils(
                icon: "info.circle",
                title: nil,
                subtitle: nil,
                disabled: nil,
                dangerous: false)
            {
                Button("view.title.about") { self.presentingModal = true }
                    .sheet(isPresented: $presentingModal) { MalachiteAboutView(presentedAsModal: self.$presentingModal) }
            }
        }
    }
    
    /// A variable to hold the preview settings section.
    var previewSettingsSection: some View {
        Section(header: Text("settings.header.preview")) {
            MalachiteCellViewUtils(
                icon: "aspectratio",
                title: nil,
                subtitle: "settings.detail.preview.aspect_ratio",
                disabled: false,
                dangerous: false)
            {
                Picker("settings.option.preview.aspect_ratio", selection: $previewAspect) {
                    Text("settings.option.preview.aspect_ratio.fit")
                        .tag(0)
                    Text("settings.option.preview.aspect_ratio.fill")
                        .tag(1)
                }
            }
            
            MalachiteCellViewUtils(
                icon: "camera.metering.none",
                title: nil,
                subtitle: "settings.detail.preview.sbtlz",
                disabled: nil,
                dangerous: false)
            {
                Toggle("settings.option.preview.sbtlz", isOn: $shouldStabilize)
            }
        }
        .onChange(of: previewAspect) {_ in
            
            if previewAspect == 0 {
                utilities.settings.defaults.set(false, forKey: "preview.size.fill")
            } else {
                utilities.settings.defaults.set(true, forKey: "preview.size.fill")
            }
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, object: nil)
        }
        .onChange(of: shouldStabilize) {_ in
            utilities.settings.defaults.set(shouldStabilize, forKey: "preview.stblz.enabled")
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, object: nil)
        }
    }
    
    /// A variable to hold the photo settings section.
    var photoSettingsSection: some View {
        Section(header: Text("settings.header.photo"), footer: Text(formatFooterText)) {
            if MalachiteClassesObject().versionType == "INTERNAL" {
                MalachiteCellViewUtils(
                    icon: "camera.aperture",
                    title: nil,
                    subtitle: "settings.detail.photo.megapixels",
                    disabled: !utilities.settings.defaults.bool(forKey: "general.supports.8mp") && !utilities.settings.defaults.bool(forKey: "general.supports.48mp"),
                    dangerous: false)
                {
                    Picker("settings.option.photo.megapixels", selection: $megapixelCount) {
                        if utilities.settings.defaults.bool(forKey: "general.supports.8mp") {
                            Text("settings.option.photo.megapixels.8")
                                .tag(0)
                        }
                        Text("settings.option.photo.megapixels.12")
                            .tag(1)
                        if utilities.settings.defaults.bool(forKey: "general.supports.48mp") {
                            Text("settings.option.photo.megapixels.48")
                                .tag(2)
                        }
                    }
                }
            }
            MalachiteCellViewUtils(
                icon: "square.and.arrow.down",
                title: nil,
                subtitle: "settings.detail.photo.file_format",
                disabled: !supportsHEIC,
                dangerous: false)
            {
                Picker("settings.option.photo.file_format", selection: $photoFormat) {
                    Text("settings.option.photo.file_format.jpeg")
                        .tag(0)
                    Text("settings.option.photo.file_format.heif")
                        .tag(1)
                }
            }
            
            MalachiteCellViewUtils(
                icon: "camera.filters",
                title: nil,
                subtitle: "settings.detail.photo.hdr",
                disabled: !supportsHDR,
                dangerous: false)
            {
                Toggle("settings.option.photo.hdr", isOn: $hdrSwitch)
            }
            
            MalachiteCellViewUtils(
                icon: "sun.max",
                title: nil,
                subtitle: "settings.detail.photo.max_exposure",
                disabled: nil,
                dangerous: false)
            {
                Toggle("settings.option.photo.max_exposure", isOn: $exposureUnlimiterSwitch)
            }
        }
        .onChange(of: megapixelCount) { _ in
            if MalachiteClassesObject().versionType == "INTERNAL" {
                switch megapixelCount {
                case 1:
                    utilities.settings.defaults.set(12, forKey: "capture.size.mp")
                case 2:
                    utilities.settings.defaults.set(48, forKey: "capture.size.mp")
                default:
                    utilities.settings.defaults.set(8, forKey: "capture.size.mp")
                }
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.megaPixelSwitchNotification.name, object: nil)
            }
        }
        .onChange(of: photoFormat) {_ in
            if photoFormat == 0 {
                utilities.settings.defaults.set(false, forKey: "capture.type.heif")
            } else if photoFormat == 1 {
                utilities.settings.defaults.set(true, forKey: "capture.type.heif")
            }
        }
        .onChange(of: hdrSwitch) { _ in
            utilities.settings.defaults.set(hdrSwitch, forKey: "capture.hdr.enabled")
        }
        .onChange(of: exposureUnlimiterSwitch) { _ in
            utilities.debugNSLog("[Settings View] Lol")
            utilities.settings.defaults.set(exposureUnlimiterSwitch, forKey: "capture.exposure.unlimited")
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, object: nil)
        }
    }
    
    /// A variable to hold the watermark settings section.
    var watermarkSettingsSection: some View {
        Section(header: Text("settings.header.watermark")) {
            MalachiteCellViewUtils(
                icon: "textformat",
                title: nil,
                subtitle: "settings.detail.watermark.enable",
                disabled: nil,
                dangerous: false)
            {
                Toggle("settings.option.watermark.enable", isOn: $watermarkSwitch)
            }
            
            MalachiteCellViewUtils(
                icon: "signature",
                title: nil,
                subtitle: "settings.detail.watermark.text",
                disabled: nil,
                dangerous: false)
            {
                Text("settings.option.watermark.text")
                TextField("settings.option.watermark.text.placeholder", text: $watermarkText)
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
        Section(header: Text("settings.header.debug")) {
            MalachiteCellViewUtils(
                icon: "trash",
                title: nil,
                subtitle: "settings.detail.debug.erase_userdefaults",
                disabled: nil,
                dangerous: true)
            {
                Button {
                    utilities.debugNSLog("[Preferences] Resetting all preferences, relaunch the app to complete!")
                    utilities.settings.resetAllSettings()
                } label: {
                    if #available(iOS 17.0, *) {
                        Text("settings.option.debug.erase_userdefaults")
                            .foregroundStyle(.red)
                    } else {
                        Text("settings.option.debug.erase_userdefaults")
                            .foregroundColor(.red)
                    }
                }
            }
            
            if utilities.versionType == "INTERNAL" {
                MalachiteCellViewUtils(
                    icon: "trash",
                    title: nil,
                    subtitle: "settings.detail.debug.erase_gamekit",
                    disabled: nil,
                    dangerous: true)
                {
                    Button {
                        utilities.internalNSLog("[Preferences] Resetting all GameKit data!")
                        utilities.games.achievements.resetAchievements()
                    } label: {
                        if #available(iOS 17.0, *) {
                            Text("settings.option.debug.erase_gamekit")
                                .foregroundStyle(.red)
                        } else {
                            Text("settings.option.debug.erase_gamekit")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
}

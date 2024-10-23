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
    /// A State variable used for determining whether or not to enable continuous auto exposure.
    @State private var continuousAEAF = Int()
    /// A State variable used for determinign whether or not to enable exposure and focus POI on tap and hold.
    @State private var poiTapAndHold = Int()
    /// A State variable used for determining whether or not the device supports HDR capture in its current mode.
    @State private var supportsHDR = Bool()
    /// A State variable used for determining whether or not the device supports HEIC capture.
    @State private var supportsHEIC = Bool()
    /// A State variable used for presenting the user with a footer based on capabilities.
    @State private var formatFooterText = ""
    /// A State variable used for determining whether or not debug logging UserDefaults is enabled.
    @State private var debugLoggingUserDefaults = false
    /// A State variable used for determining what megapixel count the ultrawide camera should shoot in.
    @State private var ultrawideMegapixelCount = Int()
    /// A State variable used for determining what megapixel count the wide angle camera should shoot in.
    @State private var wideMegapixelCount = Int()
    /// A State variable used for determining what megapixel count the telephoto camera should shoot in.
    @State private var telephotoMegapixelCount = Int()
    /// A State variable used for determining whether or not a view is being presented.
    @State var presentingAboutModal = false
    /// A State variable used for determining whether or not a view is being presented.
    @State var presentingCompatibilityModal = false
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
            if utilities.versionType == "INTERNAL" {
                resolutionSettingsSection
            }
            photoSettingsSection
            watermarkSettingsSection
            uiSettingsSection
            if utilities.versionType == "DEBUG" || utilities.versionType == "INTERNAL" {
                debugSettingsSection
            }
        }
        .onAppear() {
            watermarkText = utilities.settings.defaults.string(forKey: "wtrmark.text") ?? ""
            
            watermarkSwitch = utilities.settings.defaults.bool(forKey: "wtrmark.enabled")
            hdrSwitch = utilities.settings.defaults.bool(forKey: "capture.hdr.enabled")
            shouldStabilize = utilities.settings.defaults.bool(forKey: "preview.stblz.enabled")
            debugLoggingUserDefaults = utilities.settings.defaults.bool(forKey: "debug.logging.userdefaults")
            
            supportsHDR = utilities.function.supportsHDR
            supportsHEIC = utilities.function.supportsHEIC()
            
            switch utilities.settings.defaults.stringArray(forKey: "capture.continuous.elements") {
            case ["ae", "af"]:
                continuousAEAF = 0
            case ["af"]:
                continuousAEAF = 1
            case ["ae"]:
                continuousAEAF = 2
            default:
                continuousAEAF = 3
            }
            
            switch utilities.settings.defaults.stringArray(forKey: "capture.tapgesture.elements") {
            case ["ae", "af"]:
                poiTapAndHold = 0
            case ["af"]:
                poiTapAndHold = 1
            case ["ae"]:
                poiTapAndHold = 2
            default:
                poiTapAndHold = 3
            }
            
            if !supportsHEIC {
                formatFooterText = "settings.footer.photo.heif".localized
            }
            
            if !supportsHDR {
                formatFooterText = formatFooterText + "\n" + "settings.footer.photo.hdr".localized
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
            utilities.settings.defaults.set(shouldStabilize, forKey: "preview.stblz.enabled")
            utilities.settings.defaults.set(debugLoggingUserDefaults, forKey: "debug.logging.userdefaults")
            
            switch continuousAEAF {
            case 0:
                utilities.settings.defaults.set(["ae", "af"] as Array<String>, forKey: "capture.continuous.elements")
            case 1:
                utilities.settings.defaults.set(["af"] as Array<String>, forKey: "capture.continuous.elements")
            case 2:
                utilities.settings.defaults.set(["ae"] as Array<String>, forKey: "capture.continuous.elements")
            default:
                utilities.settings.defaults.set(["off"] as Array<String>, forKey: "capture.continuous.elements")
            }
            
            switch poiTapAndHold {
            case 0:
                utilities.settings.defaults.set(["ae", "af"] as Array<String>, forKey: "capture.tapgesture.elements")
            case 1:
                utilities.settings.defaults.set(["af"] as Array<String>, forKey: "capture.tapgesture.elements")
            case 2:
                utilities.settings.defaults.set(["ae"] as Array<String>, forKey: "capture.tapgesture.elements")
            default:
                utilities.settings.defaults.set(["off"] as Array<String>, forKey: "capture.tapgesture.elements")
            }
            
            if !watermarkText.isEmpty {
                utilities.settings.defaults.set(watermarkText, forKey: "wtrmark.text")
            } else {
                utilities.settings.defaults.set("Shot with Malachite", forKey: "wtrmark.text")
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
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.continousAEAFNotification.name, object: nil)
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aeafTapGestureNotification.name, object: nil)
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
                disabled: nil,
                dangerous: false)
            {
                Button("view.title.about") { self.presentingAboutModal = true }
                    .sheet(isPresented: $presentingAboutModal) { MalachiteAboutView(presentedAsModal: self.$presentingAboutModal) }
            }
            if utilities.versionType == "INTERNAL" {
                MalachiteCellViewUtils(
                    icon: "checkmark.seal",
                    disabled: nil,
                    dangerous: false)
                {
                    Button("view.title.compatibility") { self.presentingCompatibilityModal = true }
                        .sheet(isPresented: $presentingCompatibilityModal) { MalachiteCompatibilityView(presentedAsModal: self.$presentingCompatibilityModal, utilities: utilities) }
                }
            }
        }
    }
    
    /// A variable to hold the preview settings section.
    var previewSettingsSection: some View {
        Section(header: Text("settings.header.preview")) {
            MalachiteCellViewUtils(
                icon: "aspectratio",
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
                icon: "level",
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
    
    /// A variable to hold the image resolution section.
    var resolutionSettingsSection: some View {
        Section(header: Text("settings.header.resolution")) {
            if utilities.settings.getCountOfDictionary(dictionary: "compatibility.dimensions.ultrawide") > 0 {
                MalachiteCellViewUtils(
                    icon: "camera.aperture",
                    disabled: utilities.settings.getCountOfDictionary(dictionary: "compatibility.dimensions.ultrawide") == 1,
                    dangerous: false)
                {
                    Picker("settings.option.resolution.ultrawide", selection: $ultrawideMegapixelCount) {
                        if utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.ultrawide", key: "8") {
                            Text("settings.option.resolution.8")
                                .tag(0)
                        }
                        if utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.ultrawide", key: "12") {
                            Text("settings.option.resolution.12")
                                .tag(1)
                        }
                        if utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.ultrawide", key: "48") {
                            Text("settings.option.resolution.48")
                                .tag(2)
                        }
                    }
                }
            }
            if utilities.settings.getCountOfDictionary(dictionary: "compatibility.dimensions.wide") > 0 {
                MalachiteCellViewUtils(
                    icon: "camera.aperture",
                    disabled: utilities.settings.getCountOfDictionary(dictionary: "compatibility.dimensions.wide") == 1,
                    dangerous: false)
                {
                    Picker("settings.option.resolution.wide", selection: $wideMegapixelCount) {
                        if utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.wide", key: "8") {
                            Text("settings.option.resolution.8")
                                .tag(0)
                        }
                        if utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.wide", key: "12") {
                            Text("settings.option.resolution.12")
                                .tag(1)
                        }
                        if utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.wide", key: "48") {
                            Text("settings.option.resolution.48")
                                .tag(2)
                        }
                    }
                }
            }
            if utilities.settings.getCountOfDictionary(dictionary: "compatibility.dimensions.telephoto") > 0 {
                MalachiteCellViewUtils(
                    icon: "camera.aperture",
                    disabled: utilities.settings.getCountOfDictionary(dictionary: "compatibility.dimensions.telephoto") == 1,
                    dangerous: false)
                {
                    Picker("settings.option.resolution.telephoto", selection: $telephotoMegapixelCount) {
                        if utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.telephoto", key: "12") {
                            Text("settings.option.resolution.12")
                                .tag(0)
                        }
                    }
                }
            }
        }
        .onAppear {
            switch utilities.settings.defaults.integer(forKey: "capture.mp.ultrawide") {
            case 12:
                ultrawideMegapixelCount = 1
            case 48:
                ultrawideMegapixelCount = 2
            default:
                ultrawideMegapixelCount = 0
            }
            
            switch utilities.settings.defaults.integer(forKey: "capture.mp.wide") {
            case 12:
                wideMegapixelCount = 1
            case 48:
                wideMegapixelCount = 2
            default:
                wideMegapixelCount = 0
            }
            
            switch utilities.settings.defaults.integer(forKey: "capture.mp.telephoto") {
            default:
                telephotoMegapixelCount = 0
            }
        }
        .onDisappear {
            switch ultrawideMegapixelCount {
            case 1:
                utilities.settings.defaults.set(12, forKey: "capture.mp.ultrawide")
            case 2:
                utilities.settings.defaults.set(48, forKey: "capture.mp.ultrawide")
            default:
                utilities.settings.defaults.set(8, forKey: "capture.mp.ultrawide")
            }
            
            switch wideMegapixelCount {
            case 1:
                utilities.settings.defaults.set(12, forKey: "capture.mp.wide")
            case 2:
                utilities.settings.defaults.set(48, forKey: "capture.mp.wide")
            default:
                utilities.settings.defaults.set(8, forKey: "capture.mp.wide")
            }
            
            switch telephotoMegapixelCount {
            default:
                utilities.settings.defaults.set(12, forKey: "capture.mp.telephoto")
            }
        }
        .onChange(of: ultrawideMegapixelCount) { _ in
            switch ultrawideMegapixelCount {
            case 1:
                utilities.settings.defaults.set(12, forKey: "capture.mp.ultrawide")
            case 2:
                utilities.settings.defaults.set(48, forKey: "capture.mp.ultrawide")
            default:
                utilities.settings.defaults.set(8, forKey: "capture.mp.ultrawide")
            }
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.megaPixelSwitchNotification.name, object: nil)
        }
        .onChange(of: wideMegapixelCount) { _ in
            switch wideMegapixelCount {
            case 1:
                utilities.settings.defaults.set(12, forKey: "capture.mp.wide")
            case 2:
                utilities.settings.defaults.set(48, forKey: "capture.mp.wide")
            default:
                utilities.settings.defaults.set(8, forKey: "capture.mp.wide")
            }
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.megaPixelSwitchNotification.name, object: nil)
        }
        .onChange(of: telephotoMegapixelCount) { _ in
            switch telephotoMegapixelCount {
            default:
                utilities.settings.defaults.set(12, forKey: "capture.mp.telephoto")
            }
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.megaPixelSwitchNotification.name, object: nil)
        }
    }
    
    /// A variable to hold the photo settings section.
    var photoSettingsSection: some View {
        Section(header: Text("settings.header.photo"), footer: Text(formatFooterText)) {
            MalachiteCellViewUtils(
                icon: "square.and.arrow.down",
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
                disabled: !supportsHDR,
                dangerous: false)
            {
                Toggle("settings.option.photo.hdr", isOn: $hdrSwitch)
            }
            MalachiteCellViewUtils(
                    icon: "plus.viewfinder",
                    disabled: nil,
                    dangerous: false)
            {
                Picker("settings.option.photo.continuous", selection: $continuousAEAF) {
                    Text("settings.option.reusable.ae_af")
                        .tag(0)
                    Text("settings.option.reusable.af")
                        .tag(1)
                    Text("settings.option.reusable.ae")
                        .tag(2)
                    Text("settings.option.reusable.off")
                        .tag(3)
                }
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
        .onChange(of: continuousAEAF) { _ in
            switch continuousAEAF {
            case 0:
                utilities.settings.defaults.set(["ae", "af"] as Array<String>, forKey: "capture.continuous.elements")
            case 1:
                utilities.settings.defaults.set(["af"] as Array<String>, forKey: "capture.continuous.elements")
            case 2:
                utilities.settings.defaults.set(["ae"] as Array<String>, forKey: "capture.continuous.elements")
            default:
                utilities.settings.defaults.set(["off"] as Array<String>, forKey: "capture.continuous.elements")
            }
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.continousAEAFNotification.name, object: nil)
        }
    }
    
    /// A variable to hold the watermark settings section.
    var watermarkSettingsSection: some View {
        Section(header: Text("settings.header.watermark")) {
            MalachiteCellViewUtils(
                icon: "hand.tap",
                disabled: nil,
                dangerous: false)
            {
                Toggle("settings.option.watermark.enable", isOn: $watermarkSwitch)
            }
            
            MalachiteCellViewUtils(
                icon: "signature",
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
    
    /// A variable to hold settings related to the user interface
    var uiSettingsSection: some View {
        Section(header: Text("settings.header.ui")) {
            MalachiteCellViewUtils(
                icon: "text.justify",
                disabled: nil,
                dangerous: false)
            {
                Picker("settings.option.ui.tapgesture", selection: $poiTapAndHold) {
                    Text("settings.option.reusable.ae_af")
                        .tag(0)
                    Text("settings.option.reusable.af")
                        .tag(1)
                    Text("settings.option.reusable.ae")
                        .tag(2)
                    Text("settings.option.reusable.off")
                        .tag(3)
                }
            }
        }
        .onChange(of: poiTapAndHold) {_ in
            switch poiTapAndHold {
            case 0:
                utilities.settings.defaults.set(["ae", "af"] as Array<String>, forKey: "capture.tapgesture.elements")
            case 1:
                utilities.settings.defaults.set(["af"] as Array<String>, forKey: "capture.tapgesture.elements")
            case 2:
                utilities.settings.defaults.set(["ae"] as Array<String>, forKey: "capture.tapgesture.elements")
            default:
                utilities.settings.defaults.set(["off"] as Array<String>, forKey: "capture.tapgesture.elements")
            }
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aeafTapGestureNotification.name, object: nil)
        }
    }
    
    /// A variable to hold the debug settings section. Only available with debug builds.
    var debugSettingsSection: some View {
        Section(header: Text("settings.header.debug")) {
            MalachiteCellViewUtils(
                icon: "text.redaction",
                disabled: nil,
                dangerous: false)
            {
                Toggle("settings.option.debug.logging.userdefaults", isOn: $debugLoggingUserDefaults)
            }
            MalachiteCellViewUtils(
                icon: "trash",
                disabled: nil,
                dangerous: true)
            {
                Button {
                    utilities.debugNSLog("[Preferences] Resetting all preferences, relaunch the app to complete!")
                    utilities.settings.resetAllSettings()
                } label: {
                    if #available(iOS 17.0, *) {
                        Text("settings.option.debug.erase.userdefaults")
                            .foregroundStyle(.red)
                    } else {
                        Text("settings.option.debug.erase.userdefaults")
                            .foregroundColor(.red)
                    }
                }
            }
            
            if utilities.versionType == "INTERNAL" {
                MalachiteCellViewUtils(
                    icon: "trash",
                    disabled: nil,
                    dangerous: true)
                {
                    Button {
                        utilities.internalNSLog("[Preferences] Resetting all GameKit data!")
                        utilities.games.achievements.resetAchievements()
                    } label: {
                        if #available(iOS 17.0, *) {
                            Text("settings.option.debug.erase.gamekit")
                                .foregroundStyle(.red)
                        } else {
                            Text("settings.option.debug.erase.gamekit")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .onChange(of: debugLoggingUserDefaults) {_ in
            utilities.settings.defaults.set(debugLoggingUserDefaults, forKey: "debug.logging.userdefaults")
        }
    }
}

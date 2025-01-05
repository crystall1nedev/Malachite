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
    /// A State variable used for determining what the maximum zoom level for each camera should be.
    @State private var zoomMaximum = Int()
    /// A State variable used for determining whether or not to capture in HDR.
    @State private var hdrSwitch = false
    /// A State variable used for determining whether or not to enable continuous auto exposure.
    @State private var continuousAEAF = Int()
    /// A State variable used for determining how many fingers are used for the settings gesture.
    @State private var settingsGestureFingers = Int()
    /// A State variable used for determining whether or not to enable exposure and focus POI on tap and hold.
    @State private var poiTapAndHold = Int()
    /// A State variable used for determining whether or not to enable the system's auto locking APIs.
    @State private var idleTimerDisabled = Bool()
    /// A State variable used for determining whether or not to enabel haptics.
    @State private var hapticsDisabled = Bool()
    /// A State variable used for determining whether or not to start the app with the UI hidden.
    @State private var appStartsUIHidden = Bool()
    /// A State vairable used for determining whether or not to enable pinch to zoom and the tap gesture while the UI is hidden.
    @State private var uiHiderGestures = Int()
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
            resolutionSettingsSection
            photoSettingsSection
            watermarkSettingsSection
            uiSettingsSection
            if utilities.versionType == "DEBUG" || utilities.versionType == "INTERNAL" {
                debugSettingsSection
            }
        }
        .onAppear { onAppear() }
        .onDisappear { onDisappear() }
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
            MalachiteCellViewUtils(
                icon: "plus.magnifyingglass",
                disabled: nil,
                dangerous: false)
            {
                Picker("settings.option.preview.zoom_maximum", selection: $zoomMaximum) {
                    Text("settings.option.preview.zoom_maximum.5")
                        .tag(0)
                    Text("settings.option.preview.zoom_maximum.10")
                        .tag(1)
                }
            }
        }
        .onChange(of: previewAspect) {_ in
            utilities.preferences.preview.aspect = (previewAspect == 1)
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, object: nil)
        }
        .onChange(of: shouldStabilize) {_ in
            utilities.preferences.preview.stablize = shouldStabilize
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, object: nil)
        }
        .onChange(of: zoomMaximum) {_ in
            switch zoomMaximum {
            case 0:
                utilities.preferences.capture.maximumZoom = 5
            case 1:
                utilities.preferences.capture.maximumZoom = 10
            default:
                utilities.preferences.capture.maximumZoom = 5
            }
        }
    }
    
    /// A variable to hold the image resolution section.
    var resolutionSettingsSection: some View {
        Section(header: Text("settings.header.resolution")) {
            if utilities.preferences.utils.dictionary.isValid(dictionary: utilities.preferences.compatibility.ultrawide) {
                MalachiteCellViewUtils(
                    icon: "camera.aperture",
                    disabled: utilities.preferences.utils.dictionary.getCount(dictionary: utilities.preferences.compatibility.ultrawide) == 1,
                    dangerous: false)
                {
                    Picker("settings.option.resolution.ultrawide", selection: $ultrawideMegapixelCount) {
                        if let mp = utilities.preferences.compatibility.ultrawide["8"] { if mp {
                            Text("settings.option.resolution.8")
                                .tag(0)
                        } }
                        if let mp = utilities.preferences.compatibility.ultrawide["12"] { if mp {
                            Text("settings.option.resolution.12")
                                .tag(1)
                        } }
                        if let mp = utilities.preferences.compatibility.ultrawide["48"] { if mp {
                            Text("settings.option.resolution.48")
                                .tag(2)
                        } }
                    }
                }
            }
            if utilities.preferences.utils.dictionary.isValid(dictionary: utilities.preferences.compatibility.wideangle) {
                MalachiteCellViewUtils(
                    icon: "camera.aperture",
                    disabled: utilities.preferences.utils.dictionary.getCount(dictionary: utilities.preferences.compatibility.wideangle) == 1,
                    dangerous: false)
                {
                    Picker("settings.option.resolution.wide", selection: $wideMegapixelCount) {
                        if let mp = utilities.preferences.compatibility.wideangle["8"] { if mp {
                            Text("settings.option.resolution.8")
                                .tag(0)
                        } }
                        if let mp = utilities.preferences.compatibility.wideangle["12"] { if mp {
                            Text("settings.option.resolution.12")
                                .tag(1)
                        } }
                        if let mp = utilities.preferences.compatibility.wideangle["48"] { if mp {
                            Text("settings.option.resolution.48")
                                .tag(2)
                        } }
                    }
                }
            }
            if utilities.preferences.utils.dictionary.isValid(dictionary: utilities.preferences.compatibility.telephoto) {
                MalachiteCellViewUtils(
                    icon: "camera.aperture",
                    disabled: utilities.preferences.utils.dictionary.getCount(dictionary: utilities.preferences.compatibility.telephoto) == 1,
                    dangerous: false)
                {
                    Picker("settings.option.resolution.telephoto", selection: $telephotoMegapixelCount) {
                        if let mp = utilities.preferences.compatibility.wideangle["48"] { if mp {
                            Text("settings.option.resolution.12")
                                .tag(0)
                        } }
                    }
                }
            }
        }
        .onChange(of: ultrawideMegapixelCount) { _ in
            switch ultrawideMegapixelCount {
            case 1:
                utilities.preferences.capture.mp.ultrawide = 12
            case 2:
                utilities.preferences.capture.mp.ultrawide = 48
            default:
                utilities.preferences.capture.mp.ultrawide = 8
            }
        }
        .onChange(of: wideMegapixelCount) { _ in
            switch wideMegapixelCount {
            case 1:
                utilities.preferences.capture.mp.wideangle = 12
            case 2:
                utilities.preferences.capture.mp.wideangle = 48
            default:
                utilities.preferences.capture.mp.wideangle = 8
            }
        }
        .onChange(of: telephotoMegapixelCount) { _ in
            switch telephotoMegapixelCount {
            default:
                utilities.preferences.capture.mp.telephoto = 12
            }
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
                Picker("settings.option.photo.fileformat", selection: $photoFormat) {
                    Text("settings.option.photo.fileformat.jpeg")
                        .tag(0)
                    Text("settings.option.photo.fileformat.heif")
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
                    Text("settings.option.reusable.aeaf")
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
            utilities.preferences.capture.format.jpeg = photoFormat == 0 ? true : false
            utilities.preferences.capture.format.heic = photoFormat == 1 ? true : false
        }
        .onChange(of: hdrSwitch) { _ in
            utilities.preferences.capture.hdr = hdrSwitch
        }
        .onChange(of: continuousAEAF) { _ in
            switch continuousAEAF {
            case 0:
                utilities.preferences.capture.continuous = ["ae", "af"]
            case 1:
                utilities.preferences.capture.continuous = ["af"]
            case 2:
                utilities.preferences.capture.continuous = ["ae"]
            default:
                utilities.preferences.capture.continuous = ["off"]
            }
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.continousAEAFNotification.name, object: nil)
        }
    }
    
    /// A variable to hold the watermark settings section.
    var watermarkSettingsSection: some View {
        Section(header: Text("settings.header.watermark")) {
            MalachiteCellViewUtils(
                icon: "textformat",
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
            utilities.preferences.watermark.enabled = watermarkSwitch
        }
        .onChange(of: watermarkText) {_ in
            utilities.preferences.watermark.text = watermarkText.isEmpty ? "Shot with Malachite" : String(watermarkText.prefix(65))
        }
    }
    
    /// A variable to hold settings related to the user interface
    var uiSettingsSection: some View {
        Section(header: Text("settings.header.ui")) {
            MalachiteCellViewUtils(
                icon: "hand.tap",
                disabled: nil,
                dangerous: false)
            {
                Picker("settings.option.ui.tapgesture", selection: $poiTapAndHold) {
                    Text("settings.option.reusable.aeaf")
                        .tag(0)
                    Text("settings.option.reusable.af")
                        .tag(1)
                    Text("settings.option.reusable.ae")
                        .tag(2)
                    Text("settings.option.reusable.off")
                        .tag(3)
                }
            }
            if utilities.versionType == "INTERNAL" {
                MalachiteCellViewUtils(
                    icon: "hand.draw",
                    disabled: nil,
                    dangerous: false)
                {
                    Picker("settings.option.ui.settingsgesture", selection: $settingsGestureFingers) {
                        Text("settings.option.ui.settingsgesture.1")
                            .tag(1)
                        Text("settings.option.ui.settingsgesture.2")
                            .tag(2)
                        Text("settings.option.ui.settingsgesture.3")
                            .tag(3)
                    }
                }
            }
            MalachiteCellViewUtils(
                icon: "hand.raised.slash",
                disabled: nil,
                dangerous: false)
            {
                Picker("settings.option.ui.hiddengestures", selection: $uiHiderGestures) {
                    Text("settings.option.reusable.pinchzoomtapandhold")
                        .tag(0)
                    Text("settings.option.reusable.pinchzoom")
                        .tag(1)
                    Text("settings.option.reusable.tapandhold")
                        .tag(2)
                    Text("settings.option.reusable.off")
                        .tag(3)
                }
            }
            MalachiteCellViewUtils(
                icon: "clock",
                disabled: nil,
                dangerous: false)
            {
                Toggle("settings.option.ui.idletimer", isOn: $idleTimerDisabled)
            }
            MalachiteCellViewUtils(
                icon: "iphone.radiowaves.left.and.right",
                disabled: nil,
                dangerous: false)
            {
                Toggle("settings.option.ui.haptics", isOn: $hapticsDisabled)
            }
            MalachiteCellViewUtils(
                icon: "eye.slash",
                disabled: nil,
                dangerous: false)
            {
                Toggle("settings.option.ui.hiddenonlaunch", isOn: $appStartsUIHidden)
            }
        }
        .onChange(of: poiTapAndHold) {_ in
            switch poiTapAndHold {
            case 0:
                utilities.preferences.userInterface.tapAndHold = ["ae", "af"]
            case 1:
                utilities.preferences.userInterface.tapAndHold = ["af"]
            case 2:
                utilities.preferences.userInterface.tapAndHold = ["ae"]
            default:
                utilities.preferences.userInterface.tapAndHold = ["off"]
            }
        }
        .onChange(of: settingsGestureFingers) {_ in
            utilities.preferences.evaintrnl.settingsGesture = settingsGestureFingers
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.settingsGestureNotification.name, object: nil)
        }
        .onChange(of: uiHiderGestures) {_ in
            switch uiHiderGestures {
            case 0:
                utilities.preferences.userInterface.hiddenControls = ["zoom", "tah"]
            case 1:
                utilities.preferences.userInterface.hiddenControls = ["zoom"]
            case 2:
                utilities.preferences.userInterface.hiddenControls = ["tah"]
            default:
                utilities.preferences.userInterface.hiddenControls = ["off"]
            }
            
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aeafTapGestureNotification.name, object: nil)
        }
        .onChange(of: idleTimerDisabled) { _ in
            utilities.preferences.userInterface.idleTimerDisabled = idleTimerDisabled
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.idleTimerNotification.name, object: nil)
        }
        .onChange(of: hapticsDisabled) { _ in
            utilities.preferences.userInterface.hapticFeedback = hapticsDisabled
        }
        .onChange(of: appStartsUIHidden) { _ in
            utilities.preferences.userInterface.appLaunch = appStartsUIHidden
        }
    }
    
    /// A variable to hold the debug settings section. Only available with debug builds.
    // TODO: Update to the new preferences system
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
            utilities.preferences.debug.logging.preferences = debugLoggingUserDefaults
        }
    }
    
    func onAppear() {
        supportsHDR = utilities.function.supportsHDR
        supportsHEIC = utilities.function.supportsHEIC()
        
        if !supportsHEIC {
            formatFooterText = "settings.footer.photo.heif".localized
        }
        
        if !supportsHDR {
            formatFooterText = formatFooterText + "settings.footer.photo.hdr".localized
        }
        
        shouldStabilize = utilities.preferences.preview.stablize
        
        switch utilities.preferences.capture.maximumZoom {
        case 5:
            zoomMaximum = 0
        case 10:
            zoomMaximum = 1
        default:
            zoomMaximum = 0
        }
        
        previewAspect = utilities.preferences.preview.aspect ? 1 : 0
        
        switch utilities.preferences.capture.mp.ultrawide {
        case 12:
            ultrawideMegapixelCount = 1
        case 48:
            ultrawideMegapixelCount = 2
        default:
            ultrawideMegapixelCount = 0
        }
        
        switch utilities.preferences.capture.mp.wideangle {
        case 12:
            wideMegapixelCount = 1
        case 48:
            wideMegapixelCount = 2
        default:
            wideMegapixelCount = 0
        }
        
        switch utilities.preferences.capture.mp.telephoto {
        default:
            telephotoMegapixelCount = 0
        }
        
        hdrSwitch = utilities.preferences.capture.hdr
        
        // TODO: Better way to do this
        photoFormat = utilities.preferences.capture.format.jpeg ? 0 : 1
        photoFormat = utilities.preferences.capture.format.heic ? 1 : 0
        
        switch utilities.preferences.capture.continuous {
        case ["ae", "af"]:
            continuousAEAF = 0
        case ["af"]:
            continuousAEAF = 1
        case ["ae"]:
            continuousAEAF = 2
        default:
            continuousAEAF = 3
        }
        
        watermarkText = utilities.preferences.watermark.text
        watermarkSwitch = utilities.preferences.watermark.enabled
        
        settingsGestureFingers = utilities.preferences.evaintrnl.settingsGesture
        idleTimerDisabled = utilities.preferences.userInterface.idleTimerDisabled
        hapticsDisabled = utilities.preferences.userInterface.hapticFeedback
        appStartsUIHidden = utilities.preferences.userInterface.appLaunch
        
        switch utilities.preferences.userInterface.tapAndHold {
        case ["ae", "af"]:
            poiTapAndHold = 0
        case ["af"]:
            poiTapAndHold = 1
        case ["ae"]:
            poiTapAndHold = 2
        default:
            poiTapAndHold = 3
        }
        
        switch utilities.preferences.userInterface.hiddenControls {
        case ["zoom", "tah"]:
            uiHiderGestures = 0
        case ["zoom"]:
            uiHiderGestures = 1
        case ["tah"]:
            uiHiderGestures = 2
        default:
            uiHiderGestures = 3
        }
        
        debugLoggingUserDefaults = utilities.preferences.debug.logging.preferences
    }
    
    func onDisappear() {
        utilities.preferences.preview.aspect = (previewAspect == 1)
        utilities.preferences.preview.stablize = shouldStabilize
        
        switch zoomMaximum {
        case 0:
            utilities.preferences.capture.maximumZoom = 5
        case 1:
            utilities.preferences.capture.maximumZoom = 10
        default:
            utilities.preferences.capture.maximumZoom = 5
        }
        
        NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aspectFillNotification.name, object: nil)
        NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.stabilizerNotification.name, object: nil)
        
        switch ultrawideMegapixelCount {
        case 1:
            utilities.preferences.capture.mp.ultrawide = 12
        case 2:
            utilities.preferences.capture.mp.ultrawide = 48
        default:
            utilities.preferences.capture.mp.ultrawide = 8
        }
        
        switch wideMegapixelCount {
        case 1:
            utilities.preferences.capture.mp.wideangle = 12
        case 2:
            utilities.preferences.capture.mp.wideangle = 48
        default:
            utilities.preferences.capture.mp.wideangle = 8
        }
        
        switch telephotoMegapixelCount {
        default:
            utilities.preferences.capture.mp.telephoto = 12
        }
        
        NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.megaPixelSwitchNotification.name, object: nil)
        
        utilities.preferences.capture.hdr = hdrSwitch
        utilities.preferences.capture.format.jpeg = photoFormat == 0 ? true : false
        utilities.preferences.capture.format.heic = photoFormat == 1 ? true : false
        
        switch continuousAEAF {
        case 0:
            utilities.preferences.capture.continuous = ["ae", "af"]
        case 1:
            utilities.preferences.capture.continuous = ["af"]
        case 2:
            utilities.preferences.capture.continuous = ["ae"]
        default:
            utilities.preferences.capture.continuous = ["off"]
        }
        
        NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.continousAEAFNotification.name, object: nil)
        
        utilities.preferences.watermark.enabled = watermarkSwitch
        utilities.preferences.watermark.text = watermarkText.isEmpty ? "Shot with Malachite" : String(watermarkText.prefix(65))
        
        utilities.preferences.evaintrnl.settingsGesture = settingsGestureFingers
        utilities.preferences.userInterface.idleTimerDisabled = idleTimerDisabled
        utilities.preferences.userInterface.hapticFeedback = hapticsDisabled
        utilities.preferences.userInterface.appLaunch = appStartsUIHidden
        
        switch poiTapAndHold {
        case 0:
            utilities.preferences.userInterface.tapAndHold = ["ae", "af"]
        case 1:
            utilities.preferences.userInterface.tapAndHold = ["af"]
        case 2:
            utilities.preferences.userInterface.tapAndHold = ["ae"]
        default:
            utilities.preferences.userInterface.tapAndHold = ["off"]
        }
        
        switch uiHiderGestures {
        case 0:
            utilities.preferences.userInterface.hiddenControls = ["zoom", "tah"]
        case 1:
            utilities.preferences.userInterface.hiddenControls = ["zoom"]
        case 2:
            utilities.preferences.userInterface.hiddenControls = ["tah"]
        default:
            utilities.preferences.userInterface.hiddenControls = ["off"]
        }
        
        NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.settingsGestureNotification.name, object: nil)
        NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aeafTapGestureNotification.name, object: nil)
        NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.idleTimerNotification.name, object: nil)
        
        utilities.preferences.debug.logging.preferences = debugLoggingUserDefaults
    }
}

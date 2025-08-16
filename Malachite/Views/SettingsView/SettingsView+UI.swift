//
//  SettingsView+UI.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension SettingsView {
    struct UserInterface: View {
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
        /// A State variable used for determining whether or not this view is being presented as a modal.
        var dismissAction: (() -> Void)
        /// A variable to hold the existing instance of ``MalachiteClassesObject``.
        var utilities = MalachiteClassesObject()
        
        init(
            utilities: MalachiteClassesObject,
            dismissAction: @escaping (() -> Void)
        ) {
            self.utilities = utilities
            self.dismissAction = dismissAction
        }
        
        var body: some View {
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
            .onAppear(perform: self.onAppear)
            .onDisappear(perform: self.onDisappear)
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
        
        func onAppear() {
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
        }
        
        func onDisappear() {
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.aeafTapGestureNotification.name, object: nil)
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.idleTimerNotification.name, object: nil)
            
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
        }
    }
}

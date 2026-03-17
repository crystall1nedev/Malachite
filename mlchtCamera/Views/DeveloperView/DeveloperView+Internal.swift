//
//  DeveloperView+Internal.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension DeveloperView {
    struct InternalSettings: View {
        /// A State variable used for determining how many fingers are used for the settings gesture.
        @State private var settingsGestureFingers = Int()
        /// A State variable used for determining whether or not to block accidental gestures.
        @State private var blockAccidentalGestures = Bool()
        /// A State variable used for determining whether or not to enable the Camera Control.
        @State private var cameraControlEnabled = Bool()
        /// A State variable used for determining whether or not to enable geotagging images.
        @State private var locationEnabled = Bool()
        
        var utilities: MalachiteClassesObject
        var location: Location
        
        init(
            utilities: MalachiteClassesObject,
            location: Location
        ) {
            self.utilities = utilities
            self.location = location
        }
        
        var body: some View {
            Section(header: Text("developer.header.internal")) {
                MalachiteCellViewUtils(
                    icon: "hand.draw",
                    disabled: nil,
                    dangerous: false)
                {
                    Picker("internal.option.settingsgesture", selection: $settingsGestureFingers) {
                        Text("internal.option.settingsgesture.1")
                            .tag(1)
                        Text("internal.option.settingsgesture.2")
                            .tag(2)
                        Text("internal.option.settingsgesture.3")
                            .tag(3)
                    }
                }
                MalachiteCellViewUtils(
                    icon: "",
                    disabled: nil,
                    dangerous: false)
                {
                    Toggle("internal.option.blockaccidentalgestures", isOn: $blockAccidentalGestures)
                }
                if #available(iOS 18.0, *) {
                    MalachiteCellViewUtils(
                        icon: "",
                        disabled: nil,
                        dangerous: false)
                    {
                        Toggle("internal.option.cameracontrol", isOn: $cameraControlEnabled)
                    }
                }
                MalachiteCellViewUtils(
                    icon: "",
                    disabled: !location.locationEnabled,
                    dangerous: false)
                {
                    Toggle("internal.option.location", isOn: $locationEnabled)
                }
                #warning("do camera control options")
            }
            .onAppear(perform: onAppear)
            .onDisappear(perform: onDisappear)
            .onChange(of: settingsGestureFingers) {_ in
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.settingsGestureNotification.name, object: nil)
                
                utilities.preferences.evaintrnl.settingsGesture = settingsGestureFingers
            }
            .onChange(of: blockAccidentalGestures) {_ in
                utilities.preferences.evaintrnl.blockAccidentalGestures = blockAccidentalGestures
            }
            .onChange(of: cameraControlEnabled) {_ in
                utilities.preferences.evaintrnl.cameraControlEnabled = cameraControlEnabled
            }
            .onChange(of: locationEnabled) {_ in
                if location.locationEnabled { utilities.preferences.evaintrnl.locationEnabled = locationEnabled }
            }
        }
        
        func onAppear() {
            settingsGestureFingers = utilities.preferences.evaintrnl.settingsGesture
            blockAccidentalGestures = utilities.preferences.evaintrnl.blockAccidentalGestures
            cameraControlEnabled = utilities.preferences.evaintrnl.cameraControlEnabled
            locationEnabled = location.locationEnabled ? utilities.preferences.evaintrnl.locationEnabled : false
        }
        
        func onDisappear() {
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.settingsGestureNotification.name, object: nil)
            
            utilities.preferences.evaintrnl.settingsGesture = settingsGestureFingers
            utilities.preferences.evaintrnl.blockAccidentalGestures = blockAccidentalGestures
            utilities.preferences.evaintrnl.cameraControlEnabled = cameraControlEnabled
            if location.locationEnabled { utilities.preferences.evaintrnl.locationEnabled = locationEnabled }
        }
    }
}

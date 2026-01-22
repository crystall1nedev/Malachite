//
//  SettingsView+Resolution.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension SettingsView {
    struct Resolution: View {
        /// A State variable used for determining what megapixel count the ultrawide camera should shoot in.
        @State private var ultrawideMegapixelCount = Int()
        /// A State variable used for determining what megapixel count the wide angle camera should shoot in.
        @State private var wideMegapixelCount = Int()
        /// A State variable used for determining what megapixel count the telephoto camera should shoot in.
        @State private var telephotoMegapixelCount = Int()
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
            Section(header: Text("settings.header.resolution")) {
                if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.ultrawide) {
                    MalachiteCellViewUtils(
                        icon: "camera.aperture",
                        disabled: utilities.preferences.ext.dictionary.getCount(dictionary: utilities.preferences.compatibility.ultrawide) == 1,
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
                if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.wideangle) {
                    MalachiteCellViewUtils(
                        icon: "camera.aperture",
                        disabled: utilities.preferences.ext.dictionary.getCount(dictionary: utilities.preferences.compatibility.wideangle) == 1,
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
                if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.telephoto) {
                    MalachiteCellViewUtils(
                        icon: "camera.aperture",
                        disabled: utilities.preferences.ext.dictionary.getCount(dictionary: utilities.preferences.compatibility.telephoto) == 1,
                        dangerous: false)
                    {
                        Picker("settings.option.resolution.telephoto", selection: $telephotoMegapixelCount) {
                            if let mp = utilities.preferences.compatibility.telephoto["48"] { if mp {
                                Text("settings.option.resolution.48")
                                    .tag(1)
                            } }
                            if let mp = utilities.preferences.compatibility.telephoto["12"] { if mp {
                                Text("settings.option.resolution.12")
                                    .tag(0)
                            } }
                        }
                    }
                }
            }
            .onAppear(perform: self.onAppear)
            .onDisappear(perform: self.onDisappear)
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
                case 1:
                    utilities.preferences.capture.mp.telephoto = 48
                default:
                    utilities.preferences.capture.mp.telephoto = 12
                }
            }
        }
        
        func onAppear() {
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
            case 48:
                telephotoMegapixelCount = 1
            default:
                telephotoMegapixelCount = 0
            }
        }
        
        func onDisappear() {
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.megaPixelSwitchNotification.name, object: nil)
            
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
            case 1:
                utilities.preferences.capture.mp.telephoto = 48
            default:
                utilities.preferences.capture.mp.telephoto = 12
            }
        }
    }
}


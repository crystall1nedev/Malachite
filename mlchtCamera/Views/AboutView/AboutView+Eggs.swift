//
//  AboutView+Eggs.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension AboutView {
    struct Eggs: View {
        /// A State variable used for determining whether or not to enable Game Center integration.
        @State private var gamekitSwitch = false
        /// A State variable used for determining whether or not to uncap the exposure slider.
        @State private var exposureUnlimiterSwitch = false
        /// A variable to hold the existing instance of ``MalachiteClassesObject``.
        var utilities = MalachiteClassesObject()
        
        init(
            utilities: MalachiteClassesObject,
        ) {
            self.utilities = utilities
        }
        
        var body: some View {
            Section(header: Text("about.header.special")) {
                MalachiteCellViewUtils(
                    icon: "sun.max",
                    disabled: nil,
                    dangerous: false)
                {
                    Toggle("settings.option.photo.max_exposure", isOn: $exposureUnlimiterSwitch)
                }
                if utilities.preferences.general.gamekit.found {
                    MalachiteCellViewUtils(
                        icon: "gamecontroller",
                        disabled: nil,
                        dangerous: true)
                    {
                        Toggle("", isOn: $gamekitSwitch)
                    }
                }
            }
            .onChange(of: gamekitSwitch) {_ in
                utilities.preferences.general.gamekit.enabled = gamekitSwitch
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.gameCenterEnabledNotification.name, object: nil)
            }
            .onChange(of: exposureUnlimiterSwitch) { _ in
                utilities.debugNSLog("[Settings View] Lol")
                utilities.preferences.capture.unlimitedISO = exposureUnlimiterSwitch
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, object: nil)
            }
            .onAppear() {
                gamekitSwitch = utilities.preferences.general.gamekit.enabled
                exposureUnlimiterSwitch = utilities.preferences.capture.unlimitedISO
            }
            .onDisappear() {
                utilities.preferences.general.gamekit.enabled = gamekitSwitch
                utilities.preferences.capture.unlimitedISO = exposureUnlimiterSwitch
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.exposureLimitNotification.name, object: nil)
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.gameCenterEnabledNotification.name, object: nil)
            }
        }
    }
}

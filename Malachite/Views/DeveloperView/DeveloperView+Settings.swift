//
//  DeveloperView+Settings.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/15/25.
//

import SwiftUI

extension DeveloperView {
    struct Settings: View {
        @State private var debugLoggingUserDefaults = false
        /// A State variable used for determining whether or not to literally break the app.
        @State private var breakApp = false
        
        var utilities: MalachiteClassesObject
        
        init(
            utilities: MalachiteClassesObject
        ) {
            self.utilities = utilities
        }
        
        var body: some View {
            Section {
                MalachiteCellViewUtils(
                    icon: "text.redaction",
                    disabled: nil,
                    dangerous: false)
                {
                    Toggle("developer.option.debug.logging.userdefaults", isOn: $debugLoggingUserDefaults)
                }
                MalachiteCellViewUtils(
                    icon: "iphone.slash",
                    disabled: nil,
                    dangerous: false)
                {
                    Toggle("developer.option.debug.breakapp", isOn: $breakApp)
                }
                MalachiteCellViewUtils(
                    icon: "trash",
                    disabled: nil,
                    dangerous: true)
                {
                    Button {
                        utilities.debugNSLog("[Preferences] Resetting all preferences, relaunch the app to complete!")
                        utilities.preferences.ext.resetPreferences()
                    } label: {
                        if #available(iOS 17.0, *) {
                            Text("developer.option.debug.erase.userdefaults")
                                .foregroundStyle(.red)
                        } else {
                            Text("developer.option.debug.erase.userdefaults")
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
                                Text("developer.option.debug.erase.gamekit")
                                    .foregroundStyle(.red)
                            } else {
                                Text("developer.option.debug.erase.gamekit")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .onAppear {
                debugLoggingUserDefaults = utilities.preferences.debug.logging.preferences
                breakApp = utilities.preferences.debug.breakApp
            }
            .onChange(of: debugLoggingUserDefaults) {_ in
                utilities.preferences.debug.logging.preferences = debugLoggingUserDefaults
            }
            .onChange(of: breakApp) {_ in
                utilities.preferences.debug.breakApp = breakApp
            }
            .onDisappear {
                utilities.preferences.debug.logging.preferences = debugLoggingUserDefaults
                utilities.preferences.debug.breakApp = breakApp
            }
        }
    }
}

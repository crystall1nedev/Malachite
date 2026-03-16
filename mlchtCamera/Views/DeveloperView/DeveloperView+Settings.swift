//
//  DeveloperView+Settings.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/15/25.
//

import SwiftUI

extension DeveloperView {
    struct Settings: View {
        @State private var debugLoggingUnified = false
        @State private var debugLoggingPreferences = false
        @State private var debugLoggingImageProps = false
        @State private var forceCompatibilityRechecks = false
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
                    disabled: utilities.versionType == "INTERNAL",
                    dangerous: false)
                {
                    Toggle("developer.option.debug.logging.unified", isOn: $debugLoggingUnified)
                }
                MalachiteCellViewUtils(
                    icon: "slider.horizontal.3",
                    disabled: nil,
                    dangerous: false)
                {
                    Toggle("developer.option.debug.logging.preferences", isOn: $debugLoggingPreferences)
                }
                MalachiteCellViewUtils(
                    icon: "camera.badge.ellipsis",
                    disabled: nil,
                    dangerous: false)
                {
                    Toggle("developer.option.debug.logging.imageprops", isOn: $debugLoggingImageProps)
                }
                MalachiteCellViewUtils(
                    icon: "checkmark.seal",
                    disabled: nil,
                    dangerous: false)
                {
                    Toggle("developer.option.debug.forcecheck", isOn: $forceCompatibilityRechecks)
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
                            Text("developer.option.debug.erase.preferences")
                                .foregroundStyle(.red)
                        } else {
                            Text("developer.option.debug.erase.preferences")
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
                if utilities.versionType == "INTERNAL" { debugLoggingUnified = true }
                else { debugLoggingUnified = utilities.preferences.debug.logging.unified }
                debugLoggingPreferences = utilities.preferences.debug.logging.preferences
                debugLoggingImageProps = utilities.preferences.debug.logging.imageProps
                forceCompatibilityRechecks = utilities.preferences.debug.compatibility.forcecheck
                breakApp = utilities.preferences.debug.breakApp
            }
            .onChange(of: debugLoggingUnified) {_ in
                utilities.preferences.debug.logging.unified = debugLoggingUnified
            }
            .onChange(of: debugLoggingPreferences) {_ in
                utilities.preferences.debug.logging.preferences = debugLoggingPreferences
            }
            .onChange(of: debugLoggingImageProps) {_ in
                utilities.preferences.debug.logging.imageProps = debugLoggingImageProps
            }
            .onChange(of: forceCompatibilityRechecks) {_ in
                utilities.preferences.debug.compatibility.forcecheck = forceCompatibilityRechecks
            }
            .onChange(of: breakApp) {_ in
                utilities.preferences.debug.breakApp = breakApp
            }
            .onDisappear {
                utilities.preferences.debug.logging.unified = debugLoggingUnified
                utilities.preferences.debug.logging.preferences = debugLoggingPreferences
                utilities.preferences.debug.logging.imageProps = debugLoggingImageProps
                utilities.preferences.debug.breakApp = breakApp
            }
        }
    }
}

//
//  SettingsView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 11/26/23.
//

import SwiftUI

struct SettingsView: View {
    /// A State variable used for determining whether or not debug logging UserDefaults is enabled.
    @State private var debugLoggingUserDefaults = false
    /// A State variable used for determining whether or not to literally break the app.
    @State private var breakApp = false
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
        MalachiteNagivationViewUtils() {
            Form {
                About(utilities: utilities, dismissAction: dismissAction)
                Preview(utilities: utilities, dismissAction: dismissAction)
                Resolution(utilities: utilities, dismissAction: dismissAction)
                Photo(utilities: utilities, dismissAction: dismissAction)
                Watermarking(utilities: utilities, dismissAction: dismissAction)
                UserInterface(utilities: utilities, dismissAction: dismissAction)
                if utilities.versionType == "DEBUG" { DeveloperView.Settings(utilities: utilities) }
            }
            .onAppear { onAppear() }
            .onDisappear { onDisappear() }
            .navigationTitle("view.title.settings")
            .toolbar(content: {
                ToolbarItemGroup(placement: .topBarLeading) {
                    NavigationLink(destination: QuickHelpView(utilities: utilities, dismissAction: dismissAction)) {
                        if #available(iOS 26.0, *) {
                            Image(systemName: "questionmark.circle")
                        } else {
                            Image(systemName: "questionmark.circle").tint(.primary)
                        }
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    MalachiteToolbarUtils(action: self.dismissAction, image: "checkmark", primary: true)
                }
            })
        }
    }
    
    func onAppear() {
        debugLoggingUserDefaults = utilities.preferences.debug.logging.preferences
        breakApp = utilities.preferences.debug.breakApp
    }
    
    func onDisappear() {
        utilities.preferences.debug.logging.preferences = debugLoggingUserDefaults
        utilities.preferences.debug.breakApp = breakApp
    }
}


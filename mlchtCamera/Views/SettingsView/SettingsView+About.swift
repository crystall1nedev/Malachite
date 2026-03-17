//
//  SettingsView+About.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension SettingsView {
    struct About: View {
        /// A State variable used for determining whether or not this view is being presented as a modal.
        var dismissAction: (() -> Void)
        /// A variable to hold the existing instance of ``MalachiteClassesObject``.
        var utilities: MalachiteClassesObject
        var location: Location
        init(
            utilities: MalachiteClassesObject,
            location: Location,
            dismissAction: @escaping (() -> Void)
        ) {
            self.utilities = utilities
            self.location = location
            self.dismissAction = dismissAction
        }
        
        var body: some View {
            Section {
                MalachiteCellViewUtils(
                    icon: "info.circle",
                    disabled: nil,
                    dangerous: false)
                {
                    NavigationLink(destination: AboutView(dismissAction: dismissAction)) {
                        Text("view.title.about")
                    }
                }
                if utilities.versionType == "INTERNAL" {
                    MalachiteCellViewUtils(
                        icon: "checkmark.seal",
                        disabled: nil,
                        dangerous: false)
                    {
                        NavigationLink(destination: CompatibilityView(dismissAction: dismissAction, utilities: utilities)) {
                            Text("view.title.compatibility")
                        }
                    }
                    MalachiteCellViewUtils(
                        icon: "wrench.and.screwdriver",
                        disabled: nil,
                        dangerous: false)
                    {
                        NavigationLink(destination: DeveloperView(dismissAction: dismissAction, utilities: utilities, location: location)) {
                            Text("view.title.developer")
                        }
                    }
                }
            }
        }
    }
}

//
//  SettingsView+Help.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 3/14/24.
//

import SwiftUI

struct QuickHelpView: View {
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
    
    /// A variable used to hold the entire view.
    var body: some View {
        Form {
            About(utilities: utilities)
            Preview()
            Resolution(utilities: utilities)
            Photo()
            Watermarking()
            UserInterface()
            if utilities.versionType == "DEBUG" { Debugging() }
        }
        .navigationTitle("view.title.help")
        .toolbar(content: {
            ToolbarItemGroup(placement: .topBarTrailing) {
                MalachiteToolbarUtils(action: self.dismissAction, image: "checkmark", primary: true)
            }
        })
    }
    
    @available(*, deprecated, message: "This struct is set to be replaced by DeveloperView in the near future.")
    struct Debugging: View {
        /// A variable to hold the debug settings section. Only available with debug and internal builds.
        var body: some View {
            Section(header: Text("developer.header.debug"), footer: Text("developer.footer.debug")) {
                createQuickHelpRow(title: Text("developer.option.debug.logging.unified"), subtitle: Text("developer.detail.debug.logging.unified"))
                createQuickHelpRow(title: Text("developer.option.debug.logging.preferences"), subtitle: Text("developer.detail.debug.logging.preferences"))
                createQuickHelpRow(title: Text("developer.option.debug.logging.imageprops"), subtitle: Text("developer.detail.debug.logging.imageprops"))
                createQuickHelpRow(title: Text("developer.option.debug.breakapp"), subtitle: Text("developer.detail.debug.breakapp"))
                createQuickHelpRow(title: Text("developer.option.debug.erase.preferences"), subtitle: Text("developer.detail.debug.erase.preferences"))
                createQuickHelpRow(title: Text("developer.option.debug.erase.gamekit"), subtitle: Text("developer.detail.debug.erase.gamekit"))
            }
        }
    }
    
    struct createQuickHelpRow: View {
        var title: Text
        var subtitle: Text
        
        init(
            title: Text,
            subtitle: Text
        ) {
            self.title = title
            self.subtitle = subtitle
        }
        
        var body: some View {
            VStack {
                HStack {
                    title
                        .bold()
                    Spacer()
                    
                }
                HStack {
                    subtitle
                        .font(.footnote)
                    Spacer()
                }
            }
        }
    }
}

struct QuickHelpViewDeveloper: View {
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
        Form {
            QuickHelpView.Debugging()
        }
        .navigationTitle("view.title.help")
        .toolbar(content: {
            ToolbarItemGroup(placement: .topBarTrailing) {
                MalachiteToolbarUtils(action: self.dismissAction, image: "checkmark", primary: true)
            }
        })
    }
}

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
            Resolution()
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
    
    @available(*, deprecated, message: "Debugging section is being replaced with the Developer link in the future")
    struct Debugging: View {
        /// A variable to hold the debug settings section. Only available with debug builds.
        var body: some View {
            Section(header: Text("developer.header.debug"), footer: Text("developer.footer.debug")) {
                Builder(title: Text("developer.option.debug.logging.userdefaults"), subtitle: Text("developer.detail.debug.logging.userdefaults")) {}
                Builder(title: Text("developer.option.debug.erase.userdefaults"), subtitle: Text("developer.detail.debug.erase.userdefaults")) {}
                Builder(title: Text("developer.option.debug.erase.gamekit"), subtitle: Text("developer.detail.debug.erase.gamekit")) {}
            }
        }
    }
    
    struct Builder<Content : View>: View {
        var title: Text
        var subtitle: Text
        let content: Content?
        
        init(
            title: Text,
            subtitle: Text,
            @ViewBuilder content: () -> Content?
        ) {
            self.title = title
            self.subtitle = subtitle
            self.content = content() ?? nil
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

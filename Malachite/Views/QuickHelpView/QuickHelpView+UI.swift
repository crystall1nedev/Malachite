//
//  QuickHelpView+UI.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension QuickHelpView {
    struct UserInterface: View {
        /// A variable to hold the user interface settings section.
        var body: some View {
            Section(header: Text("settings.header.ui"), footer: Text("settings.footer.ui")) {
                Builder(title: Text("settings.option.ui.tapgesture"), subtitle: Text("settings.detail.ui.tapgesture")) {}
                Builder(title: Text("settings.option.ui.hiddengestures"), subtitle: Text("settings.detail.ui.hiddengestures")) {}
                Builder(title: Text("settings.option.ui.idletimer"), subtitle: Text("settings.detail.ui.idletimer")) {}
                Builder(title: Text("settings.option.ui.haptics"), subtitle: Text("settings.detail.ui.haptics")) {}
                Builder(title: Text("settings.option.ui.hiddenonlaunch"), subtitle: Text("settings.detail.ui.hiddenonlaunch")) {}
            }
        }
    }
}

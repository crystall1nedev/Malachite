//
//  QuickHelpView+Preview.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension QuickHelpView {
    struct Preview: View {
        /// A variable to hold the preview settings section.
        var body: some View {
            Section(header: Text("settings.header.preview"), footer: Text("settings.footer.preview")) {
                createQuickHelpRow(title: Text("settings.option.preview.aspect_ratio"), subtitle: Text("settings.detail.preview.aspect_ratio")) 
                createQuickHelpRow(title: Text("settings.option.preview.sbtlz"), subtitle: Text("settings.detail.preview.sbtlz"))
                createQuickHelpRow(title: Text("settings.option.preview.zoom_maximum"), subtitle: Text("settings.detail.preview.zoom_maximum"))
            }
        }
    }
}

//
//  QuickHelpView+Photo.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension QuickHelpView {
    struct Photo: View {
        /// A variable to hold the photo settings section.
        var body: some View {
            Section(header: Text("settings.header.photo"), footer: Text("settings.footer.photo")) {
                createQuickHelpRow(title: Text("settings.option.photo.fileformat"), subtitle: Text("settings.detail.photo.fileformat")) 
                createQuickHelpRow(title: Text("settings.option.photo.hdr"), subtitle: Text("settings.detail.photo.hdr"))
                createQuickHelpRow(title: Text("settings.option.photo.continuous"), subtitle: Text("settings.detail.photo.continuous"))
            }
        }
    }
}

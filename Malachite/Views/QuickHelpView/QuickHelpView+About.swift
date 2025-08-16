//
//  QuickHelpView+About.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension QuickHelpView {
    struct About: View {
        var utilities = MalachiteClassesObject()
        
        init(utilities: MalachiteClassesObject ) { self.utilities = utilities }
        
        /// A variable to hold the about section.
        var body: some View {
            Section {
                Builder(title: Text("view.title.about"), subtitle: Text("view.detail.about")) {}
                if utilities.versionType == "INTERNAL" {
                    Builder(title: Text("view.title.compatibility"), subtitle: Text("view.detail.compatibility")) {}
                    Builder(title: Text("view.title.developer"), subtitle: Text("view.detail.developer")) {}
                }
            }
        }
    }
}

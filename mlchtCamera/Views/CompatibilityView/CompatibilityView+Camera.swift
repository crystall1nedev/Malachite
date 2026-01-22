//
//  CompatibilityView+Camera.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/17/25.
//

import SwiftUI

extension CompatibilityView {
    struct Cameras: View {
        /// A variable to hold the existing instance of ``MalachiteClassesObject``.
        var utilities = MalachiteClassesObject()
        
        init(
            utilities: MalachiteClassesObject,
        ) {
            self.utilities = utilities
        }
        
        var body: some View {
            Section(header: Text("compatibility.header.cameras")) {
                MalachiteCompatibilityViewUtils(
                    title: "compatibility.title.ultrawide",
                    available: utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.ultrawide) ? true : false)
                MalachiteCompatibilityViewUtils(
                    title: "compatibility.title.wide",
                    available: utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.wideangle) ? true : false)
                MalachiteCompatibilityViewUtils(
                    title: "compatibility.title.telephoto",
                    available: utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.telephoto) ? true : false)
            }
        }
    }
}

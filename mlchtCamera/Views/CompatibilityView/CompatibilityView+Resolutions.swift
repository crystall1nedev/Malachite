//
//  CompatibilityView+Resolutions.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/17/25.
//

import SwiftUI

extension CompatibilityView {
    struct Resolutions: View {
        /// A variable to hold the existing instance of ``MalachiteClassesObject``.
        var utilities = MalachiteClassesObject()
        
        init(
            utilities: MalachiteClassesObject,
        ) {
            self.utilities = utilities
        }
        
        var body: some View {
            Section(header: Text("compatibility.header.resolution")) {
                if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.ultrawide) {
                    // Ultra wide megapixel capabilities
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.12mp.ultrawide", available: utilities.preferences.compatibility.ultrawide["12"] ?? false)
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.48mp.ultrawide", available: utilities.preferences.compatibility.ultrawide["48"] ?? false)
                }
                if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.wideangle) {
                    // Wide angle megapixel capabilities
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.8mp.wide", available: utilities.preferences.compatibility.wideangle["8"] ?? false)
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.12mp.wide", available: utilities.preferences.compatibility.wideangle["12"] ?? false)
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.48mp.wide", available: utilities.preferences.compatibility.wideangle["48"] ?? false)
                }
                if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.telephoto) {
                    // Telephoto megapixel capabilities
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.12mp.telephoto", available: utilities.preferences.compatibility.telephoto["12"] ?? false)
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.48mp.telephoto", available: utilities.preferences.compatibility.telephoto["48"] ?? false)
                }
            }
        }
    }
}

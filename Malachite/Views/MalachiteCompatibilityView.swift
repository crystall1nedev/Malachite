//
//  MalachiteCompatibilityView.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 10/21/24.
//

import SwiftUI

public struct MalachiteCompatibilityView: View {
    /// A State variable used for determining whether or not this view is being presented as a modal.
    @Binding var presentedAsModal: Bool
    /// A variable to hold the existing instance of ``MalachiteClassesObject``.
    var utilities = MalachiteClassesObject()
    
    public var body: some View {
        MalachiteNagivationViewUtils() {
            Form {
                Section {
                    Text("compatibility.note")
                }
                Section {
                    if utilities.settings.getCountOfDictionary(dictionary: "compatibility.dimensions.ultrawide") > 0 {
                        // Ultra wide megapixel capabilities
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.12mp.ultrawide", available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.ultrawide", key: "12"))
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.48mp.ultrawide", available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.ultrawide", key: "48"))
                    } else {
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.no.ultrawide", available: false)
                    }
                    if utilities.settings.getCountOfDictionary(dictionary: "compatibility.dimensions.wide") > 0 {
                        // Wide angle megapixel capabilities
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.8mp.wide", available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.wide", key: "8"))
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.12mp.wide", available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.wide", key: "12"))
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.48mp.wide", available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.wide", key: "48"))
                    } else {
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.no.wide", available: false)
                    }
                    if utilities.settings.getCountOfDictionary(dictionary: "compatibility.dimensions.telephoto") > 0 {
                        // Telephoto megapixel capabilities
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.12mp.telephoto", available: utilities.settings.getBoolInsideDictionary(dictionary: "compatibility.dimensions.telephoto", key: "12"))
                    } else {
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.no.telephoto", available: false)
                    }
                    
                    // JPEG, HEIF
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.jpeg", available: utilities.settings.defaults.bool(forKey: "compatibility.jpeg"))
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.heif", available: utilities.settings.defaults.bool(forKey: "compatibility.heif"))
                    
                    // HDR
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.hdr", available: utilities.settings.defaults.bool(forKey: "compatibility.hdr"))
                }
            }
            .navigationTitle("view.title.compatibility")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.presentedAsModal = false
                    } label: {
                        Text("action.done_button")
                    }
                }
            })
        }
    }
}

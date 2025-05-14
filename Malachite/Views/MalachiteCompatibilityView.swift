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
                    if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.ultrawide) {
                        // Ultra wide megapixel capabilities
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.12mp.ultrawide", available: utilities.preferences.compatibility.ultrawide["12"] ?? false)
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.48mp.ultrawide", available: utilities.preferences.compatibility.ultrawide["48"] ?? false)
                    } else {
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.no.ultrawide", available: false)
                    }
                    if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.wideangle) {
                        // Wide angle megapixel capabilities
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.8mp.wide", available: utilities.preferences.compatibility.wideangle["8"] ?? false)
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.12mp.wide", available: utilities.preferences.compatibility.wideangle["12"] ?? false)
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.48mp.wide", available: utilities.preferences.compatibility.wideangle["48"] ?? false)
                    } else {
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.no.wide", available: false)
                    }
                    if utilities.preferences.ext.dictionary.isValid(dictionary: utilities.preferences.compatibility.telephoto) {
                        // Telephoto megapixel capabilities
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.12mp.telephoto", available: utilities.preferences.compatibility.telephoto["12"] ?? false)
                    } else {
                        MalachiteCompatibilityViewUtils(title: "compatibility.title.no.telephoto", available: false)
                    }
                    
                    // JPEG, HEIF
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.jpeg", available: utilities.preferences.compatibility.jpeg)
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.heif", available: utilities.preferences.compatibility.heic)
                    
                    // HDR
                    MalachiteCompatibilityViewUtils(title: "compatibility.title.hdr", available: utilities.preferences.compatibility.hdr)
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

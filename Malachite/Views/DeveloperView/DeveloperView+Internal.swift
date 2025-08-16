//
//  DeveloperView+Internal.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension DeveloperView {
    struct InternalSettings: View {
        /// A State variable used for determining how many fingers are used for the settings gesture.
        @State private var settingsGestureFingers = Int()
        
        var utilities: MalachiteClassesObject
        
        init(
            utilities: MalachiteClassesObject
        ) {
            self.utilities = utilities
        }
        
        var body: some View {
            Section(header: Text("developer.header.internal")) {
                MalachiteCellViewUtils(
                    icon: "hand.draw",
                    disabled: nil,
                    dangerous: false)
                {
                    Picker("settings.option.ui.settingsgesture", selection: $settingsGestureFingers) {
                        Text("settings.option.ui.settingsgesture.1")
                            .tag(1)
                        Text("settings.option.ui.settingsgesture.2")
                            .tag(2)
                        Text("settings.option.ui.settingsgesture.3")
                            .tag(3)
                    }
                }
            }
            .onAppear(perform: onAppear)
            .onDisappear(perform: onDisappear)
            .onChange(of: settingsGestureFingers) {_ in
                NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.settingsGestureNotification.name, object: nil)
                
                utilities.preferences.evaintrnl.settingsGesture = settingsGestureFingers
            }
        }
        
        func onAppear() {
            settingsGestureFingers = utilities.preferences.evaintrnl.settingsGesture
        }
        
        func onDisappear() {
            NotificationCenter.default.post(name: MalachiteFunctionUtils.Notifications.settingsGestureNotification.name, object: nil)
            
            utilities.preferences.evaintrnl.settingsGesture = settingsGestureFingers
        }
    }
}

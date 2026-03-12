//
//  Content+Controls.swift
//  mlchtCamera
//
//  Created by Eva Isabella Luna on 3/12/26.
//

import SwiftUI

extension Content {
    struct Controls: View {
        @Binding var isPresented: Bool
        @Binding var hasSeenOnce: Bool
        
        var mainAction: some View {
            Button {
                Connection.shared.sendButtonPress(key: "capture")
            } label: {
                Text("Take picture")
            }
        }
        
        var body: some View {
            if #available(watchOS 11.0, *) {
                mainAction.handGestureShortcut(.primaryAction)
            } else {
                mainAction
            }
            Button {
                Connection.shared.sendButtonPress(key: "settings")
            } label: {
                Text("Open Settings")
            }
            Button {
                Connection.shared.sendButtonPress(key: "flashlight")
            } label: {
                Text("Toggle flashlight")
            }
            Button {
                Connection.shared.sendButtonPress(key: "cameras")
            } label: {
                Text("Switch cameras")
            }
        }
    }
}

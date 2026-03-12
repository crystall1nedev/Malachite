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
                CellViewUtils(
                    icon: "camera.aperture",
                    disabled: nil,
                    dangerous: false)
                { mainAction.handGestureShortcut(.primaryAction) }
            } else {
                CellViewUtils(
                    icon: "camera.aperture",
                    disabled: nil,
                    dangerous: false)
                { mainAction }
            }
            CellViewUtils(
                icon: "gear",
                disabled: nil,
                dangerous: false)
            {
                Button {
                    Connection.shared.sendButtonPress(key: "settings")
                } label: {
                    Text("Open Settings")
                }
            }
            
            CellViewUtils(
                icon: "flashlight.off.fill",
                disabled: nil,
                dangerous: false)
            {
                Button {
                    Connection.shared.sendButtonPress(key: "flashlight")
                } label: {
                    Text("Toggle flashlight")
                }
            }
            
            CellViewUtils(
                icon: "camera.fill",
                disabled: nil,
                dangerous: false)
            {
                Button {
                    Connection.shared.sendButtonPress(key: "cameras")
                } label: {
                    Text("Switch cameras")
                }
            }
        }
    }
}

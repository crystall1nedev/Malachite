//
//  ControlCenterWidgetControl.swift
//  ControlCenterWidget
//
//  Created by Eva Isabella Luna on 10/14/24.
//

import AVFoundation
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct ControlCenterWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "dev.crystall1ne.Malachite.ControlCenterWidget",
            provider: Provider()
        ) { value in
            ControlWidgetButton(action: MalachiteLaunchIntent()) {
                Label("appname.open", systemImage: "camera.aperture")
                    .controlWidgetActionHint("appname.open.action_button")
            }
            .tint(.green)
        }
        .displayName("appname.open")
        .description("appname.open.description")
    }
}

@available(iOS 18.0, *)
// This is a testing control just to be sure I don't break it as a whole
// while I'm messing with LockedCameraCapture.
// It will eventually be integrated into the main control.
struct CameraControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "dev.crystall1ne.Malachite.CameraControlWidget",
            provider: Provider()
        ) { value in
            ControlWidgetButton(action: MalachiteCaptureIntent()) {
                Label("appname.open", systemImage: "camera.shutter.button")
                    .controlWidgetActionHint("appname.open.action_button")
            }
            .tint(.green)
        }
        .displayName("appname.open")
        .description("appname.open.description")
    }
}

@available(iOS 18.0, *)
extension ControlCenterWidget {
    struct Provider: ControlValueProvider {
        var previewValue: Bool { false }; func currentValue() async throws -> Bool { false }
    }
}

@available(iOS 18.0, *)
extension CameraControlWidget {
    struct Provider: ControlValueProvider {
        var previewValue: Bool { false }; func currentValue() async throws -> Bool { false }
    }
}

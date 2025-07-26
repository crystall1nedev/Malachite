//
//  ControlCenterWidgetControl.swift
//  ControlCenterWidget
//
//  Created by Eva Isabella Luna on 10/14/24.
//

import AVFoundation
import SwiftUI
import WidgetKit

@available(iOS 18.0, watchOS 26.0, *)
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

#if targetEnvironment(iOS)
@available(iOS 18.0, *)
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
extension CameraControlWidget {
    struct Provider: ControlValueProvider {
        var previewValue: Bool { false }; func currentValue() async throws -> Bool { false }
    }
}
#endif

@available(iOS 18.0, watchOS 26.0, *)
extension ControlCenterWidget {
    struct Provider: ControlValueProvider {
        var previewValue: Bool { false }; func currentValue() async throws -> Bool { false }
    }
}

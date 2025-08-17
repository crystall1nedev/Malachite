//
//  DeveloperView+DeviceInfo.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/15/25.
//

import SwiftUI
import Foundation

extension DeveloperView {
    struct DeviceInfo: View {
        var utilities: MalachiteClassesObject
        
        init(
            utilities: MalachiteClassesObject
        ) {
            self.utilities = utilities
        }
        
        var body: some View {
            Section(header: Text("developer.header.device"), footer: Text("developer.footer.device")) {
                createBuildInformation(label: "developer.option.device_model", value: utilities.preferences.general.deviceModel)
                createBuildInformation(label: "developer.option.device_version", value: getCurrentOSVersion())
                createBuildInformation(label: "developer.option.device_build", value: getCurrentOSBuild())
            }
        }
        
        @available(*, deprecated, message: "Will be renamed in MalachiteKit.")
        func getCurrentOSVersion() -> String {
            var osVersion: String
            
            // Doing it like this to possibly add "iOS" "macOS" "watchOS" in the future
            osVersion =  ProcessInfo.processInfo.operatingSystemVersion.majorVersion.description
            osVersion += "."
            osVersion += ProcessInfo.processInfo.operatingSystemVersion.minorVersion.description
            osVersion += "."
            osVersion += ProcessInfo.processInfo.operatingSystemVersion.patchVersion.description
            
            return osVersion
        }
        
        @available(*, deprecated, message: "Will be renamed in MalachiteKit.")
        func getCurrentOSBuild() -> String {
            var size = 0
            sysctlbyname("kern.osversion", nil, &size, nil, 0)
            var buffer = [CChar](repeating: 0, count: size)
            let result = sysctlbyname("kern.osversion", &buffer, &size, nil, 0)
            if result == 0 { return String(cString: buffer) }
            
            return "Unknown"
        }
    }
}

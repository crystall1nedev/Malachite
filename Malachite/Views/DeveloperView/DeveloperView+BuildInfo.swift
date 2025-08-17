//
//  DeveloperView+BuildInfo.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/15/25.
//

import SwiftUI

extension DeveloperView {
    struct BuildInfo: View {
        var utilities: MalachiteClassesObject
        
        init(
            utilities: MalachiteClassesObject
        ) {
            self.utilities = utilities
        }
        
        var body: some View {
            Section(header: Text("developer.header.info")) {
                if utilities.versionType == "DEBUG" || utilities.versionType == "INTERNAL" {
                    createBuildInformation(label: "developer.option.version_type", value: utilities.versionType)
                    createBuildInformation(label: "developer.option.version_branch", value: utilities.versionBranch)
                    createBuildInformation(label: "developer.option.version_hash", value: utilities.versionHash)
                    createBuildInformation(label: "developer.option.version_date", value: utilities.versionDate)
                }
                if utilities.versionType == "INTERNAL" {
                    createBuildInformation(label: "developer.option.version_user", value: utilities.versionUser)
                    createBuildInformation(label: "developer.option.version_host", value: utilities.versionHost)
                }
            }
        }
    }
}

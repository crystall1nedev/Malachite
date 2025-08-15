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
                    HStack {
                        Text("developer.option.version_type")
                            .frame(alignment: .leading)
                        Spacer()
                        Text(utilities.versionType)
                            .frame(alignment: .trailing)
                    }
                    HStack {
                        Text("developer.option.version_branch")
                            .frame(alignment: .leading)
                        Spacer()
                        Text(utilities.versionBranch)
                            .frame(alignment: .trailing)
                    }
                    HStack {
                        Text("developer.option.version_hash")
                            .frame(alignment: .leading)
                        Spacer()
                        Text(utilities.versionHash)
                            .frame(alignment: .trailing)
                    }
                    HStack {
                        Text("developer.option.version_date")
                            .frame(alignment: .leading)
                        Spacer()
                        Text(utilities.versionDate)
                            .frame(alignment: .trailing)
                    }
                }
                if utilities.versionType == "INTERNAL" {
                    HStack {
                        Text("developer.option.version_user")
                            .frame(alignment: .leading)
                        Spacer()
                        Text(utilities.versionUser)
                            .frame(alignment: .trailing)
                    }
                    HStack {
                        Text("developer.option.version_host")
                            .frame(alignment: .leading)
                        Spacer()
                        Text(utilities.versionHost)
                            .frame(alignment: .trailing)
                    }
                }
            }
        }
    }
}

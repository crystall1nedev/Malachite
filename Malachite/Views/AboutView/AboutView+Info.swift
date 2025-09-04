//
//  AboutView+Info.swift
//  Malachite
//
//  Created by Eva Isabella Luna on 8/16/25.
//

import SwiftUI

extension AboutView {
    struct Info: View {
        /// A variable to hold the existing instance of ``MalachiteClassesObject``.
        var utilities = MalachiteClassesObject()
        
        @State private var clicks = 0
        
        init(
            utilities: MalachiteClassesObject,
        ) {
            self.utilities = utilities
        }
        
        var body: some View {
            Section(footer: (utilities.versionType == "INTERNAL") ? footer : nil){
                HStack {
                    VStack {
                        HStack {
                            Text("appname")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }
                        HStack {
                            Text("\(utilities.versionMajor).\(utilities.versionMinor).\(utilities.versionMinor)")
                                .font(.footnote)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                    }
                    Spacer()
                    Button {
                        if utilities.versionType == "INTERNAL" {
                            if clicks < 8 { utilities.preferences.ext.showGameKitOptionInAbout(in: &utilities.preferences, clicks: &clicks) }
                        }
                    } label: {
                        if #available(iOS 26.0, *) {
                            Image("icon26")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 80, alignment: .trailing)
                                .clipShape(RoundedRectangle(cornerRadius: 17))
                        } else {
                            Image("icon")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 80, alignment: .trailing)
                                .clipShape(RoundedRectangle(cornerRadius: 17))
                        }
                    }
                }
                Text("about.description")
                Text("about.author_note")
                    .bold()
            }
        }
        
        var footer: some View {
            VStack {
                if utilities.versionType == "DEBUG" {
                    HStack {
                        Text("\(utilities.versionType) - \(utilities.versionHash) - \(utilities.versionDate)")
                            .font(.footnote)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                }
            }
        }
    }
}

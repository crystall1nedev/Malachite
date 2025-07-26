//
//  ContentView.swift
//  MalachiteWatch Watch App
//
//  Created by Eva Isabella Luna on 7/24/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            if #available(watchOS 8.0, *) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            } else {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

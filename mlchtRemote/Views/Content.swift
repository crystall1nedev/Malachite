//
//  ContentView.swift
//  MalachiteWatch Watch App
//
//  Created by Eva Isabella Luna on 7/24/25.
//

// this entire app is buttcheeks

import Foundation
import SwiftUI

struct CompanionWaitView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            if #available(watchOS 8.0, *) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
            }
            Text("")
            Text("Keep mlchtCamera open on your phone to use this app.")
                .padding(10)
                .multilineTextAlignment(.center)
        }
    }
}

struct Content: View {
    @State private var hasSeenOnce = false
    @State private var isPresented = false
    
    var body: some View {
        if #available(watchOS 9.0, *) {
            NavigationStack { guts }
        } else {
            NavigationView { guts }.navigationViewStyle(.stack)
        }
    }
    
    var guts: some View {
        List {
            Controls(isPresented: $isPresented, hasSeenOnce: $hasSeenOnce)
            Debug(isPresented: $isPresented)
        }
        .listStyle(.carousel)
        .onAppear {
            if !hasSeenOnce {
                Connection.shared.bringUpWatchRemote()
                isPresented = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Connection.Notifications.phoneForegroundChanged.name)) { _ in
            if !hasSeenOnce { hasSeenOnce = true }
            if isPresented == !Connection.shared.isPhoneForeground {
                isPresented = Connection.shared.isPhoneForeground
            }
            isPresented = !Connection.shared.isPhoneForeground
        }
        .fullScreenCover(isPresented: $isPresented) {
            CompanionWaitView()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {} label: {
                            ProgressView()
                        }
                        .onTapGesture(count: 5) {
                            isPresented = false
                        }
                    }
                }
        }
    }
}

//
//  ContentView.swift
//  Gatherly
//

import SwiftUI
import LiveViewNative
import LiveViewNativeLiveForm

struct ContentView: View {
    var body: some View {
        #LiveView(
            .automatic(
                development: .localhost(path: "/"),
                production: URL(string: "https://gatherly.qingbo.io")!
            ),
            addons: [
               .liveForm
            ]
        ) {
            ConnectingView()
        } disconnected: {
            DisconnectedView()
        } reconnecting: { content, isReconnecting in
            ReconnectingView(isReconnecting: isReconnecting) {
                content
            }
        } error: { error in
            ErrorView(error: error)
        }
    }
}

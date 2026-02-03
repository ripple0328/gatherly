import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            webView.load(URLRequest(url: url))
        }
    }
}

@main
struct GatherlyVisionPageUpApp: App {
    private let gatherlyURL = URL(string: "https://gatherly.qingbo.us")!

    var body: some Scene {
        WindowGroup {
            WebView(url: gatherlyURL)
        }
    }
}

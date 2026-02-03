import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            webView.load(URLRequest(url: url))
        }
    }
}

@main
struct GatherlyPageUpApp: App {
    private let gatherlyURL = URL(string: "https://gatherly.qingbo.us")!

    var body: some Scene {
        WindowGroup {
            WebView(url: gatherlyURL)
                .ignoresSafeArea()
        }
    }
}

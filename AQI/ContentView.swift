//
//  ContentView.swift
//  AQI
//
//  Created by ZHOU QUAN on 2020/12/14.
//

import SwiftUI
import SafariServices

struct ContentView: View {
    var body: some View {
        SafariView(url:URL(string: "http://aqicn.org/city/beijing/cn/")!)
    }
}

struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }

}

//
//  Tap_to_Pay_Sample_AppApp.swift
//  Tap to Pay Sample App
//
//  Created by Allan Cheng on 12/23/25.
//

import SwiftUI

@main
struct Tap_to_Pay_Sample_AppApp: App {
    @State private var deeplinkURL: URL?

    var body: some Scene {
        WindowGroup {
            ContentView(deeplinkURL: $deeplinkURL)
                .onOpenURL { url in
                    deeplinkURL = url
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    deeplinkURL = activity.webpageURL
                }
        }
    }
}

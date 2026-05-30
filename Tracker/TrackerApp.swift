//
//  TrackerApp.swift
//  Tracker
//
//  Created by Juned Namaji on 30/05/26.
//

import SwiftUI
import FirebaseCore

@main
struct TrackerApp: App {
    private let dependencyContainer: AppDependencyContainer

    init() {
        FirebaseApp.configure()
        dependencyContainer = .live()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.appDependencies, dependencyContainer)
        }
    }
}

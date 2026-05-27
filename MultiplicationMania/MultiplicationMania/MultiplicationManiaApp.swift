//
//  MultiplicationManiaApp.swift
//  MultiplicationMania
//
//  Created by Jay Hanley on 5/25/26.
//

import SwiftUI

@main
struct MultiplicationManiaApp: App {
    @StateObject var settings = GameSettings()
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(settings)
        }
    }
}

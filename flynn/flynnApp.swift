//
//  flynnApp.swift
//  flynn
//
//  Created by David Doswell on 11/15/24.
//

import SwiftUI

@main
struct flynnApp: App {
  @StateObject private var appState: AppState
  @StateObject private var autoProgressManager: AutoProgressManager
  
  init() {
    let container = Container()
    self._appState = StateObject(wrappedValue: AppState(container: container))
    self._autoProgressManager = StateObject(wrappedValue: AutoProgressManager())
  }
  
  var body: some Scene {
    WindowGroup {
      LaunchView()
        .environmentObject(appState)
        .environmentObject(autoProgressManager)
    }
  }
}

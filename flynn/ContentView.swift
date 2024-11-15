//
//  ContentView.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import SwiftUI

struct ContentView: View {
  @Environment(\.scenePhase) private var scenePhase
  @EnvironmentObject private var appState: AppState
  @EnvironmentObject private var autoProgressManager: AutoProgressManager
  
  var body: some View {
    Group {
      if autoProgressManager.currentStep == .create {
        CreateView()
          .transition(.opacity)
      } else {
        OnboardingView()
          .environmentObject(autoProgressManager)
      }
    }
    .animation(.easeInOut(duration: 0.3), value: autoProgressManager.currentStep)
    .onChange(of: scenePhase) { _, newPhase in
      if newPhase == .inactive {
        appState.saveState()
      }
    }
  }
}

//
//  OnboardingView.swift
//  hairmax
//
//  Created by David Doswell on 11/9/24.
//

import SwiftUI

struct OnboardingView: View {
  @EnvironmentObject private var appState: AppState
  @EnvironmentObject private var manager: AutoProgressManager
  @State private var path = NavigationPath()
  
  var body: some View {
    NavigationStack(path: $path) {
      viewForStep()
        .navigationDestination(for: OnboardingStep.self) { step in
          viewForStep(step: step)
            .navigationBarBackButtonHidden(true)
        }
        .onChange(of: manager.currentStep) { _, newStep in
          path.append(newStep)
        }
    }
  }
  
  @ViewBuilder
  func viewForStep(step: OnboardingStep? = nil) -> some View {
    let currentStep = step ?? manager.currentStep
    switch currentStep {
    case .welcome:
      WelcomeView()
        .environmentObject(manager)
    case .about:
      AboutView()
        .environmentObject(manager)
    case .goals:
      GoalsView()
        .environmentObject(manager)
    case .products:
      ProductsView()
        .environmentObject(manager)
    case .howTo:
      HowToView()
        .environmentObject(manager)
    case .create:
      CreateView()
        .environmentObject(manager)
    }
  }
}

//
//  AppState.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
  private let defaults = UserDefaults.standard
  
  // MARK: - Published Properties
  @Published var onboardingManager: AutoProgressManager
  
  // MARK: - View Models
  var analysisViewModel: AnalysisViewModel
  
  // MARK: - Initialization
  init(container: Container) {
    self.onboardingManager = AutoProgressManager()
    self.analysisViewModel = AnalysisViewModel(analysisManager: container.analysisManager)
  }
  
  // MARK: - State Management
  func saveState() {
    defaults.synchronize()
  }
}

//
//  AutoProgressManager.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import Foundation
import SwiftUI

// MARK: - Input Protocols
protocol ProgressionInput {}

struct GoalsInput: ProgressionInput {  
  enum HairGoal: String, CaseIterable {
    case preventLoss
    case regrowth
    case maintenance
  }
  let selectedGoals: [HairGoal]
}

struct ProductInput: ProgressionInput {
  enum ProductPreference: String, CaseIterable {
    case natural
    case prescription
    case combination
  }
  let preference: ProductPreference
}

// MARK: - Onboarding Steps Enum
enum OnboardingStep: String, CaseIterable {
  case welcome
  case about
  case goals
  case products
  case howTo
  case create
}

@MainActor
class AutoProgressManager: ObservableObject {
  @Published private(set) var currentStep: OnboardingStep
  @Published private(set) var isLoading = false
  @Published var error: String?
  
  private let defaults = UserDefaults.standard
  private let currentStepKey = "currentOnboardingStep"
  
  init() {
    currentStep = OnboardingStep(rawValue: defaults.string(forKey: currentStepKey) ?? "") ?? .welcome
  }
  
  func moveToNextStep() {
    guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
          currentIndex + 1 < OnboardingStep.allCases.count else {
      return
    }
    currentStep = OnboardingStep.allCases[currentIndex + 1]
    saveProgress()
  }
  
  private func saveProgress() {
    defaults.set(currentStep.rawValue, forKey: currentStepKey)
  }
  
  func resetProgress() {
    currentStep = .welcome
    saveProgress()
    clearOnboardingData()
  }
  
  func updateAndProgress(input: ProgressionInput) async -> Result<Void, Error> {
    isLoading = true
    defer { isLoading = false }
    
    do {
      try await update(input: input)
      moveToNextStep()
      return .success(())
    } catch {
      self.error = error.localizedDescription
      return .failure(error)
    }
  }
  
  private func update(input: ProgressionInput) async throws {
    switch input {
    case let input as GoalsInput:
      defaults.set(input.selectedGoals.map { $0.rawValue }, forKey: "onboardingGoals")
      
    case let input as ProductInput:
      defaults.set(input.preference.rawValue, forKey: "onboardingProductPreference")
      
    default:
      throw NSError(domain: "AutoProgressManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid input type"])
    }
  }
  
  func getGoals() -> [GoalsInput.HairGoal]? {
    guard let goalStrings = defaults.array(forKey: "onboardingGoals") as? [String] else { return nil }
    return goalStrings.compactMap { GoalsInput.HairGoal(rawValue: $0) }
  }
  
  func getProductPreference() -> ProductInput.ProductPreference? {
    guard let preferenceString = defaults.string(forKey: "onboardingProductPreference") else { return nil }
    return ProductInput.ProductPreference(rawValue: preferenceString)
  }
  
  private func clearOnboardingData() {
    let keys = [
      "onboardingGoals",
      "onboardingProductPreference"
    ]
    keys.forEach { defaults.removeObject(forKey: $0) }
  }
}

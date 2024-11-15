//
//  AnalysisViewModel.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import Foundation
import SwiftUI

@MainActor
final class AnalysisViewModel: ObservableObject {
  private let analysisManager: AnalysisManagerProtocol
  @Published var analyses: [Analysis] = []
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  @Published var currentAnalysis: Analysis?
  
  init(analysisManager: AnalysisManagerProtocol) {
    self.analysisManager = analysisManager
  }
  
  func analyze(image: UIImage, imageData: Data) async {
    isLoading = true
    errorMessage = nil
    currentAnalysis = nil
    
    do {
      let analysis = try await analysisManager.analyzeImage(imageData: imageData)
      
      // Validate analysis results
      guard !analysis.timeline.isEmpty,
            !analysis.currentStage.isEmpty,
            !analysis.patternDetails.isEmpty else {
        errorMessage = "Could not analyze image properly"
        return
      }
      
      let imageURL = try await analysisManager.uploadTempImage(imageData)
      
      var finalAnalysis = analysis
      finalAnalysis.imageURL = imageURL
      currentAnalysis = finalAnalysis
      
    } catch {
      errorMessage = error.localizedDescription
    }
    
    isLoading = false
  }
  
  // We'll add these back post-paywall
  // func fetchAnalyses() async { ... }
  // func saveAnalysis(_ analysis: Analysis) async throws { ... }
}

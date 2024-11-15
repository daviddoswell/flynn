//
//  CreateViewModel.swift
//  flynnapp
//
//  Created by David Doswell on 11/15/24.
//

import Foundation

@MainActor
final class CreateViewModel: ObservableObject {
  private let analysisManager: AnalysisManagerProtocol
  @Published var analyses: [Analysis] = []
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  
  init(manager: AnalysisManagerProtocol) {
    self.analysisManager = manager
  }
  
//  func fetchAnalyses() async {
//    isLoading = true
//    do {
//      let fetched = try await analysisManager.fetchAnalyses()
//      analyses = fetched
//    } catch {
//      errorMessage = error.localizedDescription
//    }
//    isLoading = false
//  }
//  
//  func delete(_ analysis: Analysis) async throws {
//    try await analysisManager.delete(analysis)
//    await fetchAnalyses()
//  }
}

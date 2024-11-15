//
//  AnalysisManager.swift
//  hairmax
//
//  Created by David Doswell on 10/27/24.
//

import Foundation

enum AnalysisError: LocalizedError {
  case imageProcessingFailed
  case userNotAuthenticated
  case analysisParseError
  case uploadFailed
  case saveFailed
  case emptyResponse
  case missingRequiredField
  case missingPatternDetails
  case invalidFormat
  
  var errorDescription: String? {
    switch self {
    case .imageProcessingFailed:
      return "Failed to process image"
    case .userNotAuthenticated:
      return "User not authenticated"
    case .analysisParseError:
      return "Failed to analyze image"
    case .uploadFailed:
      return "Failed to upload image"
    case .saveFailed:
      return "Failed to save analysis"
    case .emptyResponse:
      return "Empty response"
    case .missingRequiredField:
      return "Missing required field"
    case .missingPatternDetails:
      return "Missing pattern details"
    case .invalidFormat:
      return "Invalid format"
    }
  }
}

protocol AnalysisManagerProtocol {
  func analyzeImage(imageData: Data) async throws -> Analysis
  func uploadTempImage(_ imageData: Data) async throws -> String
}

final class AnalysisManager: AnalysisManagerProtocol {
  private let imageAnalysisService: ImageAnalysisServiceProtocol
  private let networkService: NetworkServiceProtocol
  
  init(networkService: NetworkServiceProtocol,
       imageAnalysisService: ImageAnalysisServiceProtocol) {
    self.networkService = networkService
    self.imageAnalysisService = imageAnalysisService
  }
  
  func analyzeImage(imageData: Data) async throws -> Analysis {
    let tempImagePath = "temp/\(UUID().uuidString).jpg"
    return try await imageAnalysisService.analyzeImage(
      tempImagePath,
      imageData: imageData,
      userId: UUID()
    )
  }
  
  func uploadTempImage(_ imageData: Data) async throws -> String {
    let path = "temp/\(UUID().uuidString).jpg"
    return try await networkService.uploadImage(imageData, path: path)
  }
  
  // We'll add these back post-paywall
  // func saveUser(_ user: User) async throws
  // func fetchUser(for userId: UUID) async throws -> User
  // func saveAnalysis(_ analysis: Analysis) async throws
  // func fetchAnalyses() async throws -> [Analysis]
  // func delete(_ analysis: Analysis) async throws
}

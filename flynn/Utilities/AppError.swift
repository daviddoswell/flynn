//
//  AppError.swift
//  hairmax
//
//  Created by David Doswell on 10/22/24.
//

import Foundation

enum AppError: LocalizedError {
  case imageProcessing
  case networkError(String)
  case serverError(String)
  case unknown
  
  var errorDescription: String? {
    switch self {
    case .imageProcessing:
      "Failed to process image"
    case .networkError(let message):
      "Network error: \(message)"
    case .serverError(let message):
      "Server error: \(message)"
    case .unknown:
      "An unknown error occurred"
    }
  }
}

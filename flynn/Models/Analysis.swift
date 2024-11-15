//
//  Analysis.swift
//  flynn
//
//  Created by David Doswell on 11/15/24.
//

import SwiftUI

// MARK: - Analysis Model
struct Analysis: Codable, Identifiable, Sendable {
  var id: UUID
  var userId: UUID
  var imageURL: String
  var timeline: String
  var currentStage: String
  var patternDetails: [PatternDetail]
  var riskLevel: RiskLevel
  var createdAt: Date
  
  var immediateActions: [ActionDetail]?
  var medicalOptions: [ActionDetail]?
  var lifestyleChanges: [ActionDetail]?
  
  enum CodingKeys: String, CodingKey {
    case id
    case userId = "user_id"
    case imageURL = "image_url"
    case timeline
    case currentStage = "current_stage"
    case patternDetails = "pattern_details"
    case riskLevel = "risk_level"
    case createdAt = "created_at"
    case immediateActions = "immediate_actions"
    case medicalOptions = "medical_options"
    case lifestyleChanges = "lifestyle_changes"
  }
}

// MARK: - PatternDetail Model
struct PatternDetail: Codable {
  var area: String
  var description: String
}

// MARK: - ActionDetail Model
struct ActionDetail: Codable {
  var title: String
  var description: String
  var timeframe: String?
  var urgency: Urgency?
}

// MARK: - RiskLevel and Urgency Enums
enum RiskLevel: String, Codable {
  case high = "High"
  case medium = "Medium"
  case low = "Low"
}

enum Urgency: String, Codable {
  case high = "High"
  case medium = "Medium"
  case low = "Low"
}

// MARK: - Analysis Extension for Similarity Check
extension Analysis {
  func isSimilarTo(_ other: Analysis) -> Bool {
    let timelineMatch = self.timeline == other.timeline
    let riskMatch = self.riskLevel == other.riskLevel
    
    let stageWords = Set(self.currentStage.lowercased().split(separator: " "))
    let otherStageWords = Set(other.currentStage.lowercased().split(separator: " "))
    let commonWords = stageWords.intersection(otherStageWords)
    let stageSimilarity = Double(commonWords.count) / Double(max(stageWords.count, otherStageWords.count))
    
    return timelineMatch && riskMatch && stageSimilarity > 0.7
  }
}

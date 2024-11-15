//
//  ImageAnalysisService.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import Foundation

protocol ImageAnalysisServiceProtocol {
  func analyzeImage(_ imageURL: String, imageData: Data, userId: UUID) async throws -> Analysis
}

final class ImageAnalysisService: ImageAnalysisServiceProtocol {
  private let apiKey: String
  private let networkService: NetworkServiceProtocol
  private let baseURL = "https://api.anthropic.com/v1/messages"
  private let modelVersion = "claude-3-opus-20240229"
  
  init(apiKey: String, networkService: NetworkServiceProtocol) {
    self.apiKey = apiKey
    self.networkService = networkService
  }
  
  func analyzeImage(_ imageURL: String, imageData: Data, userId: UUID) async throws -> Analysis {
    let request = try prepareRequest(with: imageData)
    return try await performAnalysis(with: request, imageURL: imageURL, userId: userId)
  }
  
  private func prepareRequest(with imageData: Data) throws -> URLRequest {
    var request = URLRequest(url: URL(string: baseURL)!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
    request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
    request.setValue(modelVersion, forHTTPHeaderField: "anthropic-model-version")
    
    let base64Image = imageData.base64EncodedString()
    let content: [String: Any] = [
      "model": modelVersion,
      "messages": [
        [
          "role": "user",
          "content": [
            [
              "type": "image",
              "source": [
                "type": "base64",
                "media_type": "image/jpeg",
                "data": base64Image
              ]
            ],
            [
              "type": "text",
              "text": analysisPrompt
            ]
          ]
        ]
      ],
      "max_tokens": 1024,
      "temperature": 0.7
    ]
    
    request.httpBody = try JSONSerialization.data(withJSONObject: content)
    return request
  }
  
  private func performAnalysis(with request: URLRequest, imageURL: String, userId: UUID) async throws -> Analysis {
    let (data, response) = try await URLSession.shared.data(for: request)
    
    print("Claude Response:")
    print(String(data: data, encoding: .utf8) ?? "Could not decode response")
    
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
      throw ImageAnalysisError.apiError
    }
    
    let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
    return try parseAnalysisResponse(claudeResponse, imageURL: imageURL, userId: userId)
  }
  
  private func parseAnalysisResponse(_ response: ClaudeResponse, imageURL: String, userId: UUID) throws -> Analysis {
    
    let analysisText = response.content.first?.text ?? ""
    
    let cleanedText = analysisText
      .replacingOccurrences(of: "Match\\(anyRegexOutput:.*?\\)", with: "", options: .regularExpression)
      .replacingOccurrences(of: "\\.\\.<Swift\\.String\\.Index.*?\\)", with: "", options: .regularExpression)
      .replacingOccurrences(of: "Age Age", with: "Age")
      .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard !analysisText.isEmpty else {
      throw AnalysisError.emptyResponse
    }
    
    let timeline = try extractTimeline(from: cleanedText).unwrapOrThrow(AnalysisError.missingRequiredField)
    
    let currentStage = extractCurrentStage(from: analysisText)
    guard !currentStage.isEmpty else {
      throw AnalysisError.missingRequiredField
    }
    
    let patternDetails = extractPatternDetails(from: analysisText)
    let expectedAreas = ["Crown", "Temples", "Overall"]
    let missingAreas = expectedAreas.filter { area in
      !patternDetails.contains { $0.area.caseInsensitiveCompare(area) == .orderedSame }
    }
    if !missingAreas.isEmpty {
      throw AnalysisError.missingPatternDetails
    }
    
    let riskLevel = extractRiskLevel(from: analysisText)
    let validatedRiskLevel = try RiskLevel(rawValue: riskLevel).unwrapOrThrow(AnalysisError.invalidFormat)
    
    print("\nParsed fields:")
    print("Timeline: \(timeline)")
    print("Current Stage: \(currentStage)")
    print("Risk Level: \(riskLevel)")
    print("\nPattern Details:")
    patternDetails.forEach { detail in
      print("- \(detail.area): \(detail.description)")
    }
    print("\nPremium Content:")
    print("Immediate Actions:")
    extractImmediateActions(from: analysisText).forEach { action in
      print("- Title: \(action.title)")
      print("  Description: \(action.description)")
      print("  Timeframe: \(action.timeframe ?? "none")")
      print("  Urgency: \(action.urgency?.rawValue ?? "none")")
    }
    
    return Analysis(
      id: UUID(),
      userId: userId,
      imageURL: imageURL,
      timeline: timeline,
      currentStage: currentStage,
      patternDetails: patternDetails,
      riskLevel: validatedRiskLevel,
      createdAt: Date(),
      immediateActions: extractImmediateActions(from: analysisText),
      medicalOptions: extractMedicalOptions(from: analysisText),
      lifestyleChanges: extractLifestyleChanges(from: analysisText)
    )
  }
}

private extension ImageAnalysisService {
  var analysisPrompt: String {
        """
        You are a supportive hair analysis assistant helping people understand and track their hair health journey. Our goal is to help users take proactive steps towards maintaining their hair health by providing educational insights and encouraging them to seek professional care when needed.
        
            Please analyze this hair image to help provide the user with a constructive assessment in exactly this format:
        
            Timeline: Age [estimated age for potential changes, being conservative and optimistic]
        
            Current Stage: [supportive description of current visible patterns, focusing on opportunities for improvement]
        
            Pattern Details:
            - Crown: [objective description of crown area]
            - Temples: [objective description of temple area]
            - Overall: [balanced description of general hair health]
        
            Risk Level: [High/Medium/Low] based on visible patterns, erring on the side of early awareness
        
            For subscribers, provide constructive action steps:
        
            Immediate Actions:
            - Title: [encouraging action title]
              Description: [supportive explanation focusing on hair health]
              Timeframe: [realistic timeline]
              Urgency: [High/Medium/Low]
        
            Medical Options:
            - Title: [professional care option]
              Description: [educational explanation]
              Timeframe: [appropriate timeline for consultation]
              Urgency: [High/Medium/Low]
        
            Lifestyle Changes:
            - Title: [positive lifestyle modification]
              Description: [explanation of benefits]
              Timeframe: [achievable timeline]
              Urgency: [High/Medium/Low]
        
            Note: This analysis is meant to empower users with information while encouraging proper medical consultation. The goal is early awareness and proactive care.
        """
  }
  
  func extractPatternDetails(from text: String) -> [PatternDetail] {
    guard let detailsMatch = text.range(of: AnalysisPatterns.patternDetails, options: .regularExpression) else {
      return []
    }
    
    let detailsText = String(text[detailsMatch])
    return detailsText.components(separatedBy: "\n").compactMap { line in
      let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
      guard trimmed.hasPrefix("- "),
            let colonIndex = trimmed.firstIndex(of: ":") else {
        return nil
      }
      
      let areaStart = trimmed.index(trimmed.startIndex, offsetBy: 2)
      let area = String(trimmed[areaStart..<colonIndex]).trimmingCharacters(in: .whitespaces)
      let descriptionStart = trimmed.index(after: colonIndex)
      let description = String(trimmed[descriptionStart...]).trimmingCharacters(in: .whitespaces)
      
      return PatternDetail(area: area, description: description)
    }
  }
  
  func extractTimeline(from text: String) -> String? {
    let pattern = #"Timeline:\s*Age\s*(\d+[-–]\d+|\d+)"#
    
    guard let range = text.range(of: pattern, options: .regularExpression),
          let match = text[range].firstMatch(of: /\d+(?:[-–]\d+)?/) else {
      return nil
    }
    return String(match.0)
  }
  
  func extractCurrentStage(from text: String) -> String {
    guard let range = text.range(of: AnalysisPatterns.stage, options: .regularExpression),
          let colonIndex = text[range].firstIndex(of: ":") else {
      return ""
    }
    let startIndex = text[range].index(after: colonIndex)
    return String(text[range][startIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  func extractRiskLevel(from text: String) -> String {
    guard let range = text.range(of: AnalysisPatterns.risk, options: .regularExpression),
          let match = text[range].firstMatch(of: /(High|Medium|Low)/) else {
      return ""
    }
    return String(match.0)
  }
}

private extension ImageAnalysisService {
  func extractActionDetails(from text: String, section: String) -> [ActionDetail] {
    let pattern = "\(section):(?:\\s|\\n)*((?:- .+\\n?)*)"
    
    guard let sectionMatch = text.range(of: pattern, options: .regularExpression) else {
      return []
    }
    
    let sectionText = String(text[sectionMatch])
    return sectionText.components(separatedBy: "- Title:").compactMap { itemText in
      let trimmed = itemText.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else { return nil }
      
      let title = extractField(from: trimmed, fieldName: "Title")
      let description = extractField(from: trimmed, fieldName: "Description")
      let timeframe = extractField(from: trimmed, fieldName: "Timeframe")
      let urgencyText = extractField(from: trimmed, fieldName: "Urgency")
      
      guard !title.isEmpty, !description.isEmpty else { return nil }
      
      let urgency = urgencyText.isEmpty ? nil : Urgency(rawValue: urgencyText)
      
      return ActionDetail(
        title: title,
        description: description,
        timeframe: timeframe.isEmpty ? nil : timeframe,
        urgency: urgency
      )
    }
  }
  
  private func extractField(from text: String, fieldName: String) -> String {
    let pattern = "\(fieldName):\\s*([^\\n]+)"
    guard let range = text.range(of: pattern, options: .regularExpression),
          let colonIndex = text[range].firstIndex(of: ":") else {
      return ""
    }
    let startIndex = text[range].index(after: colonIndex)
    return String(text[range][startIndex...])
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  func extractImmediateActions(from text: String) -> [ActionDetail] {
    extractActionDetails(from: text, section: "Immediate Actions")
  }
  
  func extractMedicalOptions(from text: String) -> [ActionDetail] {
    extractActionDetails(from: text, section: "Medical Options")
  }
  
  func extractLifestyleChanges(from text: String) -> [ActionDetail] {
    extractActionDetails(from: text, section: "Lifestyle Changes")
  }
}

private extension ImageAnalysisService {
  enum AnalysisPatterns {
    static let timeline = #"Timeline:\s*Age\s*(\d+(?:-\d+)?)"#
    static let stage = #"Current Stage:\s*([^\n]+)"#
    static let patternDetails = #"Pattern Details:(?:\s|\n)*((?:- .+\n?)*)"#
    static let risk = #"Risk Level:\s*(High|Medium|Low)"#
  }
}

extension String {
  func extractMatches(for pattern: String) throws -> String? {
    let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
    if let match = regex.firstMatch(in: self, options: [], range: NSRange(self.startIndex..., in: self)),
       let range = Range(match.range(at: 1), in: self) {
      return String(self[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    return nil
  }
}

enum ImageAnalysisError: Error {
  case apiError
  case parsingError
  case invalidResponse
}

struct ClaudeResponse: Decodable {
  var content: [MessageContent]
}

struct MessageContent: Decodable {
  var text: String
}

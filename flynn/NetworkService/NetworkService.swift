//
//  NetworkService.swift
//  flynn
//
//  Created by David Doswell on 11/15/24.
//

import Foundation
import Supabase

enum NetworkError: Error {
  case noData
  case decodingError(Error)
  case httpError(statusCode: Int, message: String)
  case unauthorized
  case unexpectedError(Error)
  case userNotFound
  case failedToCreateUser(String)
  case failedToFetchUser(String)
}

protocol NetworkServiceProtocol {
  func fetchUser(from tableName: String, userId: UUID) async throws -> User
  func uploadImage(_ imageData: Data, path: String) async throws -> String
  func insert<T: Codable>(_ value: T, table: String) async throws
  func fetch<T: Codable>(from table: String) async throws -> [T]
  func delete(_ analysis: Analysis) async throws
}

class NetworkService: NetworkServiceProtocol {
  private let supabaseClient: SupabaseClient
  
  init(supabaseClient: SupabaseClient) {
    self.supabaseClient = supabaseClient
  }
  
  // MARK: - Users
  func createUser(_ user: User) async throws {
    print("Attempting to create user with id: \(user.id)")
    do {
      try await supabaseClient
        .from("users")
        .insert(user)
        .execute()
      print("Successfully created user in Supabase")
    } catch {
      print("Failed to create user: \(error.localizedDescription)")
      throw NetworkError.failedToCreateUser(error.localizedDescription)
    }
  }
  
  func uploadProfileImage(_ imageData: Data, userId: UUID) async throws -> String {
    let path = "\(userId.uuidString)/profile.jpg"
    print("Attempting to upload profile image for path: \(path)")
    
    do {
      try await supabaseClient.storage
        .from("users")
        .upload(
          path,
          data: imageData,
          options: FileOptions(contentType: "image/jpeg")
        )
      print("Successfully uploaded image")
      
      let publicURL = try supabaseClient.storage
        .from("users")
        .getPublicURL(path: path)
        .absoluteString
        .replacingOccurrences(of: "([^:])//+", with: "$1/", options: .regularExpression)
      
      print("Generated public URL: \(publicURL)")
      return publicURL
    } catch {
      print("Failed to upload profile image: \(error)")
      throw error
    }
  }
  
  func updateProfileImage(_ imageData: Data, userId: UUID) async throws -> String {
    let path = "\(userId.uuidString)/profile.jpg"
    print("Attempting to update profile image for path: \(path)")
    
    do {
      _ = try await supabaseClient.storage
        .from("users")
        .remove(paths: [path])
      
      print("Removed existing image if it existed")
      
      try await supabaseClient.storage
        .from("users")
        .upload(
          path,
          data: imageData,
          options: FileOptions(contentType: "image/jpeg")
        )
      print("Successfully uploaded new image")
      
      let publicURL = try supabaseClient.storage
        .from("users")
        .getPublicURL(path: path)
        .absoluteString
        .replacingOccurrences(of: "([^:])//+", with: "$1/", options: .regularExpression)
      
      print("Generated new public URL: \(publicURL)")
      return publicURL
    } catch {
      print("Failed to update profile image: \(error)")
      throw error
    }
  }
  
  func fetchUser<T: Codable & Identifiable>(from tableName: String, userId: UUID) async throws -> T {
    let query = supabaseClient
      .from(tableName)
      .select()
      .eq("id", value: userId.uuidString)
      .single()
    
    do {
      let response = try await query.execute()
      
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      
      return try decoder.decode(T.self, from: response.data)
    } catch let error as PostgrestError where error.code == "PGRST116" {
      throw NetworkError.userNotFound
    } catch {
      throw NetworkError.failedToFetchUser(error.localizedDescription)
    }
  }
  
  // MARK: - Analyses
  func uploadImage(_ imageData: Data, path: String) async throws -> String {
    try await supabaseClient.storage
      .from("analyses")
      .upload(
        path,
        data: imageData,
        options: FileOptions(contentType: "image/jpeg")
      )
    
    var publicURL = try supabaseClient.storage
      .from("analyses")
      .getPublicURL(path: path)
      .absoluteString
    
    publicURL = publicURL.replacingOccurrences(of: "([^:])//+", with: "$1/", options: .regularExpression)
    
    return publicURL
  }
  
  func insert<T: Codable & Sendable>(_ value: T, table: String) async throws {
    try await supabaseClient
      .from(table)
      .insert(value)
      .execute()
  }
  
  func fetch<T: Codable>(from table: String) async throws -> [T] {
    
    let userId = try await supabaseClient.auth.session.user.id
    let query = supabaseClient
      .from(table)
      .select()
      .eq("user_id", value: userId)
      .order("created_at", ascending: false)
    
    let response = try await query.execute()
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    do {
      let data = try decoder.decode([T].self, from: response.data)
      return data
    } catch {
      throw error
    }
  }
  
  func delete(_ analysis: Analysis) async throws {
    let path = analysis.imageURL.components(separatedBy: "/analyses/").last ?? ""
    _ = try await supabaseClient.storage
      .from("analyses")
      .remove(paths: [path])
    
    try await supabaseClient
      .from("analyses")
      .delete()
      .eq("id", value: analysis.id)
      .execute()
    
    ImageCache.shared.remove(analysis.imageURL)
  }
}

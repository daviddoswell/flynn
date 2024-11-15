//
//  AuthManager.swift
//  hairmax
//
//  Created by David Doswell on 10/31/24.
//

import Foundation
import AuthenticationServices
import Supabase

protocol AuthManagerProtocol {
  func signInWithApple() async throws -> User
}

class AuthManager: NSObject, AuthManagerProtocol {
  private let supabaseClient: SupabaseClient
  private let appleManager: AppleManager
  
  init(supabaseClient: SupabaseClient) {
    self.supabaseClient = supabaseClient
    self.appleManager = AppleManager()
    super.init()
  }
  
  // MARK: - Sign in with Apple
  func signInWithApple() async throws -> User {
    let token = try await appleManager.signIn()
    let result = try await supabaseClient.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: token))
    return mapToAppUser(result.user)
  }
  
  private func mapToAppUser(_ authUser: Auth.User) -> User {
    return User(
      id: authUser.id,
      username: nil,
      firstName: nil,
      lastName: nil,
      birthYear: nil,
      city: nil,
      state: nil,
      hasSubscribed: false
    )
  }
}

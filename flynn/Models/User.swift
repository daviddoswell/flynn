//
//  User.swift
//  flynn
//
//  Created by David Doswell on 11/15/24.
//

import Foundation

struct User: Codable, Identifiable, Sendable {
  var id: UUID
  var username: String?
  var firstName: String?
  var lastName: String?
  var profileImageURL: String?
  var birthYear: Int?
  var city: String?
  var state: String?
  var hasSubscribed: Bool
  
  enum CodingKeys: String, CodingKey {
    case id
    case username
    case firstName = "first_name"
    case lastName = "last_name"
    case profileImageURL = "profile_image_url"
    case birthYear = "birth_year"
    case city
    case state
    case hasSubscribed = "has_subscribed"
  }
}

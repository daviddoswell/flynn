//
//  CustomHeader.swift
//  hairmax
//
//  Created by David Doswell on 11/5/24.
//

import SwiftUI

struct CustomHeader: View {
  let title: String
  let onSettingsTap: () -> Void
  let onSignOutTap: () -> Void
  
  var body: some View {
    HStack {
      Text(title)
        .font(.system(size: 30, weight: .heavy, design: .rounded))
        .foregroundStyle(.white.opacity(0.8))
      Spacer()
      HStack(spacing: 16) {
        Button(action: {
          onSettingsTap()
        }) {
          Image("gear")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: 35, height: 35)
            .foregroundStyle(.white.opacity(0.8))
        }
        Button(action: {
          onSignOutTap()
        }) {
          Image("signOut")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .frame(width: 35, height: 35)
            .foregroundStyle(.white.opacity(0.8))
        }
      }
    }
    .padding(.horizontal)
    .padding(.top, 30)
  }
}

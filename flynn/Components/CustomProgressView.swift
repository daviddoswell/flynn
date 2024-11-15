//
//  CustomProgressView.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import SwiftUI

struct CustomProgressView: View {
  @State private var isAnimating = false
  
  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 8)
        .foregroundColor(.gray.opacity(0.3))
        .frame(width: 200, height: 200)
      
      Circle()
        .trim(from: 0, to: 0.7)
        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
        .foregroundColor(.gray)
        .frame(width: 200, height: 200)
        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
        .animation(
          Animation.linear(duration: 1.5)
            .repeatForever(autoreverses: false),
          value: isAnimating
        )
    }
    .onAppear {
      isAnimating = true
    }
  }
}

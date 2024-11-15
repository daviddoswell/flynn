//
//  HowToView.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import SwiftUI

struct HowToView: View {
  @EnvironmentObject private var manager: AutoProgressManager
  
  var body: some View {
    ZStack {
      Color.appBackground
        .ignoresSafeArea()
      
      ScrollView {
        VStack(spacing: 32) {
          Text("How to Take a Photo")
            .font(.system(size: 32, weight: .heavy, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
            .multilineTextAlignment(.center)
            .padding(.top, 60)
          
          VStack(spacing: 24) {
            PhotoExampleCard(
              title: "Good Photo",
              description: "Top of head, well lit, close up",
              image: "good-photo",
              isGood: true
            )
            
            PhotoExampleCard(
              title: "Bad Photo",
              description: "Selfie angle, poor lighting, too far",
              image: "bad-photo",
              isGood: false
            )
          }
          .padding(.horizontal, 20)
          
          Button(action: {
            manager.moveToNextStep()
          }) {
            Text("Continue")
              .font(.system(size: 24, weight: .heavy, design: .rounded))
              .foregroundStyle(.white.opacity(0.8))
              .frame(maxWidth: .infinity)
              .padding(.vertical, 20)
              .background(Color.white.opacity(0.2))
              .clipShape(RoundedRectangle(cornerRadius: 16))
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 16)
        }
      }
    }
  }
}

struct PhotoExampleCard: View {
  let title: String
  let description: String
  let image: String
  let isGood: Bool
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Image(systemName: isGood ? "checkmark.circle.fill" : "xmark.circle.fill")
          .foregroundStyle(isGood ? .green : .red)
          .font(.system(size: 24))
        
        Text(title)
          .font(.system(size: 18, weight: .bold, design: .rounded))
          .foregroundStyle(.white.opacity(0.8))
      }
      
      Image(image)
        .resizable()
        .scaledToFit()
        .clipShape(Circle())
        .frame(maxWidth: .infinity)
        .frame(height: 300)
      
      Text(description)
        .font(.system(size: 16, weight: .bold, design: .rounded))
        .foregroundStyle(.white.opacity(0.8))
    }
    .padding()
    .background(Color.white.opacity(0.2))
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}

#Preview {
  HowToView()
}

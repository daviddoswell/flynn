//
//  DelayHairLossView.swift
//  hairmax
//
//  Created by David Doswell on 11/6/24.
//

import SwiftUI

struct DelayHairLossView: View {
  @Environment(\.dismiss) private var dismiss
  let timeline: String
  let riskLevel: String
  
  var body: some View {
    ZStack {
      Color.appBackground
        .ignoresSafeArea()
      
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          HStack {
            Button(action: {
              dismiss()
            }) {
              HStack {
                Image(systemName: "chevron.left")
                Text("Back")
              }
              .foregroundStyle(.white.opacity(0.8))
              .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            Spacer()
          }
          .padding(.top, 16)
          VStack(alignment: .leading, spacing: 8) {
            Text("Your Hair Loss Prevention Plan")
              .font(.system(size: 32, weight: .heavy, design: .rounded))
              .foregroundStyle(.white.opacity(0.8))
          }
          .padding(.horizontal)
          .padding(.bottom)
          
          Group {
            tipSection(
              title: "Immediate Actions",
              tips: [
                "Schedule a dermatologist appointment",
                "Start using a DHT-blocking shampoo",
                "Take daily photos to track progress"
              ],
              iconName: "1.circle.fill"
            )
            
            tipSection(
              title: "Lifestyle Changes",
              tips: [
                "Reduce stress through meditation or exercise",
                "Improve sleep quality (7-9 hours nightly)",
                "Maintain a balanced, protein-rich diet"
              ],
              iconName: "2.circle.fill"
            )
            
            tipSection(
              title: "Medical Options",
              tips: [
                "Discuss FDA-approved treatments",
                "Consider prescription medications",
                "Explore preventive supplements"
              ],
              iconName: "3.circle.fill"
            )
          }
        }
        .padding()
      }
    }
  }
  
  private func tipSection(title: String, tips: [String], iconName: String) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Image(systemName: iconName)
          .font(.system(size: 16, weight: .heavy, design: .rounded))
          .foregroundStyle(.white.opacity(0.8))
        Text(title)
          .font(.system(size: 24, weight: .heavy, design: .rounded))
          .foregroundStyle(.white.opacity(0.8))
      }
      
      ForEach(tips, id: \.self) { tip in
        HStack(alignment: .top, spacing: 12) {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 16, weight: .heavy, design: .rounded))
            .foregroundStyle(.green.opacity(0.8))
          Text(tip)
            .font(.system(size: 16, weight: .heavy, design: .rounded))
            .foregroundStyle(.white.opacity(0.8))
        }
      }
    }
    .padding()
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  DelayHairLossView(
    timeline: "35",
    riskLevel: "Medium")
}

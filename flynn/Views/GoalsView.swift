//
//  GoalsView.swift
//  flynnapp
//
//  Created by David Doswell on 11/14/24.
//

import SwiftUI

struct GoalsView: View {
  @EnvironmentObject private var manager: AutoProgressManager
  @State private var selectedGoals: Set<GoalsInput.HairGoal> = []
  
  var body: some View {
    ZStack {
      Color.appBackground
        .ignoresSafeArea()
      
      VStack(spacing: 32) {
        Text("What are your hair goals?")
          .font(.system(size: 32, weight: .heavy, design: .rounded))
          .foregroundStyle(.white.opacity(0.8))
          .multilineTextAlignment(.center)
          .padding(.top, 60)
        
        VStack(spacing: 16) {
          ForEach(GoalsInput.HairGoal.allCases, id: \.self) { goal in
            GoalButton(
              title: goal.title,
              isSelected: selectedGoals.contains(goal),
              action: {
                if selectedGoals.contains(goal) {
                  selectedGoals.remove(goal)
                } else {
                  selectedGoals.insert(goal)
                }
              }
            )
          }
        }
        .padding(.horizontal, 20)
        
        Spacer()
        
        Button(action: {
          let input = GoalsInput(selectedGoals: Array(selectedGoals))
          Task {
            await manager.updateAndProgress(input: input)
          }
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
        .padding(.bottom, 180)
        .disabled(selectedGoals.isEmpty)
      }
    }
  }
}

struct GoalButton: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Text(title)
          .font(.system(size: 18, weight: .bold, design: .rounded))
        Spacer()
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 24))
      }
      .foregroundStyle(.white.opacity(0.8))
      .padding()
      .background(Color.white.opacity(isSelected ? 0.3 : 0.2))
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
  }
}

extension GoalsInput.HairGoal {
  var title: String {
    switch self {
    case .preventLoss:
      return "Prevent Hair Loss"
    case .regrowth:
      return "Regrow Hair"
    case .maintenance:
      return "Maintain Current Hair"
    }
  }
}

#Preview {
  GoalsView()
}

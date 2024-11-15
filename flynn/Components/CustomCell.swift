//
//  CustomCell.swift
//  hairmax
//
//  Created by David Doswell on 11/9/24.
//

import SwiftUI

struct CustomCell: View {
  let icon: String
  let title: String
  let iconColor: Color
  var showDivider: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Image(systemName: icon)
          .font(.system(size: 16, weight: .heavy, design: .rounded))
          .foregroundStyle(iconColor)
          .frame(width: 32)
        
        Text(title)
          .font(.system(size: 16, weight: .heavy, design: .rounded))
          .foregroundStyle(.white.opacity(0.8))
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .font(.footnote)
          .foregroundStyle(.gray)
      }
      .frame(height: 40)
      .padding()
      .background(.gray.opacity(0.2))
      
      if showDivider {
        Divider()
          .padding(.leading, 56)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}

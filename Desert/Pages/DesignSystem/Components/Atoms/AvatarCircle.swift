//
//  AvatarCircle.swift
//  Desert
//
//  Created by Samar A on 07/12/1447 AH.
//

import SwiftUI

struct AvatarCircle: View {

    var initial: String

    var body: some View {

        Text(initial)
            .font(AppTypography.body)
            .foregroundStyle(Color.black)
            .frame(width: 50, height: 50)
            .background(Color.Secondary)
            .clipShape(Circle())
    }
}

#Preview {

    AvatarCircle(initial: "A")
        .padding()
}

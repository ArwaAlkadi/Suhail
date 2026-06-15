//
//  Toggle.swift
//  Desert
//
//  Created by Samar A on 04/12/1447 AH.
//

import SwiftUI

struct AppToggle: View {

    @Binding var isOn: Bool

    var body: some View {

        Toggle("", isOn: $isOn)
            .labelsHidden()
            .tint(.Secondary02)
    }
}

#Preview {

    VStack(spacing: 24) {

        AppToggle(isOn: .constant(false))

        AppToggle(isOn: .constant(true))
    }
}

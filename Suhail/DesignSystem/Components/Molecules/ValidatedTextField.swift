//
//  ErrorMessageRow.swift
//  Desert
//
//  Created by Samar A on 07/12/1447 AH.
//

import SwiftUI

struct ValidatedTextField: View {

    var placeholderKey: String

    var errorMessageKey: String?

    @Binding var text: String

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: AppSpacing.sm
        ) {

            AppTextField(
                placeholderKey: placeholderKey,
                text: $text,
                state: errorMessageKey == nil
                ? .normal
                : .error
            )

            if let errorMessageKey {

                ErrorMessageRow(
                    messageKey: errorMessageKey
                )
            }
        }
    }
}

#Preview {

    VStack(spacing: 24) {

      

        ValidatedTextField(
            placeholderKey: "textfield.value",
            errorMessageKey: "error.requiredField",
            text: .constant("Value")
        )
    }
    .padding()
}

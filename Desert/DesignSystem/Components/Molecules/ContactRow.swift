//
//  ContactRow.swift
//  Desert
//
//  Created by Samar A on 07/12/1447 AH.
//

import SwiftUI

struct ContactRow: View {

    var initial: String
    var titleKey: String
    var captionKey: String

    var deleteAction: (() -> Void)? = nil

    @State private var showDeleteButton = false
    @State private var dragOffset: CGFloat = 0
    private let deleteRevealWidth: CGFloat = 52
    private let deleteTriggerWidth: CGFloat = 96

    var body: some View {

        ZStack(alignment: .trailing) {

            Button {
                deleteAction?()
            } label: {
                Text("Delete")
                    .font(AppTypography.caption)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.Destructive)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            }
            .buttonStyle(.plain)
            .opacity(showDeleteButton ? 1 : 0)

            HStack(spacing: AppSpacing.sm) {

                AvatarCircle(initial: initial)

                VStack(alignment: .leading, spacing: AppSpacing.sx) {

                    Text(titleKey.localized)
                        .font(AppTypography.body)
                        .foregroundStyle(Color.Primary)

                    Text(captionKey.localized)
                        .font(AppTypography.footnote)
                        .foregroundStyle(Color.Disabled)
                }

                Spacer(minLength: AppSpacing.sx)

                Button {
                    withAnimation(.spring()) {
                        showDeleteButton.toggle()
                        dragOffset = showDeleteButton ? -deleteRevealWidth : 0
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.Disabled.opacity(0.5))
                        .frame(width: 18, height: 21)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .offset(x: dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let startOffset = showDeleteButton ? -deleteRevealWidth : 0
                        let newOffset = startOffset + value.translation.width

                        dragOffset = min(0, max(newOffset, -deleteTriggerWidth))
                    }
                    .onEnded { value in
                        let startOffset = showDeleteButton ? -deleteRevealWidth : 0
                        let finalOffset = startOffset + value.translation.width

                        if finalOffset <= -deleteTriggerWidth {
                            deleteAction?()
                            return
                        }

                        withAnimation(.spring()) {
                            if finalOffset < -40 {
                                showDeleteButton = true
                                dragOffset = -deleteRevealWidth
                            } else {
                                showDeleteButton = false
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 68)
    }
}
#Preview {

    VStack(spacing: 0) {

        ContactRow(
            initial: "A",
            titleKey: "contact.name",
            captionKey: "contact.phone"
        ) {
            print("Deleted")
        }

        AppDivider()

        ContactRow(
            initial: "F",
            titleKey: "contact.name",
            captionKey: "contact.phone"
        ) {
            print("Deleted")
        }
    }
    .padding()
}

//
//  SelectDestinationTemplate.swift
//  Desert
//
//  Created by Samar A on 12/12/1447 AH.
//

// هنا غيرت فيه كان ينقصه متغيرات.. وبرضو سويت نتايج البحث عالسريع بدون ديزاين عدلي عدليها من فيقما ميار سوتها

import SwiftUI
import MapKit

struct SelectDestinationTemplate<MapContent: View>: View {

    @Binding var searchText: String
    var searchResults: [(item: MKMapItem, subtitle: String?)]
    var canConfirm: Bool
    var mapContent: () -> MapContent

    var onBack: () -> Void
    var onSearch: () -> Void
    var onSelectResult: (MKMapItem) -> Void
    var onConfirm: () -> Void

    var body: some View {
        ZStack(alignment: .top) {

            mapContent()
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.sm) {

                SearchBar(
                    style: .withBackButton,
                    placeholderKey: "search.destination",
                    text: $searchText,
                    backAction: onBack,
                    searchAction: onSearch
                )
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.sm)

                if !searchResults.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(searchResults.enumerated()), id: \.offset) { index, result in
                            Button {
                                onSelectResult(result.item)
                            } label: {
                                HStack(spacing: AppSpacing.md) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(result.item.name ?? "")
                                        if let subtitle = result.subtitle {
                                            Text(subtitle)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.vertical, AppSpacing.md)
                            }

                            if index < searchResults.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .background(.primary)
                    .padding(.horizontal, AppSpacing.lg)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .environment(\.layoutDirection, .leftToRight)
        .safeAreaInset(edge: .bottom) {
            CTAButton(
                title: "common.select".localized,
                style: canConfirm ? .primary : .disabled
            ) {
                onConfirm()
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, AppSpacing.lg)
        }
    }
}

#Preview {
    SelectDestinationTemplate(
        searchText: .constant("Al Thoumamah"),
        searchResults: [],
        canConfirm: false,
        mapContent: {
            Image("tripMap")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        },
        onBack: {},
        onSearch: {},
        onSelectResult: { _ in },
        onConfirm: {}
    )
}

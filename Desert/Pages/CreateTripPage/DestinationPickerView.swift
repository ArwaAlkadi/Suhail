//
//  DestinationPickerView.swift
//  Desert
//
//  Sheet shown when the user taps the Destination field in CreateTripStepsView.
//
//  Flow:
//  1. User types in the search bar → MKLocalSearch returns suggestions
//  2. User taps a suggestion → map jumps to that location, pin drops
//  3. Alternatively, user taps anywhere on the map → pin drops, reverse geocode fills name
//  4. User taps "Select" → vm updates destination/lat/lng → sheet dismisses
//
//  All logic lives in CreateTripViewModel — this view is UI only.
//

import SwiftUI
import MapKit

struct DestinationPickerView: View {

    @ObservedObject var vm: CreateTripViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SelectDestinationTemplate(
            searchText: $vm.destinationSearchText,
            searchResults: vm.formattedSearchResults,
            canConfirm: vm.pinCoordinate != nil,
            mapContent: {
                DestinationPickerMapView(
                    region: $vm.destinationRegion,
                    pinCoordinate: $vm.pinCoordinate,
                    onTap: { coordinate in
                        vm.pinCoordinate = coordinate
                        vm.reverseGeocode(coordinate)
                    }
                )
            },
            onBack: { dismiss() },
            onSearch: { vm.searchDestination() },
            onSelectResult: { item in vm.selectDestination(item) },
            onConfirm: {
                vm.confirmDestination()
                dismiss()
            }
        )
        .onChange(of: vm.destinationSearchText) { _, newValue in
            if newValue.isEmpty { vm.destinationSearchResults = [] }
        }
    }
}

#Preview {
    let vm = CreateTripViewModel()
    vm.destination = "Al Thumamah"
    vm.destinationLat = 24.9
    vm.destinationLng = 46.7

    return NavigationStack {
        DestinationPickerView(vm: vm)
    }
}

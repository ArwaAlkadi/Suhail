//
//  Components.swift
//  Desert
//

import SwiftUI
import MapKit
import ContactsUI

// MARK: - Contact Picker Sheet A (single select)

struct ContactPickerSheetA: UIViewControllerRepresentable {

    var onSelect: (CNContact) -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onSelect: onSelect) }

    class Coordinator: NSObject, CNContactPickerDelegate {
        var onSelect: (CNContact) -> Void
        init(onSelect: @escaping (CNContact) -> Void) { self.onSelect = onSelect }
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelect(contact)
        }
    }
}

// MARK: - Contact Picker Sheet B (multi select)

struct ContactPickerSheetB: UIViewControllerRepresentable {

    var onSelect: ([CNContact]) -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onSelect: onSelect) }

    class Coordinator: NSObject, CNContactPickerDelegate {
        var onSelect: ([CNContact]) -> Void
        init(onSelect: @escaping ([CNContact]) -> Void) { self.onSelect = onSelect }
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
            onSelect(contacts)
        }
    }
}

// MARK: - Destination Picker View

struct DestinationPickerViewA: View {

    @Environment(\.dismiss) private var dismiss
    @Binding var destination: String
    @Binding var lat: Double
    @Binding var lng: Double

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var pinCoordinate: CLLocationCoordinate2D?
    @State private var pinName: String = ""

    var body: some View {
        ZStack {
            TappableMapViewA(
                region: $region,
                pinCoordinate: $pinCoordinate,
                onTap: { coordinate in
                    pinCoordinate = coordinate
                    reverseGeocode(coordinate)
                }
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                SearchBar(
                    style: .withBackButton,
                    placeholderKey: "search.destination",
                    text: $searchText,
                    backAction: { dismiss() },
                    searchAction: { search() }
                )
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.sm)

                if !searchResults.isEmpty {
                    List(searchResults, id: \.self) { item in
                        Button(item.name ?? "") {
                            selectLocation(item)
                        }
                    }
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.sm)
                }

                Spacer()
            }
        }
        .safeAreaInset(edge: .bottom) {
            CTAButton(
                title: "confirm_destination".localized,
                style: pinCoordinate == nil ? .disabled : .primary
            ) {
                guard let pinCoordinate else { return }
                destination = pinName.isEmpty ? coordinateText() : pinName
                lat = pinCoordinate.latitude
                lng = pinCoordinate.longitude
                dismiss()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.sm)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    func search() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        MKLocalSearch(request: request).start { response, _ in
            searchResults = response?.mapItems ?? []
        }
    }

    func selectLocation(_ item: MKMapItem) {
        pinCoordinate = item.placemark.coordinate
        pinName = item.name ?? searchText
        region.center = item.placemark.coordinate
        searchResults = []
        searchText = item.name ?? ""
    }

    func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        CLGeocoder().reverseGeocodeLocation(
            CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        ) { placemarks, _ in
            pinName = placemarks?.first?.name ?? coordinateText()
        }
    }

    func coordinateText() -> String {
        guard let pin = pinCoordinate else { return "" }
        return String(format: "%.4f, %.4f", pin.latitude, pin.longitude)
    }
}

// MARK: - Tappable Map View

struct TappableMapViewA: UIViewRepresentable {

    @Binding var region: MKCoordinateRegion
    @Binding var pinCoordinate: CLLocationCoordinate2D?
    var onTap: (CLLocationCoordinate2D) -> Void

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: false)
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        mapView.addGestureRecognizer(tap)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if let coordinate = pinCoordinate {
            mapView.setRegion(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ), animated: true)
        }
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        if let coordinate = pinCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(region: $region, pinCoordinate: $pinCoordinate, onTap: onTap)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        @Binding var region: MKCoordinateRegion
        @Binding var pinCoordinate: CLLocationCoordinate2D?
        var onTap: (CLLocationCoordinate2D) -> Void

        init(
            region: Binding<MKCoordinateRegion>,
            pinCoordinate: Binding<CLLocationCoordinate2D?>,
            onTap: @escaping (CLLocationCoordinate2D) -> Void
        ) {
            _region = region
            _pinCoordinate = pinCoordinate
            self.onTap = onTap
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let mapView = gesture.view as! MKMapView
            let coordinate = mapView.convert(
                gesture.location(in: mapView),
                toCoordinateFrom: mapView
            )
            onTap(coordinate)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view.markerTintColor = .red
            view.isDraggable = true
            view.canShowCallout = false
            return view
        }

        func mapView(
            _ mapView: MKMapView,
            annotationView view: MKAnnotationView,
            didChange newState: MKAnnotationView.DragState,
            fromOldState oldState: MKAnnotationView.DragState
        ) {
            if newState == .ending, let coordinate = view.annotation?.coordinate {
                pinCoordinate = coordinate
                onTap(coordinate)
            }
        }
    }
}


// MARK: - Delete Swipe Action

struct DeleteSwipeActionA: View {

    var action: () -> Void

    var body: some View {
        Button { action() } label: {
            Label("delete".localized, systemImage: "trash")
        }
        .tint(.red)
    }
}


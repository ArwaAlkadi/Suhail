
//
//  DestinationPickerMapView.swift
//  Desert
//
//  Tappable map used inside DestinationPickerView.
//
//  Responsibilities:
//  - Drops a draggable pin wherever the user taps
//  - Zooms to a coordinate when driven externally (from search results)
//  - Returns the selected coordinate via onTap callback
//
//  Does NOT handle:
//  - Search UI (owned by DestinationPickerView)
//  - Reverse geocoding (owned by DestinationPickerView)
//  - Confirm / cancel actions (owned by DestinationPickerView)
//

import SwiftUI
import MapKit

struct DestinationPickerMapView: UIViewRepresentable {

    @Binding var region: MKCoordinateRegion
    @Binding var pinCoordinate: CLLocationCoordinate2D?
    var onTap: (CLLocationCoordinate2D) -> Void

    // MARK: - Make

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

    // MARK: - Update

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if let coordinate = pinCoordinate {
            mapView.setRegion(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ),
                animated: true
            )
        }

        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })

        if let coordinate = pinCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }

    // MARK: - Coordinator

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
            view.markerTintColor = .systemOrange
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
//  4. User taps "Select" → bindings update → sheet dismisses
//
//  Returns via bindings:
//  - destination: human-readable place name
//  - lat / lng: coordinates of the selected location
//

import SwiftUI
import MapKit

struct DestinationPickerView: View {

    @Binding var destination: String
    @Binding var lat: Double
    @Binding var lng: Double

    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var pinCoordinate: CLLocationCoordinate2D?
    @State private var pinName: String = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    var userLocation: CLLocation? {
        guard let coord = LocationManager.shared.currentUserLocation else { return nil }
        return CLLocation(latitude: coord.latitude, longitude: coord.longitude)
    }

    var formattedResults: [(item: MKMapItem, subtitle: String?)] {
        searchResults.map { item in
            var parts: [String] = []

            if let city = item.placemark.locality {
                parts.append(city)
            }

            if let userLoc = userLocation {
                let itemLoc = CLLocation(
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
                let km = Int(userLoc.distance(from: itemLoc) / 1000)
                if km > 0 { parts.append("\(km) km") }
            }

            return (item: item, subtitle: parts.isEmpty ? nil : parts.joined(separator: ", "))
        }
    }

    var body: some View {
        SelectDestinationTemplate(
            searchText: $searchText,
            searchResults: formattedResults,
            canConfirm: pinCoordinate != nil,
            mapContent: {
                DestinationPickerMapView(
                    region: $region,
                    pinCoordinate: $pinCoordinate,
                    onTap: { coordinate in
                        pinCoordinate = coordinate
                        reverseGeocode(coordinate)
                    }
                )
            },
            onBack: { dismiss() },
            onSearch: { search() },
            onSelectResult: { item in selectLocation(item) },
            onConfirm: { confirmSelection() }
        )
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty { searchResults = [] }
        }
    }

    // MARK: - Search

    private func search() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        MKLocalSearch(request: request).start { response, _ in
            searchResults = response?.mapItems ?? []
        }
    }

    private func selectLocation(_ item: MKMapItem) {
        pinCoordinate = item.placemark.coordinate
        pinName = item.name ?? searchText
        region.center = item.placemark.coordinate
        searchResults = []
        searchText = item.name ?? ""
    }

    // MARK: - Reverse Geocode

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) {
        CLGeocoder().reverseGeocodeLocation(
            CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        ) { placemarks, _ in
            pinName = placemarks?.first?.name ?? coordinateText()
        }
    }

    private func coordinateText() -> String {
        guard let pin = pinCoordinate else { return "" }
        return String(format: "%.4f, %.4f", pin.latitude, pin.longitude)
    }

    // MARK: - Confirm

    private func confirmSelection() {
        guard let coord = pinCoordinate else { return }
        destination = pinName.isEmpty ? coordinateText() : pinName
        lat = coord.latitude
        lng = coord.longitude
        dismiss()
    }
}

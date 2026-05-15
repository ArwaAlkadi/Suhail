//
//  Map.swift
//  Desert
//

import SwiftUI
import MapKit
import SwiftData

// MARK: - TripMapView

struct TripMapView: UIViewRepresentable {
    
    var localTrack: [CLLocationCoordinate2D]
    var lastUploadedLocation: CLLocationCoordinate2D?
    var destinationLocation: CLLocationCoordinate2D?
    var userLocation: CLLocationCoordinate2D?
    var showUserLocation: Bool = true
    var showCenterButton: Bool = true
    var mapType: MKMapType = .standard
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        context.coordinator.mapView = mapView
        
        mapView.showsUserLocation = false
        mapView.showsCompass = false
        mapView.showsScale = false
        
        let compassButton = MKCompassButton(mapView: mapView)
        compassButton.compassVisibility = .visible
        compassButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(compassButton)
        
        let scaleView = MKScaleView(mapView: mapView)
        scaleView.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(scaleView)
        
        NSLayoutConstraint.activate([
            compassButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            compassButton.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            scaleView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 16),
            scaleView.topAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        if showCenterButton {
            let centerButton = UIButton(type: .system)
            centerButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
            centerButton.backgroundColor = .systemBackground
            centerButton.tintColor = .label
            centerButton.layer.cornerRadius = 22
            centerButton.layer.shadowColor = UIColor.black.cgColor
            centerButton.layer.shadowOpacity = 0.2
            centerButton.layer.shadowRadius = 4
            centerButton.layer.shadowOffset = CGSize(width: 0, height: 2)
            centerButton.translatesAutoresizingMaskIntoConstraints = false
            centerButton.addTarget(
                context.coordinator,
                action: #selector(Coordinator.centerOnUser),
                for: .touchUpInside
            )
            
            mapView.addSubview(centerButton)
            
            NSLayoutConstraint.activate([
                centerButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
                centerButton.topAnchor.constraint(equalTo: compassButton.bottomAnchor, constant: 16),
                centerButton.widthAnchor.constraint(equalToConstant: 44),
                centerButton.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.userLocation = userLocation
        
        if userLocation == nil && mapView.overlays.isEmpty && mapView.annotations.isEmpty {
            fitMapToContent(mapView)
        }
        
        if let loc = userLocation, mapView.annotations.isEmpty {
            let region = MKCoordinateRegion(
                center: loc,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            mapView.setRegion(region, animated: true)
        }
        
        let existingPolylines = mapView.overlays.compactMap { $0 as? MKPolyline }
        
        if localTrack.count > 1 {
            let newPolyline = MKPolyline(coordinates: localTrack, count: localTrack.count)
            newPolyline.title = "Local"
            mapView.removeOverlays(existingPolylines)
            mapView.addOverlay(newPolyline)
        }
        
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        if let dest = destinationLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = dest
            annotation.title = "Destination"
            mapView.addAnnotation(annotation)
        }
        
        if let uploaded = lastUploadedLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = uploaded
            annotation.title = "Uploaded"
            mapView.addAnnotation(annotation)
        }
        
        if showUserLocation, let userLoc = userLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLoc
            annotation.title = "UserLocation"
            mapView.addAnnotation(annotation)
        }
        
        mapView.mapType = mapType
    }
    
    private func fitMapToContent(_ mapView: MKMapView) {
        var coordinates = localTrack
        
        if let dest = destinationLocation {
            coordinates.append(dest)
        }
        
        guard !coordinates.isEmpty else { return }
        
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLng = coordinates[0].longitude
        var maxLng = coordinates[0].longitude
        
        for coord in coordinates {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLng = min(minLng, coord.longitude)
            maxLng = max(maxLng, coord.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.4, 0.01),
            longitudeDelta: max((maxLng - minLng) * 1.4, 0.01)
        )
        
        mapView.setRegion(
            MKCoordinateRegion(center: center, span: span),
            animated: true
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        weak var mapView: MKMapView?
        var userLocation: CLLocationCoordinate2D?
        
        @objc func centerOnUser() {
            guard let mapView,
                  let userLocation else { return }
            
            let region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            
            mapView.setRegion(region, animated: true)
        }
        
        func mapView(
            _ mapView: MKMapView,
            rendererFor overlay: MKOverlay
        ) -> MKOverlayRenderer {
            
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                
                if polyline.title == "Local" {
                    renderer.strokeColor = .red
                    renderer.lineWidth = 5
                }
                
                return renderer
            }
            
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(
            _ mapView: MKMapView,
            viewFor annotation: MKAnnotation
        ) -> MKAnnotationView? {
            
            guard !(annotation is MKUserLocation) else { return nil }
            
            let reuseId = annotation.title ?? "pin"
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            view.canShowCallout = false
            
            let size: CGFloat = 20
            let circle = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            circle.layer.cornerRadius = size / 2
            circle.layer.borderWidth = 2
            circle.layer.borderColor = UIColor.white.cgColor
            
            if annotation.title == "Destination" {
                circle.backgroundColor = .systemOrange
            } else if annotation.title == "Uploaded" {
                circle.backgroundColor = .systemBlue
            } else if annotation.title == "UserLocation" {
                circle.backgroundColor = .systemBlue
            } else {
                circle.backgroundColor = .systemBlue
            }
            
            view.addSubview(circle)
            view.frame = circle.frame
            
            return view
        }
    }
}

// MARK: - ReplayMapView

struct ReplayMapView: View {
    
    var localTrack: [CLLocationCoordinate2D]
    var destinationLocation: CLLocationCoordinate2D?
    
    @State private var replayIndex: Int = 0
    @State private var isReplaying: Bool = false
    @State private var replayTimer: Timer?
    
    var displayTrack: [CLLocationCoordinate2D] {
        guard !localTrack.isEmpty else { return [] }
        
        if isReplaying || replayIndex > 0 {
            return Array(localTrack.prefix(replayIndex + 1))
        }
        
        return localTrack
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TripMapView(
                localTrack: displayTrack,
                lastUploadedLocation: nil,
                destinationLocation: destinationLocation,
                userLocation: nil,
                showUserLocation: false,
                showCenterButton: false
            )
            .ignoresSafeArea()
            
            HStack(spacing: 16) {
                Button(action: {
                    stopReplay()
                    replayIndex = 0
                }) {
                    Image(systemName: "backward.end.fill")
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                
                Button(action: {
                    isReplaying ? stopReplay() : startReplay()
                }) {
                    Image(systemName: isReplaying ? "stop.fill" : "play.fill")
                        .foregroundColor(.white)
                        .padding(14)
                        .background(Color.black)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    func startReplay() {
        guard !localTrack.isEmpty else { return }
        
        if replayIndex >= localTrack.count - 1 {
            replayIndex = 0
        }
        
        isReplaying = true
        
        replayTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            if replayIndex < localTrack.count - 1 {
                replayIndex += 1
            } else {
                replayTimer?.invalidate()
                isReplaying = false
            }
        }
    }
    
    func stopReplay() {
        replayTimer?.invalidate()
        isReplaying = false
    }
}

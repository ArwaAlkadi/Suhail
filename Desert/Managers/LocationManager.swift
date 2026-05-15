//
//  TripSessionManager.swift
//  Desert
//

import Foundation
import SwiftData
import CoreLocation

/// ينسق بين LocationManager وNotificationsManager وFirebaseManager
///
/// ## التقسيم
/// - LocationManager    → GPS فقط
/// - NotificationsManager → إشعارات محلية فقط
/// - FirebaseManager    → كلاود فقط
/// - TripSessionManager → ينسق بينهم ويقرر متى يستدعي كل واحد
///
/// ## Usage
/// ```swift
/// // اربط الـ delegate
/// LocationManager.shared.delegate = TripSessionManager.shared
///
/// // ابدأ رحلة
/// TripSessionManager.shared.beginTrip(trip: trip, context: context)
///
/// // أنهِ الرحلة
/// TripSessionManager.shared.finishTrip(trip: trip, context: context)
///
/// // استأنف عند فتح التطبيق
/// TripSessionManager.shared.resumeActiveSessionIfNeeded(context: context)
/// ```
class TripSessionManager: NSObject, ObservableObject {

    static let shared = TripSessionManager()

    /// هل في رحلة نشطة الآن
    @Published var hasActiveTrip = false

    private let locationManager   = LocationManager.shared
    private let notifications     = NotificationsManager.shared
    private let firebase          = FirebaseManager.shared

    // MARK: - ابدأ رحلة جديدة
    /// أنشئ معرف الرحلة، احفظها محلياً وعلى Firebase، وابدأ التتبع
    func startTrip(trip: Trip, context: ModelContext) {
        firebase.createTripId { [weak self] tripId in
            guard let self else { return }

            trip.tripId = tripId
            context.insert(trip)
            firebase.saveTrip(trip, tripId: tripId)
            locationManager.startTrackingForTrip(tripId)
            notifications.requestPermission()
            saveActiveTripToSettings(tripId: tripId, context: context)

            DispatchQueue.main.async { self.hasActiveTrip = true }
            print("TripSessionManager: بدأت الرحلة — \(tripId)")
        }
    }

    // MARK: - أنهِ الرحلة
    /// أوقف التتبع، ألغِ الإشعارات، وحدّث الحالة محلياً وعلى Firebase
    func finishTrip(trip: Trip, context: ModelContext) {
        trip.status = "completed"
        firebase.endTrip(tripId: trip.tripId)
        locationManager.stopTracking()
        notifications.cancelAllNotifications()
        clearActiveTripFromSettings(context: context)

        DispatchQueue.main.async { self.hasActiveTrip = false }
        print("TripSessionManager: انتهت الرحلة — \(trip.tripId)")
    }

    // MARK: - استأنف عند فتح التطبيق
    /// استأنف التتبع لو كانت هناك رحلة نشطة عند آخر إغلاق
    func resumeActiveSessionIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<AppSettings>()
        guard let settings = try? context.fetch(descriptor).first,
              settings.hasActiveTrip,
              !settings.currentTripId.isEmpty,
              !locationManager.isTrackingActive else { return }

        locationManager.resumeTrackingForTrip(settings.currentTripId)
        DispatchQueue.main.async { self.hasActiveTrip = true }
        print("TripSessionManager: استُؤنفت الجلسة — \(settings.currentTripId)")
    }

    // MARK: - LocationManagerDelegate
    // مُطبَّق في extension أدناه
}

// MARK: - LocationManagerDelegate

extension TripSessionManager: LocationManagerDelegate {

    /// يُستدعى كلما وصل موقع جديد — يقرر هل يحفظ أو يرفع
    func onNewLocationReceived(_ location: CLLocation) {
        guard let context = activeModelContext else { return }
        guard let trip = fetchActiveTrip(context: context) else { return }

        saveGPSPointLocally(location, trip: trip)

        if shouldUploadLocationNow(location) {
            uploadLocationToCloud(location, trip: trip, context: context)
        }
    }

    /// يُستدعى عندما يعود المستخدم لنقطة البداية — ينهي الرحلة تلقائياً
    func onUserReturnedToStartPoint() {
        guard let context = activeModelContext else { return }
        guard let trip = fetchActiveTrip(context: context) else { return }

        DispatchQueue.main.async { [weak self] in
            self?.finishTrip(trip: trip, context: context)
            print("TripSessionManager: أُنهيت الرحلة تلقائياً — المستخدم عاد للبداية")
        }
    }

    // MARK: - حفظ نقطة GPS محلياً
    private func saveGPSPointLocally(_ location: CLLocation, trip: Trip) {
        if let last = lastSavedCoordinate {
            let lastCL = CLLocation(latitude: last.latitude, longitude: last.longitude)
            guard location.distance(from: lastCL) >= minDistanceBetweenSavedPoints else { return }
        }
        lastSavedCoordinate = location.coordinate
        savedPointsCount += 1
        trip.gpsTrack.append(LocationPoint(
            index: savedPointsCount,
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
        ))
        print("TripSessionManager: حُفظت نقطة GPS رقم \(savedPointsCount)")
    }

    // MARK: - رفع الموقع للكلاود
    private func uploadLocationToCloud(_ location: CLLocation, trip: Trip, context: ModelContext) {
        let direction = location.course >= 0 ? location.course : nil

        firebase.updateLocation(
            tripId: trip.tripId,
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude,
            direction: direction,
            onSuccess: { [weak self] in
                self?.notifications.cancelAllNotifications()
                trip.lastKnownLat   = location.coordinate.latitude
                trip.lastKnownLng   = location.coordinate.longitude
                trip.lastUploadTime = Date()
                trip.lastDirection  = direction
                self?.lastUploadDate       = Date()
                self?.lastUploadedCoordinate = location.coordinate
                print("TripSessionManager: رُفع الموقع للكلاود")
            },
            onFailure: { [weak self] in
                guard Date() >= trip.returnTime else { return }
                self?.notifications.scheduleOfflineNotifications(returnTime: trip.returnTime)
                print("TripSessionManager: فشل الرفع — جُدولت إشعارات طوارئ")
            }
        )
    }

    // MARK: - شروط الرفع للكلاود
    private func shouldUploadLocationNow(_ location: CLLocation) -> Bool {
        guard let last = lastUploadedCoordinate else { return true }
        let lastCL = CLLocation(latitude: last.latitude, longitude: last.longitude)
        if location.distance(from: lastCL) >= minDistanceBetweenUploads { return true }
        if Date().timeIntervalSince(lastUploadDate) >= maxTimeBetweenUploads { return true }
        return false
    }
}

// MARK: - Private State

extension TripSessionManager {

    // GPS save state
    var lastSavedCoordinate: CLLocationCoordinate2D? {
        get {
            let lat = UserDefaults.standard.double(forKey: "lastSavedLat")
            let lng = UserDefaults.standard.double(forKey: "lastSavedLng")
            guard lat != 0 else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        set {
            UserDefaults.standard.set(newValue?.latitude ?? 0,  forKey: "lastSavedLat")
            UserDefaults.standard.set(newValue?.longitude ?? 0, forKey: "lastSavedLng")
        }
    }

    var savedPointsCount: Int {
        get { UserDefaults.standard.integer(forKey: "savedPointsCount") }
        set { UserDefaults.standard.set(newValue, forKey: "savedPointsCount") }
    }

    // Upload state
    var lastUploadDate: Date {
        get {
            let t = UserDefaults.standard.double(forKey: "lastUploadDate")
            return t == 0 ? .distantPast : Date(timeIntervalSince1970: t)
        }
        set { UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: "lastUploadDate") }
    }

    var lastUploadedCoordinate: CLLocationCoordinate2D? {
        get {
            let lat = UserDefaults.standard.double(forKey: "lastUploadedLat")
            let lng = UserDefaults.standard.double(forKey: "lastUploadedLng")
            guard lat != 0 else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        set {
            UserDefaults.standard.set(newValue?.latitude ?? 0,  forKey: "lastUploadedLat")
            UserDefaults.standard.set(newValue?.longitude ?? 0, forKey: "lastUploadedLng")
        }
    }

    // Constants
    var minDistanceBetweenSavedPoints: CLLocationDistance { 250 }
    var minDistanceBetweenUploads: CLLocationDistance { 2000 }
    var maxTimeBetweenUploads: TimeInterval { 60 * 60 }

    // SwiftData context
    var activeModelContext: ModelContext? {
        // يُعيَّن من HomeViewModel عند الـ onAppear
        return _activeModelContext
    }
    static var _activeModelContext: ModelContext?
    var _activeModelContext: ModelContext? {
        get { TripSessionManager._activeModelContext }
        set { TripSessionManager._activeModelContext = newValue }
    }

    /// يُستدعى من HomeViewModel عند الـ onAppear لتسليم الـ context
    func setModelContext(_ context: ModelContext) {
        _activeModelContext = context
    }

    // MARK: - AppSettings helpers

    private func saveActiveTripToSettings(tripId: String, context: ModelContext) {
        let descriptor = FetchDescriptor<AppSettings>()
        if let s = try? context.fetch(descriptor).first {
            s.currentTripId = tripId; s.isFirstLaunch = false
        } else {
            let s = AppSettings(); s.currentTripId = tripId; s.isFirstLaunch = false
            context.insert(s)
        }
    }

    private func clearActiveTripFromSettings(context: ModelContext) {
        let descriptor = FetchDescriptor<AppSettings>()
        if let s = try? context.fetch(descriptor).first {
            s.currentTripId = ""
        }
        savedPointsCount = 0
        lastUploadedCoordinate = nil
        lastSavedCoordinate = nil
    }

    private func fetchActiveTrip(context: ModelContext) -> Trip? {
        let tripId = locationManager.activeTripId
        let descriptor = FetchDescriptor<Trip>(predicate: #Predicate { $0.tripId == tripId })
        return try? context.fetch(descriptor).first
    }
}


//
//  LocationManager.swift
//  Desert
//

import Foundation
import CoreLocation
import SwiftData
import Combine

// MARK: - LocationManagerDelegate

protocol LocationManagerDelegate: AnyObject {
    /// يُستدعى كلما وصل موقع جديد صالح — فقط أثناء رحلة نشطة
    func onNewLocationReceived(_ location: CLLocation)
    /// يُستدعى عندما يعود المستخدم لنقطة البداية
    func onUserReturnedToStartPoint()
}

// MARK: - LocationManager

/// مسؤول عن GPS فقط.
///
/// ## القاعدة الأساسية
/// - التتبع في الخلفية يعمل **فقط** أثناء رحلة نشطة
/// - بدون رحلة = لا background updates = لا battery drain
///
/// ## Responsibilities
/// 1. طلب صلاحية الموقع
/// 2. تتبع الموقع أثناء الرحلة فقط
/// 3. مراقبة نقطة البداية (CLMonitor)
/// 4. إرسال updates للـ delegate (TripSessionManager)
/// 5. استعادة الجلسة بعد force quit
///
/// ## ما لا يفعله
/// - لا يحفظ في SwiftData
/// - لا يرفع لـ Firebase
/// - لا يرسل إشعارات
/// - لا يبدأ background tracking بدون رحلة
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    private let clManager = CLLocationManager()

    /// هل التتبع نشط الآن
    @Published var isTrackingActive = false

    /// آخر موقع للمستخدم — لتوسيط الخريطة فقط
    @Published var currentUserLocation: CLLocationCoordinate2D?

    /// صلاحية الموقع الحالية
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined

    /// المستقبل لأحداث GPS — TripSessionManager
    weak var delegate: LocationManagerDelegate?

    var activeTripId: String = ""

    private let gpsDistanceFilter: CLLocationDistance = 100
    private let maxAcceptableAccuracy: CLLocationAccuracy = 150
    private var originMonitor: CLMonitor?
    private var originMonitorTask: Task<Void, Never>?
    private var originMonitoringStarted = false

    // MARK: - Init
    /// لا يبدأ أي tracking هنا — فقط إعداد الـ delegate
    override init() {
        super.init()
        clManager.delegate = self
        // لا requestLocation() هنا — ما في background tracking بدون رحلة
    }

    // MARK: - طلب صلاحية الموقع
    func requestLocationPermission() {
        clManager.requestAlwaysAuthorization()
    }

    // MARK: - طلب موقع مبدئي للخريطة فقط
    /// يُستدعى مرة واحدة بعد منح الصلاحية لتوسيط الخريطة
    /// لا يفعّل background tracking
    func requestInitialLocationForMap() {
        guard clManager.authorizationStatus == .authorizedWhenInUse ||
              clManager.authorizationStatus == .authorizedAlways else { return }
        clManager.desiredAccuracy = kCLLocationAccuracyKilometer
        clManager.requestLocation()  // مرة واحدة فقط — لا continuous updates
    }

    // MARK: - بدء تتبع رحلة نشطة
    /// يفعّل background tracking — يُستدعى فقط عند بدء رحلة
    func startTrackingForTrip(_ tripId: String) {
        stopOriginMonitoring()
        originMonitoringStarted = false

        UserDefaults.standard.set(tripId, forKey: "activeTripId")
        activeTripId = tripId
        isTrackingActive = true

        // battery optimizations
        clManager.activityType = .automotiveNavigation
        clManager.pausesLocationUpdatesAutomatically = true
        clManager.desiredAccuracy = kCLLocationAccuracyBest
        clManager.distanceFilter = gpsDistanceFilter

        // background tracking — فقط هنا
        clManager.allowsBackgroundLocationUpdates = true
        clManager.showsBackgroundLocationIndicator = true

        clManager.startUpdatingLocation()
        clManager.startMonitoringSignificantLocationChanges()

        if let origin = currentUserLocation {
            startMonitoringReturnToStart(lat: origin.latitude, lng: origin.longitude)
            originMonitoringStarted = true
        }

        print("LocationManager: بدأ التتبع — \(tripId)")
    }

    // MARK: - إيقاف التتبع
    /// يوقف كل شيء تماماً — لا background tracking بعدها
    func stopTracking() {
        clManager.stopUpdatingLocation()
        clManager.stopMonitoringSignificantLocationChanges()

        // أوقف background tracking تماماً
        clManager.allowsBackgroundLocationUpdates = false
        clManager.showsBackgroundLocationIndicator = false
        clManager.pausesLocationUpdatesAutomatically = false

        stopOriginMonitoring()

        isTrackingActive = false
        originMonitoringStarted = false
        activeTripId = ""

        UserDefaults.standard.removeObject(forKey: "activeTripId")

        print("LocationManager: أُوقف التتبع — لا background tracking")
    }

    // MARK: - استئناف التتبع عند العودة للتطبيق
    func resumeTrackingForTrip(_ tripId: String) {
        activeTripId = tripId
        isTrackingActive = true
        originMonitoringStarted = false

        clManager.activityType = .automotiveNavigation
        clManager.pausesLocationUpdatesAutomatically = true
        clManager.desiredAccuracy = kCLLocationAccuracyBest
        clManager.distanceFilter = gpsDistanceFilter
        clManager.allowsBackgroundLocationUpdates = true
        clManager.showsBackgroundLocationIndicator = true
        clManager.startUpdatingLocation()
        clManager.startMonitoringSignificantLocationChanges()

        print("LocationManager: استُؤنف التتبع — \(tripId)")
    }

    // MARK: - استعادة الجلسة بعد force quit
    func restoreSessionAfterForceQuit() {
        let tripId = UserDefaults.standard.string(forKey: "activeTripId") ?? ""
        guard !tripId.isEmpty else { return }

        activeTripId = tripId
        isTrackingActive = true
        originMonitoringStarted = false

        clManager.activityType = .automotiveNavigation
        clManager.pausesLocationUpdatesAutomatically = true
        clManager.desiredAccuracy = kCLLocationAccuracyBest
        clManager.distanceFilter = gpsDistanceFilter
        clManager.allowsBackgroundLocationUpdates = true
        clManager.showsBackgroundLocationIndicator = true
        clManager.startUpdatingLocation()
        clManager.startMonitoringSignificantLocationChanges()

        print("LocationManager: استُعيدت الجلسة — \(tripId)")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // دائماً حدّث الموقع للخريطة
        DispatchQueue.main.async { self.currentUserLocation = location.coordinate }

        // لا تُبلّغ الـ delegate إلا أثناء رحلة نشطة
        guard isTrackingActive, !activeTripId.isEmpty else { return }

        guard location.horizontalAccuracy > 0,
              location.horizontalAccuracy <= maxAcceptableAccuracy else { return }

        // ابدأ مراقبة نقطة البداية عند أول موقع صالح
        if !originMonitoringStarted {
            startMonitoringReturnToStart(
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude
            )
            originMonitoringStarted = true
        }

        // دقة ديناميكية — توفير البطارية
        clManager.desiredAccuracy = location.speed > 5.0
            ? kCLLocationAccuracyBest
            : kCLLocationAccuracyHundredMeters

        // أرسل للـ TripSessionManager فقط
        delegate?.onNewLocationReceived(location)
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("LocationManager: GPS متوقف مؤقتاً — الجهاز ثابت")
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("LocationManager: GPS استُؤنف — الجهاز يتحرك")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationPermissionStatus = manager.authorizationStatus

        // طلب موقع مبدئي للخريطة فقط عند منح الصلاحية
        // لا يفعّل background tracking
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            requestInitialLocationForMap()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager: خطأ — \(error.localizedDescription)")
    }

    // MARK: - مراقبة نقطة البداية

    private func startMonitoringReturnToStart(lat: Double, lng: Double) {
        originMonitorTask = Task {
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let region = CLMonitor.CircularGeographicCondition(center: center, radius: 1000)
            let monitorName = "origin\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"

            originMonitor = await CLMonitor(monitorName)
            await originMonitor?.add(region, identifier: "startPoint")

            guard let originMonitor else { return }
            var isFirstEvent = true

            do {
                for try await event in await originMonitor.events {
                    if isFirstEvent { isFirstEvent = false; continue }
                    if event.state == .satisfied {
                        delegate?.onUserReturnedToStartPoint()
                    }
                }
            } catch {
                print("LocationManager: خطأ في المراقبة — \(error.localizedDescription)")
            }
        }
    }

    private func stopOriginMonitoring() {
        originMonitorTask?.cancel()
        originMonitorTask = nil
        originMonitor = nil
    }
}

//
//  HomePageTripsViewModel.swift
//  Desert
//

import SwiftUI
import SwiftData
import CoreLocation
import Contacts
import Combine

class HomePageTripsViewModel: ObservableObject {

    // MARK: - Form Fields

    @Published var tripName: String = ""
    @Published var destination: String = ""
    @Published var destinationLat: Double = 0
    @Published var destinationLng: Double = 0
    @Published var returnTime: Date = Date()
    @Published var hasGroup: Bool = false
    @Published var groupSize: Int = 1
    @Published var userName: String = ""
    @Published var phoneNumber: String = ""
    @Published var carName: String = ""
    @Published var carColor: String = ""
    @Published var is4WD: Bool = false
    @Published var plateLetters: String = ""
    @Published var plateNumbers: String = ""
    @Published var emergencyContacts: [Contact] = []
    @Published var groupContacts: [Contact] = []

    // MARK: - UI State

    @Published var showEmergencyContactPicker = false
    @Published var showGroupContactPicker = false
    @Published var showDestinationPicker = false
    @Published var showLocationAlert = false
    @Published var locationAlertTitle = ""
    @Published var locationAlertMessage = ""
    @Published var showErrors = false

    // MARK: - Validation

    var destinationIsValid: Bool { !destination.isEmpty }
    var userNameIsValid: Bool { !userName.isEmpty }
    var phoneNumberIsValid: Bool { !phoneNumber.isEmpty }
    var returnTimeIsValid: Bool { returnTime > Date() }
    var emergencyContactsIsValid: Bool { !emergencyContacts.isEmpty }

    var formIsValid: Bool {
        destinationIsValid &&
        userNameIsValid &&
        phoneNumberIsValid &&
        returnTimeIsValid &&
        emergencyContactsIsValid
    }
}

// MARK: - Load Data

extension HomePageTripsViewModel {

    func loadSavedInfo(_ savedInfo: SavedInfo?) {
        guard let saved = savedInfo else { return }

        userName = saved.userName
        phoneNumber = saved.phoneNumber
        carName = saved.carName
        carColor = saved.carColor
        is4WD = saved.is4WD
        plateLetters = saved.plateLetters
        plateNumbers = saved.plateNumbers

        emergencyContacts = saved.defaultEmergencyContacts.map {
            Contact(name: $0.name, phone: $0.phone)
        }

        groupContacts = saved.defaultGroupContacts.map {
            Contact(name: $0.name, phone: $0.phone)
        }
    }

    func loadTripData(from trip: Trip) {
        tripName = trip.tripName
        destination = trip.destination
        destinationLat = trip.destinationLat
        destinationLng = trip.destinationLng
        hasGroup = trip.hasGroup
        groupSize = trip.groupSize
        userName = trip.userName
        phoneNumber = trip.phoneNumber
        carName = trip.carName
        carColor = trip.carColor
        is4WD = trip.is4WD
        plateLetters = trip.plateLetters
        plateNumbers = trip.plateNumbers

        emergencyContacts = trip.emergencyContacts.map {
            Contact(name: $0.name, phone: $0.phone)
        }

        groupContacts = trip.groupContacts.map {
            Contact(name: $0.name, phone: $0.phone)
        }

        returnTime = Date()
    }
}

// MARK: - Contacts

extension HomePageTripsViewModel {

    func importEmergencyContact(_ contact: CNContact) {
        emergencyContacts.append(Contact(
            name: "\(contact.givenName) \(contact.familyName)",
            phone: contact.phoneNumbers.first?.value.stringValue ?? ""
        ))
    }

    func importGroupContact(_ contact: CNContact) {
        groupContacts.append(Contact(
            name: "\(contact.givenName) \(contact.familyName)",
            phone: contact.phoneNumbers.first?.value.stringValue ?? ""
        ))
    }

    func removeEmergencyContact(at offsets: IndexSet) {
        emergencyContacts.remove(atOffsets: offsets)
    }

    func removeGroupContact(at offsets: IndexSet) {
        groupContacts.remove(atOffsets: offsets)
    }
}

// MARK: - Start Trip

extension HomePageTripsViewModel {

    @discardableResult
    func startTrip(context: ModelContext) -> Bool {

        let status = CLLocationManager.authorizationStatus()

        switch status {

        case .notDetermined, .denied, .restricted:
            locationAlertTitle = "location_permission_required".localized
            locationAlertMessage = "Please enable location access in Settings to start a trip."
            showLocationAlert = true
            return false

        case .authorizedWhenInUse:
            locationAlertTitle = "location_permission_required".localized
            locationAlertMessage = "Please enable Always Allow location permission in Settings to start a trip."
            showLocationAlert = true
            return false

        case .authorizedAlways:
            break

        @unknown default:
            locationAlertTitle = "location_permission_required".localized
            locationAlertMessage = "Please enable location access in Settings to start a trip."
            showLocationAlert = true
            return false
        }

        guard formIsValid else {
            showErrors = true
            return false
        }

        let trip = Trip(
            tripId: "",
            tripName: tripName.isEmpty ? defaultTripName() : tripName,
            userName: userName,
            phoneNumber: phoneNumber,
            destination: destination,
            destinationLat: destinationLat,
            destinationLng: destinationLng,
            returnTime: returnTime,
            hasGroup: hasGroup,
            groupSize: groupSize,
            carName: carName,
            carColor: carColor,
            is4WD: is4WD,
            plateLetters: plateLetters,
            plateNumbers: plateNumbers
        )

        trip.emergencyContacts = emergencyContacts
        trip.groupContacts = groupContacts

        saveUserInfo(context: context)
        TripSessionManager.shared.startTrip(trip: trip, context: context)

        return true
    }

    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func defaultTripName() -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f.string(from: Date())
    }

    private func saveUserInfo(context: ModelContext) {
        let descriptor = FetchDescriptor<SavedInfo>()

        if let existing = (try? context.fetch(descriptor))?.first {
            existing.userName = userName
            existing.phoneNumber = phoneNumber
            existing.carName = carName
            existing.carColor = carColor
            existing.is4WD = is4WD
            existing.plateLetters = plateLetters
            existing.plateNumbers = plateNumbers

            existing.defaultEmergencyContacts = emergencyContacts.map {
                SavedContact(name: $0.name, phone: $0.phone, contactType: "emergency")
            }

            existing.defaultGroupContacts = groupContacts.map {
                SavedContact(name: $0.name, phone: $0.phone, contactType: "group")
            }

        } else {
            let saved = SavedInfo(
                userName: userName,
                phoneNumber: phoneNumber,
                carName: carName,
                carColor: carColor,
                is4WD: is4WD,
                plateLetters: plateLetters,
                plateNumbers: plateNumbers
            )

            saved.defaultEmergencyContacts = emergencyContacts.map {
                SavedContact(name: $0.name, phone: $0.phone, contactType: "emergency")
            }

            saved.defaultGroupContacts = groupContacts.map {
                SavedContact(name: $0.name, phone: $0.phone, contactType: "group")
            }

            context.insert(saved)
        }
    }
}

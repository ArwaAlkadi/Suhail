//
//  SavedInfo.swift
//  Desert
//
//  Created by Arwa Alkadi on 21/04/2026.
//

import SwiftData
import Foundation

/// Stores the user's default data for auto-filling future trips.
/// Updated after each trip when "Save my info" is enabled.
@Model
class SavedInfo {
    
    var userName: String
    var phoneNumber: String
    var carName: String
    var carColor: String
    var is4WD: Bool
    var plateLetters: String
    var plateNumbers: String
    
  
    /// Default emergency contacts — auto-filled when creating a new trip.
    var defaultEmergencyContacts: [SavedContact]
    
    init(
        userName: String,
        phoneNumber: String,
        carName: String,
        carColor: String,
        is4WD: Bool,
        plateLetters: String,
        plateNumbers: String
    ) {
        self.userName = userName
        self.phoneNumber = phoneNumber
        self.carName = carName
        self.carColor = carColor
        self.is4WD = is4WD
        self.plateLetters = plateLetters
        self.plateNumbers = plateNumbers
        self.defaultEmergencyContacts = []
    }
}


// MARK: - SavedContact

/// A saved contact inside `SavedInfo` — converted to `Contact` when a new trip starts.
@Model
class SavedContact {
    var name: String
    var phone: String
    
    /// Contact type — either `"emergency"` or `"group"`.
    var contactType: String
    
    init(name: String, phone: String, contactType: String) {
        self.name = name
        self.phone = phone
        self.contactType = contactType
    }
}

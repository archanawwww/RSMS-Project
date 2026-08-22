//
//  Appointment.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Sales Associate Team                 │
//  │  DOMAIN: Customer & Sales — Scheduling       │
//  │  USER STORIES: SA-07, VIP Appointments       │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Sales Associate — schedules and manages appointments
//  • Boutique Manager — views upcoming appointments for their store
//
//  WHAT THIS MODEL DOES:
//  A scheduled interaction between a Sales Associate and a Customer.
//  Used for VIP private viewings, personal shopping sessions, and
//  follow-up consultations.
//
//  APPOINTMENT TYPES:
//  ┌─────────────────────┬─────────────────────────────────────┐
//  │ privateViewing      │ VIP-only exclusive product showcase  │
//  │ personalShopping    │ Guided shopping session              │
//  │ consultation        │ Style/product advice                 │
//  │ followUp            │ Post-purchase check-in               │
//  │ repairPickup        │ Collect repaired items               │
//  └─────────────────────┴─────────────────────────────────────┘
//
//  CROSS-REFERENCE:
//  • customerID → SalesAssociate/Customer.swift
//  • salesAssociateID → CorporateAdmin/User.swift
//

import Foundation

// MARK: - Appointment

struct Appointment: Identifiable, Codable, Hashable {

    let id: UUID
    var customerID: UUID           // who the appointment is with
    var salesAssociateID: UUID     // who is hosting
    var date: Date                 // scheduled date and time
    var type: AppointmentType
    var notes: String?             // e.g. "Interested in new Hermès collection"
    var status: AppointmentStatus

    init(
        id: UUID = UUID(),
        customerID: UUID,
        salesAssociateID: UUID,
        date: Date,
        type: AppointmentType,
        notes: String? = nil,
        status: AppointmentStatus = .scheduled
    ) {
        self.id = id
        self.customerID = customerID
        self.salesAssociateID = salesAssociateID
        self.date = date
        self.type = type
        self.notes = notes
        self.status = status
    }
}

// MARK: - AppointmentType

enum AppointmentType: String, Codable, CaseIterable, Hashable {
    case privateViewing   = "Private Viewing"
    case personalShopping = "Personal Shopping"
    case consultation     = "Consultation"
    case followUp         = "Follow-Up"
    case repairPickup     = "Repair Pickup"
}

// MARK: - AppointmentStatus

enum AppointmentStatus: String, Codable, CaseIterable, Hashable {
    case scheduled  = "Scheduled"    // booked but not confirmed
    case confirmed  = "Confirmed"    // customer confirmed attendance
    case inProgress = "In Progress"  // currently happening
    case completed  = "Completed"    // finished
    case cancelled  = "Cancelled"    // cancelled by either party
    case noShow     = "No Show"      // customer didn't show up
}

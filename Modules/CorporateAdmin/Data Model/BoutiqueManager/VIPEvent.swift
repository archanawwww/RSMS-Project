//
//  VIPEvent.swift
//  Noir Luxe — RSMS
//
//  ┌──────────────────────────────────────────────┐
//  │  OWNER: Boutique Manager Team                │
//  │  DOMAIN: Client Events — VIP Trunk Shows     │
//  │  USER STORIES: BM-206                        │
//  └──────────────────────────────────────────────┘
//
//  WHO USES THIS MODEL:
//  • Boutique Manager — creates VIP trunk shows, manages event capacity, and tracks digital RSVPs
//  • Corporate Admin — sends marketing campaigns and provides support for upcoming VIP events
//  • Sales Associate — engages with invited clients and monitors client attendance
//
//  WHAT THIS MODEL DOES:
//  Represents a VIP trunk show or client event organized by a Boutique Manager.
//  Captures core event parameters explicitly defined in BM-206: title, date, time, and maximum capacity limit.
//  Manages digital invitations dispatched to clients selected from the CRM database and dynamically tracks
//  real-time RSVP statuses (Accepted, Declined, Pending) as clients respond.
//
//  WORKFLOW:
//  1. Boutique Manager creates a VIPEvent containing a title, date, time, and maximum capacity limit.
//  2. Boutique Manager selects clients from the CRM database (Customer) and triggers dispatch of EventInvitations.
//  3. Invitations update dynamically in real time as clients respond (Accepted, Declined, Pending).
//  4. Event dashboard aggregates RSVP counts dynamically to manage capacity and client attendance.
//
//  NON-FUNCTIONAL REQUIREMENTS & SECURITY (BM-206 NFRs):
//  • Real-time synchronization: Event creation and RSVP updates must synchronize in real time across all channels.
//  • Privacy & Encryption: Client information must be protected using encryption and privacy controls.
//  • Role-Based Access: Only authorized boutique managers can create or modify VIP events.
//  • Scalability: System must support large invitation and RSVP volumes without performance degradation.
//  • Consistency & Accessibility: RSVP data must remain consistent across all channels, and event screens must be accessible and easy to navigate.
//
//  CROSS-REFERENCE:
//  • storeID → BoutiqueManager/Store.swift
//  • organizerID → CorporateAdmin/User.swift (Boutique Manager)
//  • customerID → SalesAssociate/Customer.swift (CRM Database)
//

import Foundation

// MARK: - VIPEvent

struct VIPEvent: Identifiable, Codable, Hashable {

    let id: UUID
    var storeID: UUID                  // The boutique where the event is held
    var organizerID: UUID              // User.id of the Boutique Manager organizing the event
    var title: String                  // Title of the VIP Trunk Show / Event
    var date: Date                     // Date of the event
    var time: String                   // Time of the event (e.g., "18:00 - 21:00")
    var maxCapacity: Int               // Maximum capacity limit for the event
    var invitations: [EventInvitation] // Digital invitations sent to CRM clients
    var campaignID: UUID?              // Optional reference to Corporate Admin campaign

    // MARK: - Dynamic RSVP Calculations

    /// Dynamically calculates the count of accepted RSVPs
    var acceptedCount: Int {
        invitations.filter { $0.rsvpStatus == .accepted }.count
    }

    /// Dynamically calculates the count of declined RSVPs
    var declinedCount: Int {
        invitations.filter { $0.rsvpStatus == .declined }.count
    }

    /// Dynamically calculates the count of pending RSVPs
    var pendingCount: Int {
        invitations.filter { $0.rsvpStatus == .pending }.count
    }

    /// Checks if the current accepted RSVPs have reached or exceeded the maximum capacity limit
    var isAtCapacity: Bool {
        acceptedCount >= maxCapacity
    }

    // MARK: - Init

    init(
        id: UUID = UUID(),
        storeID: UUID,
        organizerID: UUID,
        title: String,
        date: Date,
        time: String,
        maxCapacity: Int,
        invitations: [EventInvitation] = [],
        campaignID: UUID? = nil
    ) {
        self.id = id
        self.storeID = storeID
        self.organizerID = organizerID
        self.title = title
        self.date = date
        self.time = time
        self.maxCapacity = maxCapacity
        self.invitations = invitations
        self.campaignID = campaignID
    }
}

// MARK: - EventInvitation

struct EventInvitation: Identifiable, Codable, Hashable {

    let id: UUID
    var eventID: UUID                  // Reference to the VIPEvent
    var customerID: UUID               // Customer.id from the CRM database (encrypted/protected)
    var rsvpStatus: RSVPStatus         // Real-time RSVP status
    var sentAt: Date                   // When the digital invitation was dispatched
    var respondedAt: Date?             // When the client responded to the invitation

    init(
        id: UUID = UUID(),
        eventID: UUID,
        customerID: UUID,
        rsvpStatus: RSVPStatus = .pending,
        sentAt: Date = Date(),
        respondedAt: Date? = nil
    ) {
        self.id = id
        self.eventID = eventID
        self.customerID = customerID
        self.rsvpStatus = rsvpStatus
        self.sentAt = sentAt
        self.respondedAt = respondedAt
    }
}

// MARK: - RSVPStatus

enum RSVPStatus: String, Codable, CaseIterable, Hashable {
    case accepted = "Accepted"         // Client has confirmed attendance
    case declined = "Declined"         // Client has declined invitation
    case pending  = "Pending"          // Invitation dispatched, awaiting client response
}

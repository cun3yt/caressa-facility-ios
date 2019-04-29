//
//  Calendar.swift
//  Caressa
//
//  Created by Hüseyin Metin on 27.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import Foundation

struct CalendarModel: Codable {
    let date: String
    let events: Events
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case events = "events"
    }
}

struct Events: Codable {
    let count: Int
    let allDay: AllDay
    let hourlyEvents: HourlyEvents
    
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case allDay = "all_day"
        case hourlyEvents = "hourly_events"
    }
}

struct AllDay: Codable {
    let count: Int
    let allDaySet: [AllDaySet]
    
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case allDaySet = "set"
    }
}

struct AllDaySet: Codable {
    let summary: String
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case summary = "summary"
        case location = "location"
    }
}

struct HourlyEvents: Codable {
    let count: Int
    let hourlyEventsSet: [HourlyEventsSet]
    
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case hourlyEventsSet = "set"
    }
}

struct HourlyEventsSet: Codable {
    let start: Date
    let startSpoken: String
    let summary: String
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case start = "start"
        case startSpoken = "start_spoken"
        case summary = "summary"
        case location = "location"
    }
}

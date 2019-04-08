//
//  DateManager.swift
//  Caressa
//
//  Created by Hüseyin METİN on 22.03.2019.
//  Copyright © 2018 Hüseyin METİN. All rights reserved.
//

import Foundation

public class DateManager {
    private let formatter: DateFormatter
    
    init(_ format: String) {
        formatter = DateFormatter()
        formatter.dateFormat = format
    }
    
    func string(date: Date) -> String {
        return formatter.string(from: date)
    }
    
    func date(string: String) -> Date? {
        return formatter.date(from: string)
    }
    
    static func onlyDate(date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let oDate = Calendar.current.date(from: components)
        return oDate!
    }

    static func getDateParts(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        if seconds.isNaN { return (0,0,0) }
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    static func startOfWeek() -> Date? {
        let calendar = Calendar.current
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return nil }
        return calendar.date(byAdding: .day, value: 1, to: sunday)
    }
    
    static func endOfWeek() -> Date? {
        let calendar = Calendar.current
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return nil }
        return calendar.date(byAdding: .day, value: 7, to: sunday)
    }
    
    static func dayOfWeek(today: Date) -> Int? {
        let calendar = Calendar.current
        let weekDay = calendar.component(.weekday, from: today)
        return weekDay
    }
    
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
}

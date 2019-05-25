//
//  DateManager.swift
//  Caressa
//
//  Created by Hüseyin METİN on 22.03.2019.
//  Copyright © 2018 Hüseyin METİN. All rights reserved.
//

import UIKit

public class DateManager: NSObject {
    private let formatter: DateFormatter

    private var calendar: Calendar
    private var appDel = (UIApplication.shared.delegate as! AppDelegate)
//    static private var calendar: Calendar = {
//        var calendar = Calendar(identifier: .gregorian)
//        calendar.timeZone = TimeZone(abbreviation: "UTC")!
//        return calendar
//    }()
    
    init(_ format: String? = nil, useUTC: Bool? = nil, onlyTime: Bool = false) {
        calendar = Calendar(identifier: .gregorian)
        formatter = DateFormatter()
        
        if let timezone = appDel.serverTimeState?.timezone {
            calendar.timeZone = TimeZone(identifier: timezone)!
            formatter.timeZone = TimeZone(identifier: timezone)!
        }
        if useUTC == true {
            calendar.timeZone = TimeZone(abbreviation: "UTC")!
            formatter.timeZone = TimeZone(abbreviation: "UTC")!
        }
        
        if let format = format {
            formatter.dateFormat = format
        } else {
            if !onlyTime {
                formatter.dateStyle = .short
            }
            formatter.timeStyle = .short
        }
    }
    
    func now() -> Date {
        return appDel.serverTimeState?.currentTime ?? Date()
    }
    
    func string(date: Date) -> String {
        return formatter.string(from: date)
    }
    
    func date(string: String) -> Date? {
        return formatter.date(from: string)
    }
    
    func onlyDate(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let oDate = calendar.date(from: components)
        return oDate!
    }

    func getDateParts(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        if seconds.isNaN { return (0,0,0) }
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    func startOfWeek() -> Date? {
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return nil }
        return calendar.date(byAdding: .day, value: 1, to: sunday)
    }
    
    func endOfWeek() -> Date? {
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return nil }
        return calendar.date(byAdding: .day, value: 7, to: sunday)
    }
    
    func dayOfWeek(today: Date) -> Int? {
        let weekDay = calendar.component(.weekday, from: today)
        return weekDay
    }
    
    func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
}

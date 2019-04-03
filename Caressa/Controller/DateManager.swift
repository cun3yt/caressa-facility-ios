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

    class func getDateParts(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        if seconds.isNaN { return (0,0,0) }
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
}

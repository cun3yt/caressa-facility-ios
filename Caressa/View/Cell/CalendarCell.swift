//
//  CalendarCell.swift
//  Caressa
//
//  Created by Hüseyin Metin on 6.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class CalendarCell: UITableViewCell {
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblActivity: UILabel!
    @IBOutlet weak var lblPlace: UILabel!
    
    func setup(set: HourlyEventsSet) {
        lblTime.text = set.startSpoken
        lblActivity.text = set.summary
        lblPlace.text = set.location
        
        if set.start < Date() {
            lblTime.textColor = .lightGray
            lblActivity.textColor = .lightGray
            lblPlace.textColor = .lightGray
        } else {
            lblTime.textColor = .black
            lblActivity.textColor = .black
            lblPlace.textColor = .black
        }
    }
    
}

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
    
    func setup(date: Date, item: String) {
        lblTime.text = DateManager("hh:MM a").string(date: date)
        lblActivity.text = item
        lblPlace.text = "Library"
        
        if date < Date() {
            lblTime.textColor = .lightGray
            lblActivity.textColor = .lightGray
            lblPlace.textColor = .lightGray
        } else {
            lblTime.textColor = .black
            lblActivity.textColor = .black
            lblPlace.textColor = .black
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

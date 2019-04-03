//
//  ResidentCell.swift
//  Caressa
//
//  Created by Hüseyin Metin on 23.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

protocol ResidentCellDelegate {
    func touchCheckButon(_ isSelected: Bool)
}

class ResidentCell: UITableViewCell  {

    @IBOutlet weak var ivThumb: UIImageView!
    @IBOutlet weak var vStatus: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var btnCheck: UIButton!
    
    private var resident: Resident!
    
    public var delegate: ResidentCellDelegate?
    public var navigationController: UINavigationController?
    
    func setup(resident: Resident) {
        self.resident = resident
        self.contentView.alpha = 1.0
        if let devStat = resident.deviceStatus {
            if devStat.isOnline {
                vStatus.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            } else {
                vStatus.backgroundColor = #colorLiteral(red: 1, green: 0.1564272642, blue: 0.18738392, alpha: 1)
            }
        } else {
            self.contentView.alpha = 0.4
        }
        
        lblName.text = "\(resident.firstName) \(resident.lastName)"
        lblRoom.text = "Room # \(resident.roomNo)"
        ImageManager.shared.downloadImage(suffix: resident.profilePicture, view: ivThumb)
        
        btnCheck.isHidden = resident.checkInInfo == nil
        if let ci = resident.checkInInfo {
            btnCheck.isHidden = ci.checkedBy == "self"
            btnCheck.isSelected = !(ci.checkedBy ?? "").isEmpty
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btnCheck.setImage(#imageLiteral(resourceName: "checked"), for: .selected)
        btnCheck.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func checkAction(_ sender: UIButton) {
        btnCheck.isSelected = !btnCheck.isSelected
        delegate?.touchCheckButon(sender.isSelected)
    }
    
    @IBAction func btnMessageAction(_ sender: Any) {
        WindowManager.pushToMessageThreadVC(navController: navigationController, resident: resident)
    }
    
}

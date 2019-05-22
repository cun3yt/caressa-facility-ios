//
//  ResidentCell.swift
//  Caressa
//
//  Created by Hüseyin Metin on 23.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

protocol ResidentCellDelegate {
    func touchCheckButon(_ isSelected: Bool, resident: Resident)
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
        
        vStatus.backgroundColor = .clear
        //self.contentView.alpha = 1.0
        ivThumb.alpha = 1.0
        lblName.alpha = 1.0
        lblRoom.alpha = 1.0
        btnMessage.alpha = 1.0
        lblDetail.alpha = 1.0
        
        if let devStat = resident.deviceStatus {
            if devStat.isThereDevice,
                let isOnline = devStat.status.isOnline {
                vStatus.backgroundColor = isOnline ? #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) : #colorLiteral(red: 1, green: 0.1564272642, blue: 0.18738392, alpha: 1)
            } else {
                vStatus.backgroundColor = .lightGray
                ivThumb.alpha = 0.5
                lblName.alpha = ivThumb.alpha
                lblRoom.alpha = ivThumb.alpha
                lblDetail.alpha = ivThumb.alpha
            }
        }
        
        lblName.text = "\(resident.firstName) \(resident.lastName)"
        lblRoom.text = "Room # \(resident.roomNo)"
        if let tempImage = SessionManager.shared.temporaryProfile,
            tempImage.id == resident.id {
            ivThumb.image = tempImage.image
        } else {
            ImageManager.shared.downloadImage(suffix: resident.profilePicture, view: ivThumb)
        }
            
        
        btnCheck.isHidden = resident.checkIn == nil
        if let ci = resident.checkIn {
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
        delegate?.touchCheckButon(sender.isSelected, resident: self.resident)
    }
    
    @IBAction func btnMessageAction(_ sender: Any) {
        //if resident.messageThreadURL.url != nil {
            WindowManager.pushToMessageThreadVC(navController: navigationController, resident: resident)
        //}
    }
    
}

//
//  PhotoCell.swift
//  Caressa
//
//  Created by Hüseyin Metin on 6.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var ivSelected: UIImageView!
    
    func setup(url: String) {
        ImageManager.shared.downloadImage(suffix: url, view: ivImage)
    }
    
    override func prepareForReuse() {
        //super.prepareForReuse()
        ivImage.image = nil
        ivSelected.image = nil
    }
    
    override var isSelected: Bool {
        didSet {
            if let cv = self.superview as? UICollectionView,
                cv.allowsMultipleSelection {
                if isSelected {
                    ivSelected.image = #imageLiteral(resourceName: "checked")
                } else {
                    ivSelected.image = nil
                }
            }
            
        }
    }

}

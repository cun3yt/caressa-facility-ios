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
    
    func setup(image: UIImage) {
        ivImage.image = image
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

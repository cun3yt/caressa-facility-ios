//
//  ImageManager.swift
//  Caressa
//
//  Created by Hüseyin METİN on 22.03.2019.
//  Copyright © 2018 Hüseyin METİN. All rights reserved.
//

import UIKit

class ImageManager: NSObject {
    
    static let shared: ImageManager = ImageManager()
    
    let mediaURL = "" //APIConst.WebBase + "/public/images/proclamation/"
    let imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(suffix: String?, view: UIImageView, width: CGFloat? = nil, height: CGFloat? = nil, completion: (() -> Void)? = nil) {
        
        view.image = UIImage(named: "emptyphoto")
        
        if let suffix = suffix {
            
            if let url = URL(string: "\(mediaURL)\(suffix)") {
                if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
                    
                    DispatchQueue.main.async {
                        view.image = cachedImage
                        completion?()
                    }
                    
                } else {
                    
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        guard error == nil else { return }
                        guard data != nil else { return }
                        guard let image = UIImage(data: data!) else { return }
                        
                        self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                        
                        DispatchQueue.main.async {
                            view.image = image
                            completion?()
                        }
                    }).resume()
                }
            }
        }
    }
    
    func downloadImage(url: String?, view: UIButton, completion: (() -> Void)? = nil) {
        
        view.setImage(UIImage(named: "emptyphoto"), for: .normal)
        
        if let suffix = url {
            
            if let url = URL(string: "\(mediaURL)\(suffix)") {
                if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
                    
                    DispatchQueue.main.async {
                        view.setImage(cachedImage, for: .normal)
                        completion?()
                    }
                    
                } else {
                    
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        guard error == nil else { return }
                        guard data != nil else { return }
                        guard let image = UIImage(data: data!) else { return }
                        
                        self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                        
                        DispatchQueue.main.async {
                            view.setImage(image, for: .normal)
                            completion?()
                        }
                    }).resume()
                }
            }
        }
    }
    
    func resize(_ image: UIImage, width: CGFloat) -> UIImage {
        var actualHeight = image.size.height
        var actualWidth = image.size.width
        let maxHeight: CGFloat = width
        let maxWidth: CGFloat = width
        var imgRatio: CGFloat = actualWidth / actualHeight
        let maxRatio: CGFloat = maxWidth / maxHeight
        let compressionQuality: CGFloat = 0.5
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.jpegData(compressionQuality: compressionQuality)
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
}

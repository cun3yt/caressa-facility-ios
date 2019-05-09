//
//  ImageManager.swift
//  Caressa
//
//  Created by Hüseyin METİN on 22.03.2019.
//  Copyright © 2018 Hüseyin METİN. All rights reserved.
//

import UIKit
import CropViewController
import DKImagePickerController

class ImageManager: NSObject {
    
    static let shared: ImageManager = ImageManager()
    
    private lazy var multiImagePicker = DKImagePickerController()
    private lazy var imagePicker = UIImagePickerController()
    private var onImagesSelect: (([UIImage]) -> Void)?
    private var onImageSelect: ((UIImage) -> Void)?
    
    let mediaURL = "" //APIConst.WebBase + "/public/images/proclamation/"
    let imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(suffix: String?, view: UIImageView, width: CGFloat? = nil, height: CGFloat? = nil, completion: (() -> Void)? = nil) {
        
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.frame.origin = CGPoint(x: view.frame.midX - (indicator.frame.width / 2), y: view.frame.midY - (indicator.frame.height / 2))
        view.addSubview(indicator)
        indicator.bringSubviewToFront(view)
        indicator.startAnimating()
        view.image = UIImage(named: "emptyPhoto")
        
        if let suffix = suffix {
            
            if let url = URL(string: "\(mediaURL)\(suffix)") {
                if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
                    
                    DispatchQueue.main.async {
                        view.image = cachedImage
                        indicator.removeFromSuperview()
                        completion?()
                    }
                    
                } else {
                    
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        guard error == nil else { return }
                        guard data != nil else { return }
                        guard let image = UIImage(data: data!) else {
                            DispatchQueue.main.async {
                                view.image = #imageLiteral(resourceName: "default_profile.jpg")
                                indicator.removeFromSuperview()
                            }
                            return
                        }
                        
                        self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                        
                        DispatchQueue.main.async {
                            indicator.removeFromSuperview()
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
                        guard let image = UIImage(data: data!) else {
                            DispatchQueue.main.async { view.setImage(#imageLiteral(resourceName: "default_profile.jpg"), for: .normal) }
                            return
                        }
                        
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
    
    func resizeAspect(_ image: UIImage, width: CGFloat) -> UIImage {
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
    
    func crop(_ image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = width
        var cgheight: CGFloat = height
        
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    
    
    func takePhoto(view: UIViewController, completion: ((UIImage) -> Void)? = nil) {
        
        let prompt = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        prompt.addAction(UIAlertAction(title: "Camera", style: .default) { (_) in
            self.takePhoto(from: .camera, view: view, completion: completion)
        })
        prompt.addAction(UIAlertAction(title: "Photo Libary", style: .default) { (_) in
            self.takePhoto(from: .savedPhotosAlbum, view: view, completion: completion)
        })
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        view.present(prompt, animated: true)
    }
    
    func takePhoto(from: UIImagePickerController.SourceType, view: UIViewController, completion: ((UIImage) -> Void)? = nil) {
        if UIImagePickerController.isSourceTypeAvailable(from){
            imagePicker.delegate = self
            imagePicker.sourceType = from
            imagePicker.allowsEditing = false
            
            view.present(imagePicker, animated: true)
            onImageSelect = completion
        }
    }
    
    // MARK: Multi
    func takePhotos(view: UIViewController, completion: (([UIImage]) -> Void)? = nil) {
        
        let prompt = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        prompt.addAction(UIAlertAction(title: "Camera", style: .default) { (_) in
            self.takePhotos(from: .camera, view: view, completion: completion)
        })
        prompt.addAction(UIAlertAction(title: "Photo Libary", style: .default) { (_) in
            self.takePhotos(from: .photo, view: view, completion: completion)
        })
        prompt.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        view.present(prompt, animated: true)
    }
    
    func takePhotos(from: DKImagePickerControllerSourceType, view: UIViewController, completion: (([UIImage]) -> Void)? = nil) {
        multiImagePicker.delegate = self
        multiImagePicker.allowMultipleTypes = true
        multiImagePicker.sourceType = from
        
        multiImagePicker.didSelectAssets = { [unowned self] (assets) in
            var images: [UIImage] = []
            let queue = DispatchGroup()
            for asset in assets {
                queue.enter()
                asset.fetchOriginalImage(completeBlock: { (image, _) in
                    if let image = image {
                        images.append(image)
                    }
                    queue.leave()
                })
            }
            queue.notify(queue: .main, execute: {
                self.onImagesSelect?(images)
            })
        }
        
        view.present(multiImagePicker, animated: true)
        onImagesSelect = completion
    }
    
    
    func fixOrientation(image: UIImage) -> UIImage {
        if (image.imageOrientation == .up) { return image }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        image.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
}

extension ImageManager: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = fixOrientation(image:  info[.originalImage] as! UIImage )
        let cropVC = CropViewController(image: image)
        cropVC.aspectRatioPreset = .presetSquare
        cropVC.aspectRatioLockEnabled = true
        cropVC.aspectRatioPickerButtonHidden = true
        cropVC.delegate = self
        imagePicker.dismiss(animated: true, completion: {
            WindowManager.getTopView()?.present(cropVC, animated: true)
        })
    }
}

extension ImageManager: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true)
        onImageSelect?(image)
    }
}

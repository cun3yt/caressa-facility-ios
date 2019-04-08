//
//  PhotosVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 6.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class PhotosVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var ivFacility: UIButton!
    private var album: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        ivFacility = WindowManager.setup(vc: self, title: "Photos")
        ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture, view: ivFacility)
        
        album.append(#imageLiteral(resourceName: "Logo"))
        album.append(#imageLiteral(resourceName: "Logo"))
        album.append(#imageLiteral(resourceName: "Logo"))
        album.append(#imageLiteral(resourceName: "Logo"))
        album.append(#imageLiteral(resourceName: "Logo"))
        album.append(#imageLiteral(resourceName: "Logo"))
        album.append(#imageLiteral(resourceName: "Logo"))
        album.append(#imageLiteral(resourceName: "Logo"))
        album.append(#imageLiteral(resourceName: "Logo"))
    }
    
    @IBAction func btnCameraAction(_ sender: UIBarButtonItem) {
        ImageManager.shared.takePhoto(from: .camera, view: self) { (image) in
            
        }
    }
    
    @IBAction func btnPhotoAction(_ sender: UIBarButtonItem) {
        ImageManager.shared.takePhoto(from: .photoLibrary, view: self) { (image) in
            
        }
    }
}

extension PhotosVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.setup(image: album[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! PhotoHeaderView
            header.lblTitle.text = "Saturday, April 6, 2019"
            return header
        } else
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! PhotoFooterView
                footer.btnMore.setTitle("10 more...", for: .normal)
                return footer
        }
        return UICollectionReusableView()
    }
}

extension PhotosVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageInfo   = GSImageInfo(image: album[indexPath.row], imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: collectionView.cellForItem(at: indexPath)!)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true)
    }
}

extension PhotosVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width / 2) - 20
        return CGSize(width: width, height: width)
    }
}

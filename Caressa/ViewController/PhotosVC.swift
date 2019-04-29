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
    private var photoDays: [PhotoGalleryDay] = []
    private var photos: [[Photo]] = []
    
    private var moreSections: [Int] = []
    private let showPhotoCount = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        ivFacility = WindowManager.setup(vc: self, title: "Photos")
        ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture, view: ivFacility)
        
        setup()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        WindowManager.repaintBarTitle(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        WindowManager.repaintBarTitle(vc: self)
    }
    
    @IBAction func btnCameraAction(_ sender: UIBarButtonItem) {
        ImageManager.shared.takePhoto(from: .camera, view: self) { (image) in
            
        }
    }
    
    @IBAction func btnPhotoAction(_ sender: UIBarButtonItem) {
        ImageManager.shared.takePhoto(from: .photoLibrary, view: self) { (image) in
            
        }
    }
    
    func setup() {
        WebAPI.shared.get(APIConst.photoGallery) { (result: PhotoGallery) in
            self.photoDays = result.results
            //self.photoDays.insert(PhotoGalleryDay(day: Day(date: "2019-04-10", url: "https://caressa.herokuapp.com/api/photo-galleries/1/days/2019-04-10/")), at: 0)
            
            for i in self.photoDays {
                WebAPI.shared.get(String(format: APIConst.photoGalleryDates, i.day.date), completion: { (result2: PhotoDay) in
                    
                    self.photos.append(result2.results)
                    
                    if self.photoDays.count == self.photos.count {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func btnMore(_ sender: UIButton) {
        if moreSections.contains(sender.tag) {
            if let i = moreSections.index(of: sender.tag) {
                moreSections.remove(at: i)
            }
        } else {
            moreSections.append(sender.tag)
        }
        collectionView.reloadSections(IndexSet(integer: sender.tag))
    }
}

extension PhotosVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photoDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let spc = photos[section].count
        return moreSections.contains(section) ? spc : (spc > showPhotoCount ? showPhotoCount : spc)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.setup(url:  photos[indexPath.section][indexPath.row].url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! PhotoHeaderView
            header.lblTitle.text = photoDays[indexPath.section].day.date
            return header
        } else
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! PhotoFooterView
                let more = photos[indexPath.section].count - 3
                footer.btnMore.setTitle("\(more) more...", for: .normal)
                footer.btnMore.tag = indexPath.section
                footer.btnMore.addTarget(self, action: #selector(btnMore(_:)), for: .touchUpInside)
                return footer
        }
        return UICollectionReusableView()
    }
}

extension PhotosVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let images = photos[indexPath.section].map({$0.url})
        let imageSlider = ZoomableImageSlider(images: images, currentIndex: indexPath.row, placeHolderImage: nil)
        present(imageSlider, animated: true)
    }
}

extension PhotosVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let width = collectionView.bounds.width
        return moreSections.contains(section) ? CGSize(width: width, height: 0) : (photos[section].count > showPhotoCount ? CGSize(width: width, height: 40) : CGSize(width: width, height: 0))
    }
}

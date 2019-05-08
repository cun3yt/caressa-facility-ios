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
    
    private var page: Int = 1
    private var pageCount: Int = 1
    private var nextPage: String?
    private var ivFacility: UIButton!
    private var photoDays: [PhotoGalleryDay] = []
    private var photos: [[Photo]] = []
    private var refreshControl = UIRefreshControl(frame: .zero)
    
    private var moreSections: [Int] = []
    private let showPhotoCount = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        refreshControl.addTarget(self, action: #selector(setup), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
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
        ImageManager.shared.takePhotos(from: .camera, view: self) { (images) in
            self.upload(images: images)
        }
    }
    
    @IBAction func btnPhotoAction(_ sender: UIBarButtonItem) {
        ImageManager.shared.takePhotos(from: .photo, view: self) { (images) in
            self.upload(images: images)
        }
    }
    
    @objc func setup() {
        let url_ = nextPage != nil ? nextPage : APIConst.photoGallery
        guard let url = url_ else { return }
        
        WebAPI.shared.get(url) { (result: PhotoGallery) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
            let startPoint = self.photoDays.count
            if self.nextPage != nil {
                self.photoDays = self.photoDays + result.results
            } else {
                self.photoDays = result.results
            }
            self.pageCount = result.count / result.results.count
            self.nextPage = result.next
            
            //self.photoDays.insert(PhotoGalleryDay(day: Day(date: "2019-04-10", url: "https://caressa.herokuapp.com/api/photo-galleries/1/days/2019-04-10/")), at: 0)
            
            //for i in self.photoDays {
            for i in startPoint..<self.photoDays.count {
                let p = self.photoDays[i]
                
                WebAPI.shared.get(String(format: APIConst.photoGalleryDates, p.day.date), completion: { (result2: PhotoDay) in
                    
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
    
    func upload(images: [UIImage]?) {
        guard let images = images, !images.isEmpty else { return }

        //ActivityManager.shared.startActivity()
        
        var param: [PresignedRequest] = []
        var imageDatas: [Data] = []
        let queue = DispatchGroup()
        var keyList: [UploadedNewPhoto] = []
        
        WebAPI.shared.disableActivity = true
        for image in images {
            queue.enter()
            
            imageDatas.append(image.pngData()!)
            let key = "\(UUID().uuidString.prefix(6))"
            param.append(PresignedRequest(key: key,
                                         contentType: "image/png",
                                         clientMethod: "put_object",
                                         requestType: "PUT"))
            keyList.append(UploadedNewPhoto(key: key))
        }
        
        WebAPI.shared.post(APIConst.generateSignedURL, parameter: param) { (response: [PresignedResponse]) in
            for (i,url) in response.enumerated() {
                WebAPI.shared.put(url.url, parameter: imageDatas[i], completion: { (success) in
                    queue.leave()
                })
            }
        }
        
        WebAPI.shared.post(APIConst.photoGalleryPhotos,
                           parameter: keyList,
                           completion: { (responsePhoto: NewPhotoResponse) in
//                            DispatchQueue.main.async {
//                                self.collectionView.reloadData()
//                            }
        })
        
        queue.notify(queue: .main, execute: {
            WebAPI.shared.disableActivity = false
        })
        
    }
}

extension PhotosVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photoDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let spc = photos[section].count
        return (moreSections.contains(section) ? spc : (spc > showPhotoCount ? showPhotoCount : spc))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.setup(url:  photos[indexPath.section][indexPath.row].url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! PhotoHeaderView
            let date = DateManager("yyyy-MM-dd").date(string: photoDays[indexPath.section].day.date)!
            header.lblTitle.text = DateManager("MMMM dd, yyyy").string(date: date)
            return header
        } else
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! PhotoFooterView
                let more = photos[indexPath.section].count - showPhotoCount
                footer.btnMore.setTitle("\(more) more...", for: .normal)
                footer.btnMore.tag = indexPath.section
                footer.btnMore.addTarget(self, action: #selector(btnMore(_:)), for: .touchUpInside)
                
                if indexPath.section == photoDays.count - 1 {
                    footer.tag = 998
                }
                
                return footer
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            if view.viewWithTag(998) != nil {
                if page < pageCount {
                    page += 1
                    setup()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionFooter {
            if view.viewWithTag(998) != nil {
                view.tag = 0
            }
        }
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
        let w = (collectionView.bounds.width / 2) - 10
        return  CGSize(width: w, height: w / 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let width = collectionView.bounds.width
        return moreSections.contains(section) ? CGSize(width: width, height: 0.01) : (photos[section].count > showPhotoCount ? CGSize(width: width, height: 40) : CGSize(width: width, height: 0.01))
    }
}


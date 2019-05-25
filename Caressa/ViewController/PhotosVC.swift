//
//  PhotosVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 6.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit


class PhotosVC: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var btnDelete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(btnDelete(_:)))
    
    private var page: Int = 1
    private var pageCount: Int = 1
    private var nextPage: String?
    private var ivFacility: UIButton!
    private var photos = myPhotoGallery(dates: [])
    private var refreshControl = UIRefreshControl(frame: .zero)
    private var moreSections: [Int] = []
    private let showPhotoCount = 4
    private var willDeletePhotos: [IndexPath] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        refreshControl.addTarget(self, action: #selector(pull2Refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        ivFacility = WindowManager.setup(vc: self, title: "Photos")
        ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture, view: ivFacility)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(_:)))
        collectionView.addGestureRecognizer(longPress)
        
        setup(clear: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(pushControl), name: NSNotification.Name(rawValue: "pushControl"), object: nil)
        pushControl()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
    
    @IBAction func btnDelete(_ sender: UIBarButtonItem) {
        photoDelete()
    }
    
    @objc func longPressHandler(_ sender: UILongPressGestureRecognizer) {
        guard !collectionView.allowsMultipleSelection else { return }
        
        if sender.state == .began {
            collectionView.indexPathsForSelectedItems?.forEach { self.collectionView.deselectItem(at: $0, animated: false) }
            collectionView.allowsMultipleSelection = true
            
            let point = sender.location(in: collectionView)
            
            if let indexPath = collectionView.indexPathForItem(at: point) {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init())
                collectionView(collectionView, didSelectItemAt: indexPath)
            }
        }
    }
    
    func setup(clear cache: Bool) {
        let url_ = nextPage != nil ? nextPage : APIConst.photoGallery
        guard let url = url_ else { return }
        
        if cache {
            self.photos.dates = []
            self.clearMultiMode()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        let queue = DispatchGroup()
        queue.enter()
        WebAPI.shared.get(url) { (result: PhotoGallery) in
            
            self.pageCount = result.count / result.results.count
            self.nextPage = result.next
            
            self.photos.dates = result.results.map({myPhotos(date: $0.day.date, urls: [])})
            
            for p in result.results {
                queue.enter()
                WebAPI.shared.get(p.day.url, completion: { (day: PhotoDay) in
                    
                    if let dateIndex = self.photos.dates.firstIndex(where: {$0.date == p.day.date}) {
                        self.photos.dates[dateIndex].urls = day.results.map({$0})
                    }
                    queue.leave()
                })
            }
            queue.leave()
        }
        
        queue.notify(queue: .main) {
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func pushControl() {
        if let param = self.pushParameter {
            self.pushParameter = nil
            if let index = self.photos.dates.firstIndex(where: {$0.date == param}) {
                self.collectionView.scrollToItem(at: IndexPath(row: 0, section: index), at: .top, animated: true)
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
                    WebAPI.shared.post(APIConst.photoGalleryPhotos,
                                       parameter: keyList,
                                       completion: { (responsePhoto: [NewPhotoResponse]) in
                                        queue.leave()
                    })
                })
            }
        }
        
        queue.notify(queue: .main, execute: {
            WebAPI.shared.disableActivity = false
        })
        
    }
    
    @objc func pull2Refresh() {
        setup(clear: true)
    }
    
    func photoDelete() {
        WindowManager.showConfirmation(message: "Selected photos will be deleted. Do you want to continue?") {
            for indexPath in self.willDeletePhotos {
                let id = self.photos.dates[indexPath.section].urls[indexPath.row].id
                WebAPI.shared.delete(String(format: APIConst.photoDelete, id)) { (success) in
                    print("deleted")
                }
                self.photos.dates[indexPath.section].urls.removeAll(where: {$0.id == id})
            }
            self.collectionView.deleteItems(at: self.willDeletePhotos)
            self.clearMultiMode()
        }
    }
    
    func clearMultiMode() {
        self.collectionView.allowsMultipleSelection = false
        self.navigationItem.rightBarButtonItems?.removeAll(where: {$0 == self.btnDelete})
        self.willDeletePhotos.removeAll()
    }
}

extension PhotosVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photos.dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let spc = photos.dates[section].urls.count //photos[section].count
        return (moreSections.contains(section) ? spc : (spc > showPhotoCount ? showPhotoCount : spc))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCell
        cell.setup(url: photos.dates[indexPath.section].urls[indexPath.row].url)
        cell.isSelected = willDeletePhotos.contains(indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! PhotoHeaderView
            let date = DateManager("yyyy-MM-dd").date(string: photos.dates[indexPath.section].date)!
            header.lblTitle.text = DateManager("MMMM dd, yyyy").string(date: date)
            return header
        } else
            if kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! PhotoFooterView
                let more = photos.dates[indexPath.section].urls.count - showPhotoCount
                footer.btnMore.setTitle("\(more) more...", for: .normal)
                footer.btnMore.tag = indexPath.section
                footer.btnMore.addTarget(self, action: #selector(btnMore(_:)), for: .touchUpInside)
                
                if indexPath.section == photos.dates.count - 1 {
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
                    setup(clear: false)
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
        if collectionView.allowsMultipleSelection {
            willDeletePhotos.append(indexPath)
            if willDeletePhotos.count == 1 {
                navigationItem.rightBarButtonItems?.append(btnDelete)
            }
        } else {
            let images = photos.dates[indexPath.section].urls.map({$0.url})
            let imageSlider = ZoomableImageSlider(images: images, currentIndex: indexPath.row, placeHolderImage: nil)
            present(imageSlider, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.allowsMultipleSelection {
            willDeletePhotos.removeAll(where: {$0 == indexPath})
            if willDeletePhotos.isEmpty {
                self.clearMultiMode()
            }
        }
    }
}

extension PhotosVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.bounds.width / 2) - 10
        return  CGSize(width: w, height: w / 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let width = collectionView.bounds.width
        return moreSections.contains(section) ?
            CGSize(width: width, height: 0.01) :
            (photos.dates[section].urls.count > showPhotoCount ?
                CGSize(width: width, height: 40) :
                CGSize(width: width, height: 0.01))
    }
}


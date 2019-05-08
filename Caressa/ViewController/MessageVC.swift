//
//  MessageVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 24.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit
import CoreData

class MessageVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var page: Int = 1
//    private var pageCount: Int = 1
    private var nextPage: String?
    private var lastPage: Int = 0
    private var messages: [MessageResult] = []
    private var ivFacility: UIButton!
    //private var allResidentId: Int?
    private var refreshControl = UIRefreshControl(frame: .zero)
    
    private lazy var readMessages: [MessageRead] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "cell")
        ivFacility = WindowManager.setup(vc: self, title: "Messages")
        ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture, view: ivFacility)
        refreshControl.addTarget(self, action: #selector(setup), for: .valueChanged)
        tableView.refreshControl = refreshControl
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if AppDelegate.audioPlayer?.timeControlStatus == .playing {
            AppDelegate.audioPlayer?.pause()
            AppDelegate.audioPlayer = nil
        }
        
        readAll()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        WindowManager.repaintBarTitle(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        WindowManager.repaintBarTitle(vc: self)
        tableView.reloadData()
    }
    
    @objc private func setup() {
        var url_: String? = APIConst.messages + String(page)
        if page > 1 { url_ = nextPage }
        guard let url = url_ else { return }
        
        do {
            readMessages = try DBManager.shared.context.fetch(MessageRead.fetchRequest())
        } catch {
            print(error)
        }
        
        WebAPI.shared.get(url) { (response: MessageHeader) in //APIConst.messages + String(page)
            if var results = response.results {
                
                if self.lastPage < self.page {
                    do {
                        for (i,e) in results.enumerated() {
                            if !self.readMessages.contains(where: {$0.id == e.id}) {
                                if let newMessage = DBManager.shared.manageObject(entity: DBManager.shared.entity(entitiy: "MessageRead")!) as? MessageRead {
                                    newMessage.id = Int32(e.id)
                                    newMessage.read = true
                                    results[i].read = true
                                    try? DBManager.shared.context.save()
                                }
                            } else {
                                let fetchReq: NSFetchRequest<NSFetchRequestResult> = MessageRead.fetchRequest()
                                fetchReq.predicate = NSPredicate(format: "id = %d", e.id)
                                if let founded = try DBManager.shared.context.fetch(fetchReq).first as? MessageRead {
                                    founded.read = true
                                    results[i].read = true
                                    try? DBManager.shared.context.save()
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    self.messages += results
                }
                
//                self.allResidentId = results.first(where: {
//                    switch $0.resident {
//                    case .string?: return true
//                    default: return false
//                    }})?.id
            }
            self.lastPage = self.page
            self.nextPage = response.next
            //self.pageCount = (response.count ?? 1) / (response.results?.count ?? 1)
            
            DispatchQueue.main.async {
                let cnt = self.messages.filter({$0.read != true}).count
                self.tabBarItem.badgeValue = cnt > 0 ? "\(cnt)" : nil
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }

    func readAll() {
        do {
            let fetch = try DBManager.shared.context.fetch(MessageRead.fetchRequest())
            for (i,_) in fetch.enumerated() {
                let newMessage = fetch[i] as! MessageRead
                newMessage.read = true
                try DBManager.shared.context.save()
            }
        } catch {
            print(error)
        }
        DispatchQueue.main.async {
            let cnt = self.messages.filter({$0.read != true}).count
            self.tabBarItem.badgeValue = cnt > 0 ? "\(cnt)" : nil
        }
    }
}

extension MessageVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count + (nextPage != nil ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == messages.count {
            let cell = UITableViewCell()
            cell.contentView.tag = 998
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MessageCell
        cell.setup(message: messages[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.viewWithTag(998) != nil {
            if nextPage != nil {
                page += 1
                setup()
            }
        }
    }
    
    
}

extension MessageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        WindowManager.pushToMessageThreadVC(navController: self.navigationController, resident: messages[indexPath.row].resident)
        
        switch messages[indexPath.row].resident {
        case .residentClass(let x):
            if x.messageThreadURL.url != nil {
                WindowManager.pushToMessageThreadVC(navController: self.navigationController, resident: x)
            }
        case .allResidents(let x):
            WindowManager.pushToMessageThreadVC(navController: self.navigationController, resident: x)
        case .string: break
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let c = cell as? MessageCell {
            c.player?.stop()
        }
    }
}

extension MessageVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if nextPage != nil {
            page += 1
            setup()
        }
    }
    
    
}

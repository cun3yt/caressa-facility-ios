//
//  MessageThreadVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit
import CoreData

class MessageThreadVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noMessageView: UIView!
    
    private var messages: [MessageThreadResult] = []
    private var ivFacility: UIButton!
    private lazy var readMessages: [MessageThreadRead] = []
    private var refreshControl = UIRefreshControl(frame: .zero)
    private var emptyList: Bool = false

    public var resident: Resident?
    public var messageThreadUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MessageThreadCell", bundle: nil), forCellReuseIdentifier: "cell")
        refreshControl.addTarget(self, action: #selector(setup), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        if let resident = self.resident {
            self.ivFacility = WindowManager.setup(vc: self, title: "\(resident.firstName) \(resident.lastName)", deviceStatus: resident.deviceStatus?.status)
            ImageManager.shared.downloadImage(url: resident.profilePicture, view: self.ivFacility)
        } else {
            self.ivFacility = WindowManager.setup(vc: self, title: "All Residents")
            ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture, view: self.ivFacility)
        }
        
        PusherManager().delegate = self
        
        //setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if messageThreadUrl == nil {
            if let new = SessionManager.shared.residentsCache.first(where: {$0.id==resident?.id})?.messageThreadURL.url {
                messageThreadUrl = new
            }
        }
        
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if AppDelegate.audioPlayer?.timeControlStatus == .playing {
            AppDelegate.audioPlayer?.pause()
            AppDelegate.audioPlayer = nil
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        WindowManager.repaintBarTitle(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        WindowManager.repaintBarTitle(vc: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "newChat" {
            if let newVc = segue.destination as? NewMessageVC {
                newVc.to = resident
                newVc.fromMessageThread = true
            }
        }
    }
    
    @objc func setup() {
        title = nil
        
        guard let url = messageThreadUrl else {
            self.refreshControl.endRefreshing()
            self.emptyList = self.messages.isEmpty
            self.tableView.reloadData()
            return
        }
        
        do {
            readMessages = try DBManager.shared.context.fetch(MessageThreadRead.fetchRequest())
        } catch {
            print(error)
        }
        
        WebAPI.shared.get(url) { (response: MessageThread) in
            DispatchQueue.main.async {
                switch response.resident {
                case .residentClass(let x):
                    self.ivFacility = WindowManager.setup(vc: self, title: "\(x.firstName) \(x.lastName)", deviceStatus: x.deviceStatus?.status)
                    ImageManager.shared.downloadImage(url: x.profilePicture, view: self.ivFacility)
                case .allResidents:
                    self.ivFacility = WindowManager.setup(vc: self, title: "All Residents")
                    ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture, view: self.ivFacility)
                case .string(let x):
                    self.ivFacility = WindowManager.setup(vc: self, title: x)
                    ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture, view: self.ivFacility)
                }
            }
            
            WebAPI.shared.get(response.messages.url, completion: { (messages: MessageThreadHeader) in
                if var results = messages.results {
                    do {
                        for (i,e) in results.enumerated() {
                            if !self.readMessages.contains(where: {$0.id == e.id}) {
                                if let newMessage = DBManager.shared.manageObject(entity: DBManager.shared.entity(entitiy: "MessageThreadRead")!) as? MessageThreadRead {
                                    newMessage.id = Int32(e.id)
                                    newMessage.read = true
                                    results[i].read = true
                                    try DBManager.shared.context.save()
                                }
                            } else {
                                let fetchReq: NSFetchRequest<NSFetchRequestResult> = MessageThreadRead.fetchRequest()
                                fetchReq.predicate = NSPredicate(format: "id = %d", e.id)
                                if let founded = try DBManager.shared.context.fetch(fetchReq).first as? MessageThreadRead {
                                    founded.read = true
                                    results[i].read = true
                                    try DBManager.shared.context.save()
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    self.messages = results
                }
                self.emptyList = self.messages.isEmpty
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
            })
        }
    }
    
}

extension MessageThreadVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if emptyList {
            self.tableView.isHidden = self.messages.count == 0
            self.noMessageView.isHidden = !tableView.isHidden
        }
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MessageThreadCell
        cell.setup(message: messages[indexPath.row])
        return cell
    }
    
}

extension MessageThreadVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let c = cell as? MessageThreadCell {
            c.player?.stop()
        }
    }
}

extension MessageThreadVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
}

extension MessageThreadVC: PusherManagerDelegate {
    func subscribed(deviceStatus: DeviceStatusEvent) {
        if let new = deviceStatus.value.new {
            resident?.deviceStatus?.status.isOnline = new
            WindowManager.repaintBarTitle(vc: self, deviceStatus: resident?.deviceStatus?.status)
        }
    }
    
    func subscribed(checkIn: CheckInEvent) { }
}

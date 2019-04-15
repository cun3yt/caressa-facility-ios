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
    private var pageCount: Int = 1
    private var messages: [MessageResult] = []
    private var ivFacility: UIButton!
    
    private lazy var readMessages: [MessageRead] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "cell")
        ivFacility = WindowManager.setup(vc: self, title: "Messages")
        ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture, view: ivFacility)
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
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
        DispatchQueue.main.async {
            self.navigationItem.titleView?.frame.size.width = self.view.frame.width - 30
        }
    }
    
    private func setup() {
        do {
            readMessages = try DBManager.shared.context.fetch(MessageRead.fetchRequest())
        } catch {
            print(error)
        }
        
        WebAPI.shared.get(APIConst.messages + String(page)) { (response: MessageHeader) in
            if var results = response.results {
                
                do {
                    for (i,e) in results.enumerated() {
                        if !self.readMessages.contains(where: {$0.id == e.id}) {
                            if let newMessage = DBManager.shared.manageObject(entity: DBManager.shared.entity(entitiy: "MessageRead")!) as? MessageRead {
                                newMessage.id = Int32(e.id)
                                newMessage.read = false
                                results[i].read = false
                                try DBManager.shared.context.save()
                            }
                        } else {
                            let fetchReq: NSFetchRequest<NSFetchRequestResult> = MessageRead.fetchRequest()
                            fetchReq.predicate = NSPredicate(format: "id = %d", e.id)
                            if let founded = try DBManager.shared.context.fetch(fetchReq).first as? MessageRead {
                                founded.read = true
                                results[i].read = true
                                try DBManager.shared.context.save()
                            }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                
                self.messages += results
            }
            self.pageCount = (response.count ?? 1) / (response.results?.count ?? 1)
            
            DispatchQueue.main.async {
                let cnt = self.messages.filter({$0.read != true}).count
                self.tabBarItem.badgeValue = cnt > 0 ? "\(cnt)" : nil
                self.tableView.reloadData()
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
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MessageCell
        cell.setup(message: messages[indexPath.row])
        return cell
    }
}

extension MessageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch messages[indexPath.row].resident {
        case .residentClass(let x)? :
            WindowManager.pushToMessageThreadVC(navController: self.navigationController, resident: x)
        case .string?: break
        case .none: break
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
        if page < pageCount {
            page += 1
            setup()
        }
    }
    
    
}



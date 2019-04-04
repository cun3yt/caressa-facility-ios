//
//  MessageThreadVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class MessageThreadVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var messages: [MessageResult] = []
    private var ivFacility: UIButton!
    
    public var resident: Resident!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MessageThreadCell", bundle: nil), forCellReuseIdentifier: "cell")
        ivFacility = WindowManager.setup(vc: self, title: "", deviceStatus: resident.deviceStatus)
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if AppDelegate.audioPlayer?.timeControlStatus == .playing {
            AppDelegate.audioPlayer?.pause()
            AppDelegate.audioPlayer = nil
        }
    }
    
    func setup() {
        title = nil
        WebAPI.shared.get(APIConst.messageThreads.replacingOccurrences(of: "#rID#", with: "1")) { (response: MessageThread) in
            DispatchQueue.main.async {
                self.ivFacility = WindowManager.setup(vc: self, title: "\(response.resident.firstName) \(response.resident.lastName)", deviceStatus: response.resident.deviceStatus)
                ImageManager.shared.downloadImage(url: response.resident.profilePicture, view: self.ivFacility)
            }
            
            WebAPI.shared.get(APIConst.messageThreadsMessage.replacingOccurrences(of: "#rID#", with: "1"), completion: { (messages: MessageHeader) in
                
                if let results = messages.results {
                    self.messages = results
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }

}

extension MessageThreadVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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


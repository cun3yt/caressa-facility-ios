//
//  MessageVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 24.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class MessageVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var page: Int = 1
    private var pageCount: Int = 1
    private var messages: [MessageResult] = []
    private var ivFacility: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "cell")
        ivFacility = WindowManager.setup(vc: self, title: "Messages")
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if AppDelegate.audioPlayer?.timeControlStatus == .playing {
            AppDelegate.audioPlayer?.pause()
            AppDelegate.audioPlayer = nil
        }
    }
    
    private func setup() {
        WebAPI.shared.get(APIConst.messages + String(page)) { (response: MessageHeader) in
            if let results = response.results {
                self.messages += results
            }
            self.pageCount = (response.count ?? 1) / (response.results?.count ?? 1)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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



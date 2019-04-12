//
//  ResidentVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 23.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class ResidentVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var residents: [Resident] = []
    private var ivFacility: UIButton!
    
    private var pusher = PusherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResidentCell", bundle: nil), forCellReuseIdentifier: "SeniorCell")
        self.tabBarController?.tabBar.unselectedItemTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        ivFacility = WindowManager.setup(vc: self, title: "Residents")
        
        setup()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            self.navigationItem.titleView?.frame.size.width = self.view.frame.width - 30
        }
    }
    
    func setup() {
        
        
        WebAPI.shared.get(APIConst.facility) { (response: FacilityResponse) in
            SessionManager.shared.facility = response

            DispatchQueue.main.async {
                ImageManager.shared.downloadImage(url: response.profilePicture, view: self.ivFacility)
                self.tabBarController?.viewControllers?[1].tabBarItem.badgeValue = String(response.numberOfUnreadNotifications)
            }
        }
        
        WebAPI.shared.get(APIConst.residents) { (response: [Resident]) in
            self.residents = response
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ResidentVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return residents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeniorCell") as! ResidentCell
        cell.setup(resident: residents[indexPath.row])
        cell.navigationController = self.navigationController
        return cell
    }
}

extension ResidentVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        WindowManager.pushToProfileVC(navController: self.navigationController!, resident: residents[indexPath.row])
    }
}

//
//  ResidentVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 23.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class ResidentVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonMorningStatus: UIBarButtonItem!
    
    private var residents: [Resident] = []
    private var ivFacility: UIButton!
    private var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    //private var pusher = PusherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResidentCell", bundle: nil), forCellReuseIdentifier: "SeniorCell")
        self.tabBarController?.tabBar.unselectedItemTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        ivFacility = WindowManager.setup(vc: self, title: "Residents")
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(pushControl), name: NSNotification.Name(rawValue: "pushControl"), object: nil)
        pushControl()
        
        checkChangeProfilePage()
        if SessionManager.shared.refreshRequired {
            refreshResidentList()
        }
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
    
    func setup() {
        buttonMorningStatus.isEnabled = false
        buttonMorningStatus.tintColor = .clear
        WebAPI.shared.get(APIConst.facility) { (response: FacilityResponse) in
            SessionManager.shared.facility = response

            DispatchQueue.main.async {
                self.appDelegate.checkinChannel = self.appDelegate.pusher.subscribe(response.realTimeCommunicationChannels.checkIn.channel)
                self.appDelegate.deviceStatusChannel = self.appDelegate.pusher.subscribe(response.realTimeCommunicationChannels.deviceStatus.channel)
                
                PusherManager().delegate = self
                
                self.buttonMorningStatus.isEnabled = response.featureFlags.morningCheckIn
                self.buttonMorningStatus.tintColor = self.buttonMorningStatus.isEnabled ? .white : .clear
                
                ImageManager.shared.downloadImage(url: response.profilePicture, view: self.ivFacility)

                let cnt = DBManager.shared.getUnreadMessageCount()
                self.tabBarController?.viewControllers?[1].tabBarItem.badgeValue = cnt > 0 ? "\(cnt)" : nil
            }
        }
        
        WebAPI.shared.get(APIConst.userMe) { (response: UserMe) in
            SessionManager.shared.activeUser = response
        }
        
        refreshResidentList()
    }
    
    func refreshResidentList() {
        WebAPI.shared.get(APIConst.residents) { (response: [Resident]) in
            self.residents = response
            SessionManager.shared.residentsCache = response
            SessionManager.shared.refreshRequired = false
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func checkChangeProfilePage() {
        if let tempImage = SessionManager.shared.temporaryProfile,
            let inx = residents.firstIndex(where: {$0.id == tempImage.id}),
            let cell = tableView.cellForRow(at: IndexPath(row: inx, section: 0)) as? ResidentCell {
            cell.ivThumb.image = tempImage.image
        }
    }
    
    @objc func pushControl() {
        if let param = pushParameter {
            pushParameter = nil
            if param == "morning_status" {
                performSegue(withIdentifier: "morningStatusSegue", sender: nil)
            } else {
                if let res = SessionManager.shared.residentsCache.first(where: {String($0.id) == param}) {
                    WindowManager.pushToProfileVC(navController: self.navigationController!, resident: res)
                }
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

extension ResidentVC: PusherManagerDelegate {
    func subscribed(deviceStatus: DeviceStatusEvent) {
        if let index = residents.firstIndex(where: {$0.id == deviceStatus.user_id}) {
            if let new = deviceStatus.value.new {
                residents[index].deviceStatus?.status.isOnline = new
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
    func subscribed(checkIn: CheckInEvent) { }
}

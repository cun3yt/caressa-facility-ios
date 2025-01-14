//
//  MorningStatusVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 27.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class MorningStatusVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var unMorningStatus: UIView!
    
    private var morningChecks: MorningCheckInResponse!
    private var ivImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResidentCell", bundle: nil), forCellReuseIdentifier: "cell")
        ivImage = WindowManager.setup(vc: self, title: "Morning Status")
        ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture, view: ivImage)
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
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    func setup() {
        
        if (UIApplication.shared.delegate as! AppDelegate).serverTimeState?.status == "morning-status-not-available" {
            tableView.isHidden = true
            return
        }
        
        WebAPI.shared.get(APIConst.morningCheckIn) { (response: MorningCheckInResponse) in
            self.morningChecks = response
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension MorningStatusVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return morningChecks == nil ? 0 : 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return morningChecks.notified.residents.count
        case 1: return morningChecks.pending.residents.count
        case 2: return morningChecks.selfChecked.residents.count
        case 3: return morningChecks.staffChecked.residents.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ResidentCell
        var resident: Resident!
        switch indexPath.section {
        case 0: resident = morningChecks.notified.residents[indexPath.row]
        case 1: resident = morningChecks.pending.residents[indexPath.row]
        case 2: resident = morningChecks.selfChecked.residents[indexPath.row]
        case 3: resident = morningChecks.staffChecked.residents[indexPath.row]
        default: break
        }
        cell.setup(resident: resident)
        cell.navigationController = self.navigationController
        cell.delegate = self
        cell.lblDetail.text = nil
        if let ci = resident.checkIn, let by = ci.checkedBy, let tm = ci.checkInTime {
            cell.lblDetail.text = "By: \(by) @ \(DateManager("hh:mm a").string(date: tm))"
            cell.lblDetail.isHidden = false
            if by.contains("Staff") {
                cell.lblDetail.textColor = #colorLiteral(red: 0.3725490196, green: 0.7803921569, blue: 0.3411764706, alpha: 1)
            }
        }
        if indexPath.section == 0 {
            cell.lblName.textColor = .red
            cell.lblRoom.textColor = .red
        }
        return cell
    }
    
}

extension MorningStatusVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 17)
        switch section {
        case 0:
            label.text = morningChecks.notified.label
            view.backgroundColor = .red
        case 1:
            label.text = morningChecks.pending.label
            view.backgroundColor = #colorLiteral(red: 0.8005672089, green: 0.7860765286, blue: 0.543114721, alpha: 1)
        case 2:
            label.text = "Checked" //morningChecks.selfChecked.label
            view.backgroundColor = #colorLiteral(red: 0.3725490196, green: 0.7803921569, blue: 0.3411764706, alpha: 1)
        //case 3:
        //    label.text = morningChecks.staffChecked.label
        //    view.backgroundColor = #colorLiteral(red: 0.3725490196, green: 0.7803921569, blue: 0.3411764706, alpha: 1)
        default: break
        }
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 8))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -8))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 21))

        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var resident: Resident!
        switch indexPath.section {
        case 0: resident = morningChecks.notified.residents[indexPath.row]
        case 1: resident = morningChecks.pending.residents[indexPath.row]
        case 2: resident = morningChecks.selfChecked.residents[indexPath.row]
        case 3: resident = morningChecks.staffChecked.residents[indexPath.row]
        default: break
        }
        WindowManager.pushToProfileVC(navController: self.navigationController!, resident: resident)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 3 ? 0 : 28
    }
    
    func changedStatus(checked: Bool, resident: Resident) {
        if checked {
            if let i = morningChecks.staffChecked.residents.firstIndex(where: {$0.id==resident.id}) {
                let removed = morningChecks.staffChecked.residents.remove(at: i)
                removed.checkIn = CheckInURL(url: removed.checkIn?.url ?? "", checkedBy: nil, checkInTime: nil)
                morningChecks.pending.residents.append(removed)
            }
        } else {
            if let i = morningChecks.pending.residents.firstIndex(where: {$0.id==resident.id}) {
                let removed = morningChecks.pending.residents.remove(at: i)
                let name = (SessionManager.shared.activeUser?.firstName ?? "") + (SessionManager.shared.activeUser?.lastName ?? "")
                removed.checkIn = CheckInURL(url: removed.checkIn?.url ?? "", checkedBy: "Staff \(name)", checkInTime: Date())
                morningChecks.staffChecked.residents.append(removed)
            }
        }
        self.tableView.reloadSections(IndexSet(arrayLiteral: 1,3), with: .automatic)
    }
}

extension MorningStatusVC: ResidentCellDelegate {
    func touchCheckButon(_ isSelected: Bool, resident: Resident) {
        guard let url = resident.checkIn?.url else { return }
        let req = MorningCheckInRequest()
        WebAPI.shared.disableActivity = true
        if isSelected {
            WebAPI.shared.post(url, parameter: req) { (response: MorningCheckToday) in
                WebAPI.shared.disableActivity = false
                if !response.success {
                    WindowManager.showMessage(type: .error, message: "Failed")
                    return
                }
            }
        } else {
            WebAPI.shared.delete(url) { (success) in
                WebAPI.shared.disableActivity = false
                if !success {
                    WindowManager.showMessage(type: .error, message: "Failed")
                    return
                }
            }
        }
        changedStatus(checked: !isSelected, resident: resident)
    }
    
    
}

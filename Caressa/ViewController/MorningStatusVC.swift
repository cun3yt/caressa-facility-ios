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
        return morningChecks == nil ? 0 : 4 //residents.count
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
            label.text = morningChecks.selfChecked.label
            view.backgroundColor = #colorLiteral(red: 0.3725490196, green: 0.7803921569, blue: 0.3411764706, alpha: 1)
        case 3:
            label.text = morningChecks.staffChecked.label
            view.backgroundColor = #colorLiteral(red: 0.3725490196, green: 0.7803921569, blue: 0.3411764706, alpha: 1)
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
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        switch indexPath.section {
//        case 2: return 75
//        default: return 68
//        }
//    }
    
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
}

extension MorningStatusVC: ResidentCellDelegate {
    func touchCheckButon(_ isSelected: Bool, resident: Resident) {
        guard let url = resident.checkIn?.url else { return }
        let req = MorningCheckInRequest()
        if isSelected {
            WebAPI.shared.post(url, parameter: req) { (response: MorningCheckToday) in
                if !response.success {
                    WindowManager.showMessage(type: .error, message: "Failed")
                    return
                }
                self.setup()
            }
        } else {
            WebAPI.shared.delete(url) { (success) in
                if !success {
                    WindowManager.showMessage(type: .error, message: "Failed")
                    return
                }
                self.setup()
            }
        }
        
    }
    
    
}

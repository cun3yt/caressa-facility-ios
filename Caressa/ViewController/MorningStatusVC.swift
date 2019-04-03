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
    
    private var residents: [[Resident]] = []
    private var ivImage: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResidentCell", bundle: nil), forCellReuseIdentifier: "cell")
        ivImage = WindowManager.setup(vc: self, title: "Morning Status")
        navigationItem.leftItemsSupplementBackButton = false
        setup()
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    func setup() {
        WebAPI.shared.get("\(APIConst.residents)?status=notified") { (response: [Resident]) in
            self.residents.insert(response, at: 0)
            
            WebAPI.shared.get("\(APIConst.residents)?status=pending") { (response: [Resident]) in
                self.residents.insert(response, at: 1)
                 WebAPI.shared.get("\(APIConst.residents)?status=staff-checked") { (response: [Resident]) in
                    self.residents.insert(response, at: 2)
                    
                    WebAPI.shared.get("\(APIConst.residents)?status=self-checked") { (response: [Resident]) in
                        self.residents[2] += response
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension MorningStatusVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return residents.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return residents[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ResidentCell
        let resident = residents[indexPath.section][indexPath.row]
        cell.setup(resident: resident)
        cell.delegate = self
        if let ci = resident.checkInInfo, let by = ci.checkedBy, let tm = ci.checkInTime {
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
        let label = UILabel(frame: CGRect(x: 0, y: 3, width: 200, height: 21))
        label.frame.origin.x = (UIScreen.main.bounds.width / 2) - 100
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 17)
        switch section {
        case 0:
            label.text = "Notified"
            view.backgroundColor = .red
        case 1:
            label.text = "Pending"
            view.backgroundColor = #colorLiteral(red: 0.8005672089, green: 0.7860765286, blue: 0.543114721, alpha: 1)
        default:
            label.text = "Checked"
            view.backgroundColor = #colorLiteral(red: 0.3725490196, green: 0.7803921569, blue: 0.3411764706, alpha: 1)
        }
        
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2: return 75
        default: return 68
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        WindowManager.pushToProfileVC(navController: self.navigationController!, resident: residents[indexPath.section][indexPath.row])
    }
}

extension MorningStatusVC: ResidentCellDelegate {
    func touchCheckButon(_ isSelected: Bool) {
        if isSelected {
            print("selected")
        } else {
            print("not selected")
        }
    }
    
    
}

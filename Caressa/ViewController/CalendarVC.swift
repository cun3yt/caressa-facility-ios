//
//  CalendarVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 30.03.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class CalendarVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var ivFacility: UIButton!
    private var dateList: [Date] = []
    private var calendar: [String] = ["Poker","Pizza","Boook"]
    private var btnToday: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: "cell")
        ivFacility = WindowManager.setup(vc: self, title: "Calendar")
        ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture, view: ivFacility)
        
        btnToday = UIButton(type: .custom)
        btnToday.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btnToday.setTitle("Today", for: .normal)
        btnToday.layer.borderWidth = 1
        btnToday.layer.cornerRadius = 5
        btnToday.layer.borderColor = UIColor.white.cgColor
        btnToday.addTarget(self, action: #selector(todayAction), for: .touchUpInside)
        btnToday.frame.size.width = 60
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnToday)
        
        setup()
    }
    
    @IBAction func todayAction() {
        guard let week = DateManager.dayOfWeek(today: Date()) else { return }
        tableView.scrollToRow(at: IndexPath(row: 0, section: week - 2), at: .top, animated: true)
    }
    
    func setup() {
        dateList = DateManager.dates(from: DateManager.startOfWeek()!, to: DateManager.endOfWeek()!)
        
        
//        WebAPI.shared.get(APIConst.calendar) { (response: Calendar) in
//
//        }
    }
    
}

extension CalendarVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dateList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CalendarCell
        cell.setup(date: dateList[indexPath.section], item: calendar[indexPath.row])
        return cell
    }
}

extension CalendarVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: .zero)
        label.backgroundColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "    " + DateManager("EEEE, MMMM dd, yyyy").string(date: dateList[section])
        
        if DateManager.onlyDate(date: dateList[section]) == DateManager.onlyDate(date: Date()) {
            label.textColor = .red
        }
        return label
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let splitter = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 24))
        splitter.backgroundColor = .white
        let line = UIView(frame: CGRect(x: 16, y: 12, width: UIScreen.main.bounds.width - 32, height: 2))
        line.backgroundColor = .lightGray
        splitter.addSubview(line)
        return splitter
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
}

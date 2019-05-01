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
    private var calendar: [CalendarModel] = []
    private var btnToday: UIButton!
    private var refreshControl = UIRefreshControl(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: "cell")
        ivFacility = WindowManager.setup(vc: self, title: "Calendar")
        ImageManager.shared.downloadImage(url: SessionManager.shared.facility?.profilePicture, view: ivFacility)
        
        refreshControl.addTarget(self, action: #selector(cacheControl), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cacheControl()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        WindowManager.repaintBarTitle(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        WindowManager.repaintBarTitle(vc: self)
    }
    
    @IBAction func todayAction() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 7), at: .top, animated: true)
    }
    
    func setup() {
        WebAPI.shared.get(String(format: APIConst.calendar, DateManager("yyyy-MM-dd").string(date: DateManager().now()))) { (response: [CalendarModel]) in
            self.calendar = response
            SessionManager.shared.calendarSyncTime = Date()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.todayAction()
            }
        }
    }
    
    @objc func cacheControl() {
        if let syncTime = SessionManager.shared.calendarSyncTime {
            let diff = Date().timeIntervalSince(syncTime) / 60
            if diff > 60 {
                setup()
                return
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
}

extension CalendarVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return calendar.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendar[section].events.hourlyEvents.hourlyEventsSet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CalendarCell
        cell.setup(set: calendar[indexPath.section].events.hourlyEvents.hourlyEventsSet[indexPath.row])
        return cell
    }
}

extension CalendarVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: .zero)
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        label.text = "    " + calendar[section].date
        
        let date = DateManager("EEEE, MMMM dd, yyyy", useUTC: true).date(string: calendar[section].date)!
        if DateManager(useUTC: true).onlyDate(date: date) == DateManager(useUTC: true).onlyDate(date: DateManager().now()) {
            label.textColor = .red
        } else 
            if date < Date() {
                label.textColor = .lightGray
            } else {
                label.textColor = .black
        }
        return label
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView(frame: .zero)
        let splitter = UIView(frame: .zero)
        
        headerView.backgroundColor = .white
        splitter.backgroundColor = .lightGray
        headerView.addSubview(splitter)
        
        splitter.translatesAutoresizingMaskIntoConstraints = false
        headerView.addConstraint(NSLayoutConstraint(item: splitter, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1.0, constant: 8))
        headerView.addConstraint(NSLayoutConstraint(item: splitter, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1.0, constant: -8))
        headerView.addConstraint(NSLayoutConstraint(item: splitter, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1.0, constant: 0))
        headerView.addConstraint(NSLayoutConstraint(item: splitter, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 2))

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
}

//
//  SearchVC.swift
//  Caressa
//
//  Created by Hüseyin Metin on 4.04.2019.
//  Copyright © 2019 Hüseyin Metin. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    private var residents: [Resident] = []
    private var filteredResidents: [Resident] = []
    
    public var delegate: NewMessageVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResidentCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        
        setup()
    }
    
    func setup() {
        WebAPI.shared.get(APIConst.residents) { (response: [Resident]) in
            self.residents = response
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func search(searchText: String) {
        guard searchText.count >= 1 else {
            filteredResidents.removeAll()
            tableView.reloadData()
            return
        }
        
        filteredResidents = residents.filter({ (r) -> Bool in
            return r.firstName.lowercased().contains(searchText.lowercased()) ||
            r.lastName.lowercased().contains(searchText.lowercased()) ||
            r.roomNo.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText: searchText)
    }
}

extension SearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let retrn = filteredResidents.isEmpty ? residents.count : filteredResidents.count
        if retrn == 0 {
            let noresult = UILabel(frame: .zero)
            noresult.text = "No result found"
            tableView.backgroundView = noresult
        } else {
            tableView.backgroundView = nil
        }
        return retrn
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ResidentCell
        cell.setup(resident: filteredResidents.isEmpty ? residents[indexPath.row] : filteredResidents[indexPath.row] )
        return cell
    }
}

extension SearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectResident(resident: filteredResidents.isEmpty ? residents[indexPath.row] : filteredResidents[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}

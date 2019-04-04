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
    
    public var delegate: NewMessageVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ResidentCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
    }
    
    func search(searchText: String) {
        guard searchText.count >= 1 else { return }
        
        WebAPI.shared.get(String(format: APIConst.residentsAutoComplete, searchText)) { (response: [Resident]) in
            self.residents = response
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText: searchText)
    }
}

extension SearchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return residents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ResidentCell
        cell.setup(resident: residents[indexPath.row])
        return cell
    }
}

extension SearchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectResident(resident: residents[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}

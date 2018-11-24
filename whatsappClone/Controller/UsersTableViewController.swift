//
//  UsersTableViewController.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 23/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class UsersTableViewController: UITableViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    var allUsers: [FUser] = [] {
        didSet {
            print("all users: \(allUsers)")
        }
    }
    var filteredUsers: [FUser] = [] {
        didSet {
            print("filtered users: \(filteredUsers)")
        }
    }
    var allUsersGrouped = [String : [FUser]]()
    var sectionTitleList = [String]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        loadUsers(filter: kCITY)
        setupTableView()
    }
    
    func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }

    func loadUsers(filter: String) {
        
        ProgressHUD.show()
        
        var query: Query!
        
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapshot, error) in
            
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGrouped = [:]
            
            if let error = error {
                print(error.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            
            guard let documents = snapshot?.documents else {
                ProgressHUD.dismiss()
                return }
            
            for document in documents {
                let userDictionary = document.data() as NSDictionary
                let fUser = FUser(_dictionary: userDictionary)
                if fUser.objectId != FUser.currentId() {
                    self.allUsers.append(fUser)
                }
            }
            
            self.splitDataIntoSections()
            self.tableView.reloadData()
        }
        
        self.tableView.reloadData()
        ProgressHUD.dismiss()
    }

    func setupTableView() {
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: kCITY)
        case 1:
            loadUsers(filter: kCOUNTRY)
        case 2:
            loadUsers(filter: "")
        default: break
        }
    }
    
    func searchIsActive() -> Bool {
        return searchController.isActive && searchController.searchBar.text != ""
    }
    
    func splitDataIntoSections() {
        
        var sectionTitle = String()
        
        for i in 0..<self.allUsers.count {
            let currentUser = self.allUsers[i]
            let firstChar = currentUser.firstname.first!
            let firstCharString = "\(firstChar)"
            if firstCharString != sectionTitle {
                sectionTitle = firstCharString
                self.allUsersGrouped[sectionTitle] = []
                self.sectionTitleList.append(sectionTitle)
            }
            self.allUsersGrouped[firstCharString]?.append(currentUser)
        }
    }
}

extension UsersTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUsers = allUsers.filter({ (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

extension UsersTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return searchIsActive() ? 1 : allUsersGrouped.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchIsActive() {
            return filteredUsers.count
        } else {
            let sectionTitle = sectionTitleList[section]
            let users = self.allUsersGrouped[sectionTitle]
            return users!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserTableViewCell
        
        var user: FUser
        
        if searchIsActive() {
            let searchUser = filteredUsers[indexPath.row]
            user = searchUser
        } else {
            let sectionTitle = self.sectionTitleList[indexPath.section]
            user = self.allUsersGrouped[sectionTitle]![indexPath.item]
        }
        
        cell.generateCellWith(fUser: user, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchIsActive() ? "" : sectionTitleList[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return searchIsActive() ? nil : self.sectionTitleList
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user: FUser
        
        if searchIsActive() {
            user = filteredUsers[indexPath.item]
        } else {
            let sectionTitle = self.sectionTitleList[indexPath.section]
            user = self.allUsersGrouped[sectionTitle]![indexPath.item]
        }
        
        let profileViewTableViewController = StoryboardHelper.VC.profileView.viewController as! ProfileViewTableViewController
        profileViewTableViewController.user = user
        self.navigationController?.pushViewController(profileViewTableViewController, animated: true)
    }
    
}


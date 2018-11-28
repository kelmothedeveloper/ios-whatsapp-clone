//
//  ChatsViewController.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 24/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit
import FirebaseFirestore
import SnapKit

class ChatsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recentChats = [NSDictionary]()
    var filteredChats = [NSDictionary]()
    
    var recentListener: ListenerRegistration?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadRecentChats()
        setupTableViewHeader()
        setupNavigation()
    }
    
    func setupNavigation() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecentChats()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recentListener?.remove()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupTableViewHeader() {
        
        let headerView = UIView()
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.groupTableViewBackground
        
        let button = UIButton(type: .custom)
        button.setTitle("New Group", for: .normal)
        let buttonColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        button.setTitleColor(buttonColor, for: .normal)
        
        button.addTarget(self, action: #selector(groupButtonTapped(_:)), for: .touchUpInside)
        
        headerView.addSubview(button)
        headerView.addSubview(lineView)
        
        headerView.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.width.equalTo(UIScreen.main.bounds.size.width)
        }
        
        button.snp.makeConstraints { (make) in
            make.height.equalTo(24)
            make.trailing.equalTo(headerView.snp.trailing).offset(-8)
            make.centerY.equalTo(headerView.snp.centerY)
            make.width.equalTo(120)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.leading.equalTo(headerView.snp.leading)
            make.trailing.equalTo(headerView.snp.trailing)
            make.bottom.equalTo(headerView.snp.bottom)
        }
        
        tableView.tableHeaderView = headerView
        
    }
    
    @objc func groupButtonTapped(_ button: UIButton) {
    
    }
    
    @IBAction func newChatButtonPressed(_ sender: UIBarButtonItem) {
        let usersViewController = StoryboardHelper.VC.users.viewController
        self.navigationController?.pushViewController(usersViewController, animated: true)
    }
    
    func loadRecentChats() {
        
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            self.recentChats = []
            if !snapshot.isEmpty {
                let dictionary = NSArray(array: dictionaryFromSnapshots(snapshots: snapshot.documents))
                let description = NSSortDescriptor(key: kDATE, ascending: false)
                let sorted = dictionary.sortedArray(using: [description]) as? [NSDictionary]
                for recent in sorted! {
                    if let lastMessage = recent[kLASTMESSAGE] as? String,
                        lastMessage != "",
                        recent[kCHATROOMID] != nil,
                        recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
    
    func searchIsActive() -> Bool {
        return searchController.isActive && searchController.searchBar.text != ""
    }
    
    func deleteRecentChat(recentChat: NSDictionary) {
        if let recentId = recentChat[kRECENTID] as? String {
            reference(.Recent).document(recentId).delete { (error) in
                self.tableView.reloadData()
            }
        }
    }
    
    func restartRecentChat(recent: NSDictionary) {
        
        if let type = recent[kTYPE] as? String, type == kPRIVATE {
            createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserName: FUser.currentUser()!.firstname, type: type, users: [FUser.currentUser()!], avatarOfGroup: nil)
        }
        
        if recent[kTYPE] as! String == kGROUP {
            createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserName: recent[kWITHUSERUSERNAME] as! String, type: kGROUP, users: [FUser.currentUser()!], avatarOfGroup: recent[kAVATAR] as? String)
        }
    }
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchIsActive() {
            return filteredChats.count
        } else {
            return recentChats.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RecentChatTableViewCell
        let recent: NSDictionary!
        if searchIsActive() {
            recent = filteredChats[indexPath.item]
        } else {
            recent = recentChats[indexPath.item]
        }
        cell.delegate = self
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var tempRecent: NSDictionary!
        
        if searchIsActive() {
            tempRecent = filteredChats[indexPath.item]
        } else {
            tempRecent = recentChats[indexPath.item]
        }
        
        var muteTitle = "Unmute"
        var isMute = false
        
        if (tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            muteTitle = "Mute"
            isMute = true
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            self.recentChats.remove(at: indexPath.row)
            self.deleteRecentChat(recentChat: tempRecent)
            
        }
        
        let muteAction = UITableViewRowAction(style: .default, title: "Mute") { (action, indexPath) in
            print("mute")
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        muteAction.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        
        return [deleteAction, muteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var recent: NSDictionary!
        
        if searchIsActive() {
            recent = filteredChats[indexPath.item]
        } else {
            recent = recentChats[indexPath.item]
        }
        
        restartRecentChat(recent: recent)
        let chatVC = ChatViewController()
        chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as! [String])
        chatVC.memberIds = (recent[kMEMBERS] as! [String])
        chatVC.chatRoomId = (recent[kCHATROOMID] as! String)
        chatVC.titleName = (recent[kWITHUSERFULLNAME] as! String)
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
}

extension ChatsViewController: RecentChatsTableViewCellDelegate {
    
    func didTapAvatarImage(indexPath: IndexPath) {
        
        var recentChat: NSDictionary!
        
        if searchIsActive() {
            recentChat = filteredChats[indexPath.item]
        } else {
            recentChat = recentChats[indexPath.item]
        }
        
        if let type = recentChat[kTYPE] as? String, type == kPRIVATE {
            let documentPath = recentChat[kWITHUSERUSERID] as! String
            reference(.User).document(documentPath).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else { return }
                if snapshot.exists {
                    let userDictionary = snapshot.data()!
                    let user = FUser(userDictionary)
                    self.showUserProfile(user: user)
                }
            }
        }
    }
    
    func showUserProfile(user: FUser) {
        let profileVC = StoryboardHelper.VC.profileView.viewController as! ProfileViewTableViewController
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
}

extension ChatsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredChats = recentChats.filter({ (recentChat) -> Bool in
            return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadRecentChats()
        setupTableViewHeader()
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
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RecentChatTableViewCell
        let recent = recentChats[indexPath.item]
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        return cell
    }
    
}

extension ChatsViewController: RecentChatsTableViewCellDelegate {
    
    func didTapAvatarImage(indexPath: IndexPath) {
        
        let recentChat = recentChats[indexPath.item]
        
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

//
//  Recent.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 26/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import Foundation

func startPrivateChat(user1: FUser, user2: FUser) -> String {
    
    let userId1 = user1.objectId
    let userId2 = user2.objectId
    
    var chatRoomId = String()
    
    let value = userId1.compare(userId2).rawValue
    
    if value < 0 {
        chatRoomId = userId1 + userId2
    } else {
        chatRoomId = userId2 + userId1
    }
    
    let members = [userId1, userId2]
    let users = [user1, user2]
    
    // Create recent chat
    createRecent(members: members, chatRoomId: chatRoomId, withUserName: "", type: kPRIVATE, users: users, avatarOfGroup: nil)
    
    return chatRoomId
    
}

func createRecent(members: [String], chatRoomId: String, withUserName userName: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    
    var tempMembers = members
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            for recent in snapshot.documents {
                
                let currentRecent = recent.data() as NSDictionary
                
                if let currentUserId = currentRecent[kUSERID] as? String {
                    
                    if tempMembers.contains(currentUserId) {
                     
                        let index = tempMembers.firstIndex(of: currentUserId)!
                        tempMembers.remove(at: index)
                        
                        
                        
                    }
                }
                
            }
        }
        
        
        for userId in tempMembers {
            
            createRecentItem(userId: userId, chatRoomId: chatRoomId, members: members, withUserName: userName, type: type, users: users, avatarOfGroup: avatarOfGroup)
            
            
            
            
        }
        
        
        
    }
    
    
    
}


func createRecentItem(userId: String, chatRoomId: String, members: [String], withUserName: String, type: String, users: [FUser]?, avatarOfGroup: String?) {
    
    let localReference = reference(.Recent).document()
    
    let recentId = localReference.documentID
    
    let date = dateFormatter().string(from: Date())
    
    var recent: [String : Any]!
    
    if type == kPRIVATE {
        
        var withUser: FUser?
        
        if users != nil && users!.count > 0 {
            
            if userId == FUser.currentId() {
                withUser = users!.last!
            } else {
                withUser = users!.first!
            }
        }
        
        recent = [kRECENTID : recentId,
                  kUSERID : userId,
                  kCHATROOMID : chatRoomId,
                  kMEMBERS : members,
                  kMEMBERSTOPUSH : members,
                  kWITHUSERFULLNAME : withUser!.fullname,
                  kWITHUSERUSERID : withUser!.objectId,
                  kLASTMESSAGE : "",
                  kCOUNTER : 0,
                  kDATE : date,
                  kTYPE : type,
                  kAVATAR : withUser!.avatar]
        
    } else {
        
        if avatarOfGroup != nil {
            
            recent = [kRECENTID : recentId,
                      kUSERID: userId,
                      kCHATROOMID : chatRoomId,
                      kMEMBERS : members,
                      kMEMBERSTOPUSH : members,
                      kWITHUSERUSERNAME : withUserName,
                      kLASTMESSAGE : "",
                      kCOUNTER : 0,
                      kDATE : date,
                      kTYPE : type,
                      kAVATAR : avatarOfGroup!]
        }
    }
    
    // Save recent chat
    
    localReference.setData(recent)
}

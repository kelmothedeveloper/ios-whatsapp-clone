//
//  OutgoingMessage.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 28/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import Foundation

class OutgoingMessage {
    
    let messageDictionary: NSMutableDictionary
    
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    func sendMessage(chatRoomID: String, messageDictionary: NSMutableDictionary, memberIds: [String], membersToPush: [String]) {
        
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds {
        reference(.Message).document(memberId).collection(chatRoomID).document().setData(messageDictionary as! [String : Any])
            
        }
        
        // update recemt
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

//
//  IncomingMessage.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 28/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = messageDictionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
            message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
            print("")
        case kVIDEO:
            print("")
        case kLOCATION:
            print("")
        default:
            print("Unknown message type")
        }
        
        return message
        
    }
    
    func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID]as? String
        var date: Date!
        
        if let created = messageDictionary[kDATE] as? String {
            if created.count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created)
            }
        } else {
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
}

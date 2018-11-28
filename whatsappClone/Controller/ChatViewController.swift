//
//  ChatViewController.swift
//  whatsappClone
//
//  Created by Kelvin Fok on 27/11/18.
//  Copyright © 2018 kelvinfok. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatViewController: JSQMessagesViewController {
    
    var chatRoomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    
    var newChatListener: ListenerRegistration?
    var typingListener: ListenerRegistration?
    var updatedListener: ListenerRegistration?
    
    let legitTypes = [kAUDIO, kVIDEO, kTEXT, kPICTURE, kLOCATION]
    
    var messages: [JSQMessage] = []
    var objectMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    var initialLoadComplete = false
    
    var maxMessagesNumber = 0
    var minMessagesNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        loadMessages()
        setupJSQ()
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    
    func setupJSQ() {
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.fullname
    }
    
    func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .never
        let item = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(backItemTapped))
        navigationItem.leftBarButtonItems = [item]
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = .zero

    }
    
    @objc func backItemTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupViews() {
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        constraint.priority = UILayoutPriority(rawValue: 1000)
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Camera", style: .default) { _ in
            
        }
        
        let sharePhotoAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            
        }
        
        let shareVideoAction = UIAlertAction(title: "Video Library", style: .default) { _ in
            
            
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { _  in
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        takePhotoAction.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhotoAction.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideoAction.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(sharePhotoAction)
        optionMenu.addAction(shareVideoAction)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        if Utility.isIpad() {
            guard let currentPopoverPresentationController = optionMenu.popoverPresentationController else { return }
            let buttonItem = self.inputToolbar.contentView.leftBarButtonItem
            currentPopoverPresentationController.sourceView = buttonItem
            currentPopoverPresentationController.sourceRect = buttonItem!.bounds
            currentPopoverPresentationController.permittedArrowDirections = .up
            self.present(optionMenu, animated: true, completion: nil)
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            updateSendButton(isSent: false)
        } else {
            print("Audio message")
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            updateSendButton(isSent: true)
        } else {
            updateSendButton(isSent: false)
        }
    }
    
    func updateSendButton(isSent: Bool) {
        if isSent {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        } else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        }
    }
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
        
        var outgoingMessage: OutgoingMessage!
        let currentUser = FUser.currentUser()!
        
        if let text = text {
            outgoingMessage = OutgoingMessage(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
        finishSendingMessage()
        
        outgoingMessage.sendMessage(chatRoomID: chatRoomId, messageDictionary: outgoingMessage.messageDictionary, memberIds: memberIds, membersToPush: membersToPush)
    }
    
    func loadMessages() {
        
        
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                self.initialLoadComplete = true
                self.listenForNewChats()
                return
            }
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            //remove bad messages
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
            
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            
            self.initialLoadComplete = true
            
            self.listenForNewChats()
            
            print("we have \(self.messages.count) loaded")
//            guard let snapshot = snapshot else {
//                self.initialLoadComplete = true
//                return }
//
//            let descriptor = NSSortDescriptor(key: kDATE, ascending: true)
//
//            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [descriptor]) as! [NSDictionary]
//
//
//            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
//
//            self.finishReceivingMessage(animated: true)
//
//            self.initialLoadComplete = true
//
//            print("we have \(self.messages.count) loaded")
//
//            // Get old messages in background
//
//            // Start listening for new chats
            
        }
        
    }
    
    func insertMessages() {

        maxMessagesNumber = loadedMessages.count - loadedMessagesCount
        minMessagesNumber = maxMessagesNumber - kNUMBEROFMESSAGES

        if minMessagesNumber < 0 {
            minMessagesNumber = 0
        }

        for i in minMessagesNumber..<maxMessagesNumber {
            let messageDictionary = loadedMessages[i]
            insertInitialLoadMessages(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }

        self.showLoadEarlierMessagesHeader = loadedMessagesCount != loadedMessages.count
    }
    
    func insertInitialLoadMessages(messageDictionary: NSDictionary) -> Bool {
        
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        if messageDictionary[kSENDERID] as! String != FUser.currentId() {

        }
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        if message != nil {
            objectMessages.append(messageDictionary)
            messages.append(message!)
        }
        
        return isIncoming(messageDictionary: messageDictionary)
    }
    
    func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
        
        var tempMessages = allMessages
        for message in tempMessages {
            if message[kTYPE] != nil {
                if !self.legitTypes.contains(message[kTYPE] as! String) {
                    tempMessages.remove(at: tempMessages.index(of: message)!)
                }
            } else {
                tempMessages.remove(at: tempMessages.index(of: message)!)
            }
        }
        return tempMessages
    }
    
    func isIncoming(messageDictionary: NSDictionary) -> Bool {
        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
            return false
        } else {
            return true
        }
    }
    
    func readTimeFrom(dateString: String) -> String {
        let date = dateFormatter().date(from: dateString)
        let currentDateFormat = dateFormatter()
        currentDateFormat.dateFormat = "HH:mm"
        return currentDateFormat.string(from: date!)
    }
    
    func listenForNewChats() {
        
        var lastMessageDate = "0"
        
        if loadedMessages.count > 0 {
            lastMessageDate = loadedMessages.last![kDATE] as! String
        }
        
        newChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                for diff in snapshot.documentChanges {
                    if (diff.type == .added) {
                        let item = diff.document.data() as NSDictionary
                        if let type = item[kTYPE] {
                            if self.legitTypes.contains(type as! String) {
                                
                                //this is for picture messages
                                if type as! String == kPICTURE {
                                    // self.addNewPictureMessageLink(link: item[kPICTURE] as! String)
                                }
                                
                                if self.insertInitialLoadMessages(messageDictionary: item) {
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                self.finishReceivingMessage()
                            }
                        }
                    }
                }
            }
        })
    }
    
    
    
    func getOldChatsInBackground() {
        
        if loadedMessages.count > 10 {
            
            let firstMessageDate = loadedMessages.first![kDATE] as! String
            
            reference(.Message).document(FUser.currentId()).collection(chatRoomId).whereField(kDATE, isLessThan: firstMessageDate).getDocuments { (snapshot, error) in
                
                guard let snapshot = snapshot else { return }
                
                let descriptor = NSSortDescriptor(key: kDATE, ascending: true)
                
                let sorted = (dictionaryFromSnapshots(snapshots: snapshot.documents) as NSArray).sortedArray(using: [descriptor]) as! [NSDictionary]
                
                self.loadedMessages = self.removeBadMessages(allMessages: sorted) + self.loadedMessages
                
                // get picture messages
                
                self.maxMessagesNumber = self.loadedMessages.count - self.loadedMessagesCount - 1
                self.minMessagesNumber = self.maxMessagesNumber - kNUMBEROFMESSAGES
            }
        }
    }    
}

extension ChatViewController {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let data = messages[indexPath.item]
        if data.senderId == FUser.currentId() {
            cell.textView?.textColor = .white
        } else {
            cell.textView?.textColor = .black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.item]
        
        if data.senderId == FUser.currentId() {
            return outgoingBubble
        } else {
            return incomingBubble
        }        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = objectMessages[indexPath.row]
        let status: NSAttributedString
        let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        switch message[kSTATUS] as! String {
        case kDELIVERED:
            status = NSAttributedString(string: kDELIVERED)
        case kREAD:
            let statusText = "Read " + readTimeFrom(dateString: message[kREADDATE] as! String)
            status = NSAttributedString(string: statusText, attributes: attributedStringColor)
        default:
            status = NSAttributedString(string: "")
        }
        
        
        if indexPath.row == messages.count - 1 {
            return status
        } else {
            return NSAttributedString(string: "")
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId() {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
}

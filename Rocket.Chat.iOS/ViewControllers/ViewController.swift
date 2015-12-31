//
//  ViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/6/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import MMDrawerController
import ObjectiveDDP
import SwiftyJSON

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchRoomDelegate {
    
    @IBOutlet var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet var mainTableview: UITableView!
    @IBOutlet var composeMsg: UITextView!
    @IBOutlet var composeMsgButton: UIButton!
    
    // indexPath to find the bottom of the tableview
    var bottomIndexPath:NSIndexPath = NSIndexPath()
    
    var dateFormatter = NSDateFormatter()
    
    var meteor: MeteorClient!
    var ad:AppDelegate!
    
    //JSON to keep the response
    var chatMessages:JSON = []
    
    //Dictionary to keep each chatMessage
    var chatMessageData = [String:[ChatMessage]]()
    
    @IBOutlet var activityIndicatorInViewController: UIActivityIndicatorView!
    @IBOutlet var customIndicatorViewInViewController: UIView!
    
    var lastJoinedRoomName:String?
    var lastJoinedRoom:String?
    var tmpChatMessage:ChatMessage?
    var lastSeenTimeStamp:Double?
    
    
    var currentUsername:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notifications to manage keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        // Create tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard"))
        tapGesture.cancelsTouchesInView = true
        
        //Create double tap gesture
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: Selector("showHiddenTimestamp:"))
        doubleTapGesture.numberOfTapsRequired = 2
        
        //Add gestures on tableview
        mainTableview.addGestureRecognizer(tapGesture)
        mainTableview.addGestureRecognizer(doubleTapGesture)
        
        
        //Remove lines between cells
        mainTableview.separatorStyle = UITableViewCellSeparatorStyle.None
        
        mainTableview.rowHeight = UITableViewAutomaticDimension
        mainTableview.estimatedRowHeight = 75
        
        //Set border to composeMsg textarea
        composeMsg.layer.borderColor = UIColor.blackColor().CGColor
        composeMsg.layer.borderWidth = 0.5
        composeMsg.layer.cornerRadius = 10
        
        dateFormatter.dateFormat = "HH:mm"
        
        self.tmpChatMessage?.messageType = ""
        
        
        
        if (NSUserDefaults.standardUserDefaults().valueForKey("lastJoinedRid") != nil) {
            self.lastJoinedRoomName = NSUserDefaults.standardUserDefaults().valueForKey("lastJoinedRoomName") as? String
            self.lastJoinedRoom = NSUserDefaults.standardUserDefaults().valueForKey("lastJoinedRid") as? String
        }else {
            self.lastJoinedRoomName = "general"
            self.lastJoinedRoom = "GENERAL"
        }
        
        self.title = "#\(self.lastJoinedRoomName!)"
        
        //After login join general room
        self.ad = UIApplication.sharedApplication().delegate as! AppDelegate
        meteor = self.ad.meteorClient
        
        //Subscribe to rocketchat_message collection for the GENERAL channel
        self.meteor.addSubscription("stream-messages")
        
        
        meteor.callMethodName("channelsList", parameters: nil) { (response, error) -> Void in
            
            if error != nil {
                print(error.description)
                return
            }
            
            //print(response["result"]!["channels"]!![0]!)
        }
        
        meteor.callMethodName("joinDefaultChannels", parameters: []) { (response, error) -> Void in
            
            if error != nil {
                print("Error:\(error.description)")
                return
            }else{
                print(response)
                //Add observer to handle incoming messages
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveUpdate:", name: "stream-messages_added", object: nil)
                
                let users = self.meteor.collections["users"] as! M13MutableOrderedDictionary
                
                let user = users.objectAtIndex(0)
                self.currentUsername = user["username"] as? String

                
                
            }
        }
        
        //Get last 50 messages
        loadHistory(self.lastJoinedRoom!, numberOfMessages: 50)
        
        
        //Get the leftViewController instance and use it to notify this ViewController about changing the channel using the SwitchRoomDelegate
        let leftNavController = ad.centerContainer?.leftDrawerViewController as! UINavigationController
        let leftViewController = leftNavController.viewControllers.first as! LeftViewController
        leftViewController.viewController = self
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func leftNavTapped(sender: AnyObject) {
        
        //get the appDelegate
        let appdelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //Toggle the drawer to the left
        appdelegate.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        
    }
    
    @IBAction func rightNavTapped(sender: AnyObject) {
        
        //get the appDelegate
        let appdelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //Toggle the drawer to the right
        appdelegate.centerContainer?.toggleDrawerSide(MMDrawerSide.Right, animated: true, completion: nil)
        
        
    }
    
    
    
    //
    //MARK: TableView
    //
    
    //Sections in tableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 // Just for now?
    }
    
    
    
    //Number of table rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //If the user has joined a channel the length is that channels messages + 1 for the load more btn else it is 0
        let numOfRows = self.chatMessageData[self.lastJoinedRoom!] != nil ? self.chatMessageData[self.lastJoinedRoom!]!.count + 1 : 0
        
        return numOfRows
        
    }
    
    //Populating data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        //Get visible cells indexes
        let visible = mainTableview.indexPathsForVisibleRows
        //Set bottomIndexpath to last visible cell's index
        self.bottomIndexPath = NSIndexPath(forRow: visible!.last!.row, inSection: 0)
        
        
        
        //Boolean to check if previous and current user are the same user
        var sameUser = false
        
        
        //        print("\(indexPath.row) -- \(sameUser) -- \(self.chatMessageData[indexPath.row]![3]) -- \(self.chatMessageData[indexPath.row]![2])")
        
        
        //Check if the next and previous user are the same to see what kind of cell we will create
        if(indexPath.row > 1){
            
            if(self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].userId == self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 2].userId){
                
                sameUser = true
                
            }
        }
        
        
        
        
        //Create cell and set data
        
        //Header
        if (indexPath.row == 0) {
            
            var loadMoreHeader:LoadMoreHeaderTableViewCell? = mainTableview.dequeueReusableCellWithIdentifier("loadMoreHeader", forIndexPath: indexPath) as? LoadMoreHeaderTableViewCell
            
            if loadMoreHeader == nil{
                
                loadMoreHeader = LoadMoreHeaderTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "loadMoreHeader")
                
            }
            
            return loadMoreHeader!
        }
        
        
        
        //If Same User - return a no detailed cell
        if (sameUser) {
            
            var noDetailsCell:NoDetailsTableViewCell? = mainTableview.dequeueReusableCellWithIdentifier("noDetailsCell", forIndexPath: indexPath) as? NoDetailsTableViewCell
            
            if noDetailsCell == nil{
                
                noDetailsCell = NoDetailsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "noDetailsCell")
                
            }
            
            //Set hidden timestamp
            noDetailsCell!.hiddenTimeStamp.text = "\(dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: (self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].timestamp))))"
            noDetailsCell!.hiddenTimeStamp.hidden = true
            noDetailsCell!.hiddenTimeStamp.textColor = UIColor.rocketTimestampColor()
            
            
            //If message is removed
            if(self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].messageType == "rm") {
                
                
                //Set text to noDetailsMessage label
                noDetailsCell!.noDetailsMessage.text = "removed message"
                noDetailsCell?.noDetailsMessage.font = UIFont.italicSystemFontOfSize(15)
                
                //Set color to #444444
                noDetailsCell!.noDetailsMessage.textColor = UIColor.rocketSecondaryFontColor()
                
                return noDetailsCell!
                
            }else if (self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].messageType == "uj"){
                
                //Set text to noDetailsMessage label
                noDetailsCell!.noDetailsMessage.text = "has joined the channel"
                noDetailsCell?.noDetailsMessage.font = UIFont.italicSystemFontOfSize(15)
                
                //Set color to #444444
                noDetailsCell!.noDetailsMessage.textColor = UIColor.rocketSecondaryFontColor()
                
                return noDetailsCell!
                
            }else if (self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].messageType == "room_changed_privacy"){
                
                //Set text to noDetailsMessage label
                noDetailsCell!.noDetailsMessage.text = "room type has changed to \(self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].message) by \(self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].username)"
                noDetailsCell?.noDetailsMessage.font = UIFont.italicSystemFontOfSize(15)
                
                //Set color to #444444
                noDetailsCell!.noDetailsMessage.textColor = UIColor.rocketSecondaryFontColor()
                
                return noDetailsCell!
                
            }
            else{
                
                if (self.tmpChatMessage?.messageType == "tmp") {
                    
                    if (indexPath.row == self.chatMessageData[self.lastJoinedRoom!]?.count) {
                        
                        //Set text to noDetailsMessage label
                        noDetailsCell!.noDetailsMessage.text = self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].message
                        noDetailsCell?.noDetailsMessage.font = UIFont(name: "Roboto-Regular.ttf", size: 15)
                        
                        //Set color to #444444
                        noDetailsCell!.noDetailsMessage.textColor = UIColor.rocketRedColor()
                        
                        return noDetailsCell!
                        
                    }else {
                        
                        //Set text to noDetailsMessage label
                        noDetailsCell!.noDetailsMessage.text = self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].message
                        noDetailsCell?.noDetailsMessage.font = UIFont(name: "Roboto-Regular.ttf", size: 15)
                        
                        //Set color to #444444
                        noDetailsCell!.noDetailsMessage.textColor = UIColor.rocketSecondaryFontColor()
                        
                        return noDetailsCell!
                        
                    }
                    
                }else {
                    
                    //Set text to noDetailsMessage label
                    noDetailsCell!.noDetailsMessage.text = self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].message
                    noDetailsCell?.noDetailsMessage.font = UIFont(name: "Roboto-Regular.ttf", size: 15)
                    
                    //Set color to #444444
                    noDetailsCell!.noDetailsMessage.textColor = UIColor.rocketSecondaryFontColor()
                    
                    return noDetailsCell!
                    
                }
                
                
            }
            
            
        }
            //If different user and joined the channel - return a full detailed cell
        else if (!sameUser && self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].messageType == "uj"){
            
            var fullDetailsCell:MainTableViewCell? = mainTableview.dequeueReusableCellWithIdentifier("fullDetailsCell", forIndexPath: indexPath) as? MainTableViewCell
            
            if fullDetailsCell == nil{
                
                fullDetailsCell = MainTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "fullDetailsCell")
                
                
            }
            
            fullDetailsCell!.avatarImg.image = UIImage(named: "Default-Avatar")
            fullDetailsCell!.usernameLabel.text = self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].username
            
            //Set color to #444444
            fullDetailsCell!.usernameLabel.textColor = UIColor.rocketMainFontColor()
            
            //Set the timestamp
            fullDetailsCell!.timeLabel.text = "\(dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: (self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].timestamp))))"
            fullDetailsCell!.timeLabel.textColor = UIColor.rocketTimestampColor()
            fullDetailsCell!.messageLabel.text = "has joined the channel"
            fullDetailsCell?.messageLabel.font = UIFont.italicSystemFontOfSize(15)
            fullDetailsCell!.messageLabel.textColor = UIColor.rocketSecondaryFontColor()
            
            return fullDetailsCell!
            
        }
            //If different user - return a full detailed cell
        else {
            
            var fullDetailsCell:MainTableViewCell? = mainTableview.dequeueReusableCellWithIdentifier("fullDetailsCell", forIndexPath: indexPath) as? MainTableViewCell
            
            
            if fullDetailsCell == nil{
                
                fullDetailsCell = MainTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "fullDetailsCell")
                
            }
            
            fullDetailsCell!.avatarImg.image = UIImage(named: "Default-Avatar")
            fullDetailsCell!.usernameLabel.text = self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].username
            
            //Set color to #444444
            fullDetailsCell!.usernameLabel.textColor = UIColor.rocketMainFontColor()
            
            
            //If message is removed
            if(self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].messageType == "rm"){
                
                //Set the timestamp
                fullDetailsCell!.timeLabel.text = "\(dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: (self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].timestamp))))"
                fullDetailsCell!.timeLabel.textColor = UIColor.rocketTimestampColor()
                
                //Set the message text
                fullDetailsCell!.messageLabel.text = "message removed"
                fullDetailsCell?.messageLabel.font = UIFont.italicSystemFontOfSize(15)
                fullDetailsCell!.messageLabel.textColor = UIColor.rocketSecondaryFontColor()
                
                return fullDetailsCell!
                
                
            } else if (self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].messageType == "uj") {
                
                //Set the timestamp
                fullDetailsCell!.timeLabel.text = "\(dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: (self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].timestamp))))"
                fullDetailsCell!.timeLabel.textColor = UIColor.rocketTimestampColor()
                
                //Set the message text
                fullDetailsCell!.messageLabel.text = "has joined the channel"
                fullDetailsCell?.messageLabel.font = UIFont.italicSystemFontOfSize(15)
                fullDetailsCell!.messageLabel.textColor = UIColor.rocketSecondaryFontColor()
                
                return fullDetailsCell!
                
            } else if (self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].messageType == "room_changed_privacy") {
                
                //Set the timestamp
                fullDetailsCell!.timeLabel.text = "\(dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: (self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].timestamp))))"
                fullDetailsCell!.timeLabel.textColor = UIColor.rocketTimestampColor()
                
                //Set the message text
                fullDetailsCell!.messageLabel.text = "room type has changed to \(self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].message) by \(self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].username)"
                fullDetailsCell?.messageLabel.font = UIFont.italicSystemFontOfSize(15)
                fullDetailsCell!.messageLabel.textColor = UIColor.rocketSecondaryFontColor()
                
                return fullDetailsCell!
                
            } else {
                
                if (self.tmpChatMessage?.messageType == "tmp") {
                    
                    if (indexPath.row == self.chatMessageData[self.lastJoinedRoom!]!.count) {
                        
                        //Hide the timestamp
                        fullDetailsCell!.timeLabel.text = ""
                        
                        //Set the message text
                        fullDetailsCell!.messageLabel.text = self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].message
                        fullDetailsCell?.messageLabel.font = UIFont(name: "Roboto-Regular.ttf", size: 15)
                        fullDetailsCell!.messageLabel.textColor = UIColor.rocketRedColor()
                        
                        return fullDetailsCell!
                        
                    }else {
                        
                        //Set the timestamp
                        fullDetailsCell!.timeLabel.text = "\(dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: (self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].timestamp))))"
                        fullDetailsCell!.timeLabel.textColor = UIColor.rocketTimestampColor()
                        
                        //Set the message text
                        fullDetailsCell!.messageLabel.text = self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].message
                        fullDetailsCell?.messageLabel.font = UIFont(name: "Roboto-Regular.ttf", size: 15)
                        fullDetailsCell!.messageLabel.textColor = UIColor.rocketSecondaryFontColor()
                        
                        return fullDetailsCell!
                        
                    }
                    
                    
                }else {
                    
                    //Set the timestamp
                    fullDetailsCell!.timeLabel.text = "\(dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: (self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].timestamp))))"
                    fullDetailsCell!.timeLabel.textColor = UIColor.rocketTimestampColor()
                    
                    //Set the message text
                    fullDetailsCell!.messageLabel.text = self.chatMessageData[self.lastJoinedRoom!]![indexPath.row - 1].message
                    fullDetailsCell?.messageLabel.font = UIFont(name: "Roboto-Regular.ttf", size: 15)
                    fullDetailsCell!.messageLabel.textColor = UIColor.rocketSecondaryFontColor()
                    
                    return fullDetailsCell!
                    
                }
                
            }
            
        }
        
    }
    
    
    
    //Function to close the keyboard when send button is pressed
    @IBAction func sendMsg(sender: AnyObject) {
        
        if (composeMsg.text != ""){
            
            self.tmpChatMessage = ChatMessage(rid: self.lastJoinedRoom!, user_id: self.meteor.userId, username: self.currentUsername!, msg: composeMsg.text, msgType: "tmp", ts: NSDate().timeIntervalSince1970 * 1000.0)
            
            self.chatMessageData[self.lastJoinedRoom!]?.append(self.tmpChatMessage!)
            
            self.mainTableview.reloadData()
            
            if self.chatMessageData[self.lastJoinedRoom!] != nil {
                //If iOS 8 scrolling doesn't work properly.
                self.bottomIndexPath = NSIndexPath(forRow: self.chatMessageData[self.lastJoinedRoom!]!.count, inSection: 0)
                self.mainTableview.scrollToRowAtIndexPath(self.bottomIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
            }
            
            
            var messageObject = NSDictionary()
            messageObject = [
                "rid":self.lastJoinedRoom!,
                "msg":composeMsg.text!
            ]
            
            meteor.callMethodName("sendMessage", parameters: [messageObject], responseCallback: { (response, error) -> Void in
                
                if error != nil {
                    print("Error:\(error.description)")
                    return
                }else{
                    self.composeMsg.text = ""
                    //print(response)
                }
                
            })
            
        }
        
    }
    
    
    
    //function to move composeMsg text area up when keyboard shows up
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            //add the keyboard height to the tableview's bottom constraint
            self.bottomViewBottomConstraint.constant += keyboardFrame.size.height
            self.tableViewTopConstraint.constant -= keyboardFrame.size.height
        })
        
    }
    
    
    //function to move composeMsg text area down when keyboard hides
    func keyboardWillHide(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            //substract the keyboard height from the tableview's bottom constraint
            self.bottomViewBottomConstraint.constant -= keyboardFrame.size.height
            self.tableViewTopConstraint.constant += keyboardFrame.size.height
        })
        
        
    }
    
    
    //Function to dismiss keyboard
    func dismissKeyboard() {
        
        //dismiss keyboard
        composeMsg.resignFirstResponder()
    }
    
    
    //Function to toggle message's timestamp
    func showHiddenTimestamp(gesture: UITapGestureRecognizer) {
        
        //If double tapping happens inside the tableview
        if mainTableview.indexPathForRowAtPoint(gesture.locationInView(mainTableview)) != nil {
            
            //get the index path of the cell where the user double tapped on
            let tableCellRow = mainTableview.indexPathForRowAtPoint(gesture.locationInView(mainTableview))!
            
            //Get the cell
            if  let tableCell = mainTableview.cellForRowAtIndexPath(tableCellRow) as? NoDetailsTableViewCell {
                
                //Toggle timestamp
                
                if !tableCell.hiddenTimeStamp.hidden {
                    
                    tableCell.hiddenTimeStamp.hidden = true
                    
                }else {
                    
                    tableCell.hiddenTimeStamp.hidden = false
                    
                }
            }
        }
    }
    
    //Function to add the incoming messages
    func didReceiveUpdate(notification: NSNotification) {
        
        
        if let args = notification.userInfo!["args"] {
            
            let msg = JSON(args[1]!)
            //            print(msg)
            
            if self.tmpChatMessage?.messageType == "tmp"{
                
                self.tmpChatMessage?.messageType = ""
                self.chatMessageData[self.lastJoinedRoom!]?.removeLast()
                
            }
            
            if self.lastSeenTimeStamp != Double(msg["ts"]["$date"].number! as NSNumber) {
                
                
                
                
                if msg["rid"].string == NSUserDefaults.standardUserDefaults().valueForKey("lastJoinedRid") as? String {
                    var type = ""
                    if let t = msg["t"].string{
                        type = t
                    }
                    
                    let timestamp = [msg["ts"]["$date"].number! as NSNumber]
                    let timestampInDouble = timestamp as! [Double]
                    let timestampInMilliseconds = timestampInDouble[0] / 1000
                    
                    let incomingMsg = ChatMessage(rid: msg["rid"].string!,user_id: msg["u"]["_id"].string!, username: msg["u"]["username"].string!, msg: msg["msg"].string!, msgType: type, ts: timestampInMilliseconds)
                    
                    if self.chatMessageData[self.lastJoinedRoom!] != nil{
                        self.chatMessageData[self.lastJoinedRoom!]!.append(incomingMsg)
                    } else {
                        self.chatMessageData[self.lastJoinedRoom!] = [incomingMsg]
                    }
                    
                    self.lastSeenTimeStamp = Double(msg["ts"]["$date"].number! as NSNumber)
                    
                    
                    
                    //Reloading data and if we are at the bottom scroll the view to the last row
                    self.mainTableview.reloadData()
                    
                    if let lastVisibleCells = self.mainTableview.visibleCells.last {
                        
                        let lastVisibleCellsIndexPath = NSIndexPath(forRow: self.mainTableview.indexPathForCell(lastVisibleCells)!.row, inSection: 0)
                        
                        self.bottomIndexPath = NSIndexPath(forRow: self.chatMessageData[self.lastJoinedRoom!]!.count, inSection: 0)
                        
                        if (lastVisibleCellsIndexPath.row >= bottomIndexPath.row - 1) {
                            print("scroll to bottom")
                            self.mainTableview.scrollToRowAtIndexPath(self.bottomIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                        }
                        
                    } else {
                        //When we are in an empty room and a we have an incoming message to another room we have joined
                        print("No need to scroll")
                        self.bottomIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                        
                    }
                }
            }
        }
        
        
    }
    
    func connectionStatus(live:Bool) {
        
        if (live){
            
            self.customIndicatorViewInViewController.hidden = true
            self.activityIndicatorInViewController.stopAnimating()
            self.composeMsg.userInteractionEnabled = true
            self.composeMsg.backgroundColor = UIColor.whiteColor()
            self.composeMsgButton.userInteractionEnabled = true
            self.composeMsgButton.enabled = true
            
        }else {
            
            self.customIndicatorViewInViewController.hidden = false
            self.activityIndicatorInViewController.startAnimating()
            self.composeMsg.userInteractionEnabled = false
            self.composeMsg.backgroundColor = UIColor.lightGrayColor()
            self.composeMsgButton.userInteractionEnabled = false
            self.composeMsgButton.enabled = false
        }
        
        
    }
    
    func didSelectRoom(rid: String, roomName: String) {
        
        NSUserDefaults.standardUserDefaults().setValue(roomName, forKey: "lastJoinedRoomName")
        NSUserDefaults.standardUserDefaults().setValue(rid, forKey: "lastJoinedRid")
        
        self.lastJoinedRoomName = NSUserDefaults.standardUserDefaults().valueForKey("lastJoinedRoomName") as? String
        self.lastJoinedRoom = NSUserDefaults.standardUserDefaults().valueForKey("lastJoinedRid") as? String
        self.title = "#\(NSUserDefaults.standardUserDefaults().valueForKey("lastJoinedRoomName")!)"
        
        if self.composeMsgButton.enabled == false {

            self.composeMsg.userInteractionEnabled = true
            self.composeMsg.backgroundColor = UIColor.whiteColor()
            self.composeMsgButton.userInteractionEnabled = true
            self.composeMsgButton.enabled = true
            
        }
        
        if self.chatMessageData[lastJoinedRoom!] == nil {
            
            loadHistory(self.lastJoinedRoom!, numberOfMessages: 50)
            
        }else {

            var unreadChatMessages = [ChatMessage]()
            
            let formData = NSDictionary(dictionary: [
                "$date": ((self.chatMessageData[self.lastJoinedRoom!]?.last!.timestamp)! * 1000)
                ])
            
            self.meteor.callMethodName("loadMissedMessages", parameters: [self.lastJoinedRoom!, formData], responseCallback: { (response, error) -> Void in
                
                if error != nil {
                    print(error.description)
                    return
                }

                let unread = JSON(response["result"]!)
                print("Unread:\(unread)")
                
                for (_,subJson) in unread {
                    
                    var type = ""
                    if subJson["t"].string != nil {
                        type = subJson["t"].string!
                    }
                    
                    let timestamp = [subJson["ts","$date"].number!]
                    let timestampInDouble = timestamp as! [Double]
                    let timestampInMilliseconds = timestampInDouble[0] / 1000
                    
                    let  cM = ChatMessage(rid: subJson["rid"].string!,user_id: subJson["u","_id"].string!, username: subJson["u","username"].string!, msg: subJson["msg"].string!, msgType: type, ts: timestampInMilliseconds)
                    unreadChatMessages.append(cM)
                    
                    
                }
                
                unreadChatMessages = unreadChatMessages.reverse()
                
                for (var i = 0; i < unreadChatMessages.count; i++){
                    self.chatMessageData[self.lastJoinedRoom!]! += [unreadChatMessages[i]]
                }
                
                self.mainTableview.reloadData()
                
                //If iOS 8 scrolling doesn't work properly.
                self.bottomIndexPath = NSIndexPath(forRow: self.chatMessageData[self.lastJoinedRoom!]!.count, inSection: 0)
                
                //Uncomment this if you want to scroll at the bottom even when selecting the current channel
                self.mainTableview.scrollToRowAtIndexPath(self.bottomIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                
                unreadChatMessages.removeAll()
            })
            
        }
        
    }
    
    
    
    func loadHistory(room: String, numberOfMessages: Int){
        
        //Get the 50 past messages to fill the tableview
        let now = NSDate()
        
        let formData = NSDictionary(dictionary: [
            "$date": now.timeIntervalSince1970*1000
            ])
        
        meteor.callMethodName("loadHistory", parameters: [room, formData, numberOfMessages], responseCallback: { (response, error) -> Void in
            
            if error != nil {
                
                print("Error:\(error.description)")
                let alert = UIAlertController(title: "Invalid Room", message: "This room is invalid. You will be redirected to the general channel", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){ _ in
//                    self.ad.centerContainer?.openDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
                    self.didSelectRoom("GENERAL", roomName: "general")
                }
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
                return
                
            } else {
                
                //print(response!["result"]!)
                
                //JSON Handling
                let result = JSON(response)
                self.chatMessages = result["result"]["messages"]
                
                if self.chatMessages.count > 0 {
                    
                    for (_,subJson) in self.chatMessages {
                        
                        var type = ""
                        if subJson["t"].string != nil {
                            type = subJson["t"].string!
                        }
                        
                        let timestamp = [subJson["ts","$date"].number!]
                        let timestampInDouble = timestamp as! [Double]
                        let timestampInMilliseconds = timestampInDouble[0] / 1000
                        
                        let  cM = ChatMessage(rid: subJson["rid"].string!,user_id: subJson["u","_id"].string!, username: subJson["u","username"].string!, msg: subJson["msg"].string!, msgType: type, ts: timestampInMilliseconds)
                        
                        if self.chatMessageData[cM.rid] == nil {
                            
                            self.chatMessageData[cM.rid] = [cM]
                            
                        }else {
                            
                            self.chatMessageData[cM.rid]! += [cM]
                            
                        }
                        
                    }
                    
                    self.chatMessageData[room] = self.chatMessageData[room]!.reverse()
                    //Reload data and scroll to the bottom of the tableview
                    self.mainTableview.reloadData()
                    //If iOS 8 scrolling doesn't work properly.
                    self.bottomIndexPath = NSIndexPath(forRow: self.chatMessageData[room]!.count, inSection: 0)
                    self.mainTableview.scrollToRowAtIndexPath(self.bottomIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                    
                }else {
                    self.mainTableview.reloadData()
                }
            }
        })
        
    }
    
    
}
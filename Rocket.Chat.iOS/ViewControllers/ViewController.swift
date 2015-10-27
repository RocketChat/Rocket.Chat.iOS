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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewTopConstraint: NSLayoutConstraint!
    
    
    @IBOutlet var mainTableview: UITableView!
    @IBOutlet var composeMsg: UITextView!
    
    // indexPath to find the bottom of the tableview
    var bottomIndexPath:NSIndexPath = NSIndexPath()
  
    var dateFormatter = NSDateFormatter()

    var meteor: MeteorClient!

    var chatMessages:JSON = []

    //Dictionary to keep the users from the JSON response
    var users = [Int():[String(),String(),String(),String()]]
    
    //Dictionary to keep the timestamps from the JSON response
    var ts = [Int():[Double()]]
    
    //Counter used in didReceiveUpdate for the incoming messages
    var counter = 0
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        
        
        let ad = UIApplication.sharedApplication().delegate as! AppDelegate
        meteor = ad.meteorClient

        
        //After login join general room

        meteor.callMethodName("joinDefaultChannels", parameters: nil, responseCallback: { (response, error) -> Void in
            
                if error != nil {
                    
                    print("Error:\(error.description)\n")
                    return

                } else {
                    
//                    print("\(response)\n")

                }
            
        })
        
        



 
        //Get the 50 past messages to fill the tableview
        //This is just temporary. Later the RoomHistoryManager will handle the way the messages are coming in
        let now = NSDate()

        let formData = NSDictionary(dictionary: [
            "$date": now.timeIntervalSince1970*1000
            ])
        
        meteor.callMethodName("loadHistory", parameters: ["GENERAL", formData,50], responseCallback: { (response, error) -> Void in
            
            if error != nil {
               
                print("Error:\(error.description)")
                return
            
            } else {
                
//                print(response!["result"]!)
          
                //JSON Handling
                let result = JSON(response)
                self.chatMessages = result["result"]["messages"]
                

                
//                print(self.chatMessages)
//                print(self.users!)

                
                var i = self.chatMessages.count
                
                for (_,subJson) in self.chatMessages {
                    
                    var type = ""
                    if subJson["t"].string != nil {
                        type = subJson["t"].string!
                    }
                    
                    
                    self.users[i] = [subJson["u","_id"].string!, subJson["u","username"].string!, subJson["msg"].string!,type]
                    let timestamp = [subJson["ts","$date"].number!]
                    let timestampInDouble = timestamp as! [Double]
                    self.ts[i] =  [timestampInDouble[0] / 1000]
                    i--
                }
                
                
                
                
//                for (var i = 0; i<self.users.count; i++){
//                    print("\(self.users[i])\n")
//                }
                
                
                //Reload data and scroll to the bottom of the tableview
                self.mainTableview.reloadData()
                self.bottomIndexPath = NSIndexPath(forRow: self.chatMessages.count, inSection: 0)
                self.mainTableview.scrollToRowAtIndexPath(self.bottomIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                
                //Subscribe to rocketchat_message collection for the GENERAL channel
                self.meteor.addSubscription("messages", withParameters: ["GENERAL"])
                
                //Add observer to handle incoming messages
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveUpdate:", name: "rocketchat_message_added", object: nil)


            }

        })
        
    }
    


    
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
        
      return self.users.count
      
    }
    
    //Populating data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        //Get visible cells indexes
        let visible = mainTableview.indexPathsForVisibleRows
        //Set bottomIndexpath to last visible cell's index
        bottomIndexPath = NSIndexPath(forRow: visible!.last!.row, inSection: 0)
      

        
        //Boolean to check if previous and current user are the same user
        var sameUser = false

        
//        print("\(indexPath.row) -- \(sameUser) -- \(self.users[indexPath.row]![3]) -- \(self.users[indexPath.row]![2])")
        
        
        //Check if the next and previous user are the same to see what kind of cell we will create
        if(indexPath.row > 0){

            if(self.users[indexPath.row]![0] == self.users[indexPath.row - 1]![0]){

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
        
        

        //If Same User - return a full detailed cell
        if (sameUser) {
            
            var noDetailsCell:NoDetailsTableViewCell? = mainTableview.dequeueReusableCellWithIdentifier("noDetailsCell", forIndexPath: indexPath) as? NoDetailsTableViewCell
            
            if noDetailsCell == nil{
                
                noDetailsCell = NoDetailsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "noDetailsCell")
            
            }

            //Set hidden timestamp
            noDetailsCell!.hiddenTimeStamp.text = "\(dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: self.ts[indexPath.row]![0])))"
            noDetailsCell!.hiddenTimeStamp.hidden = true
            noDetailsCell!.hiddenTimeStamp.textColor = UIColor.rocketTimestampColor()

            //Set text to noDetailsMessage label
            noDetailsCell!.noDetailsMessage.text = self.users[indexPath.row]![2]
            noDetailsCell?.noDetailsMessage.font = UIFont(name: "Roboto-Regular.ttf", size: 15)
            
            //Set color to #444444
            noDetailsCell!.noDetailsMessage.textColor = UIColor.rocketSecondaryFontColor()
            
            return noDetailsCell!
            
        }
        //If different user and joined the channel - return a full detailed cell
        else if (!sameUser && self.users[indexPath.row]![3] == "uj"){

            var fullDetailsCell:MainTableViewCell? = mainTableview.dequeueReusableCellWithIdentifier("fullDetailsCell", forIndexPath: indexPath) as? MainTableViewCell
            
            if fullDetailsCell == nil{
                
                fullDetailsCell = MainTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "fullDetailsCell")
                
                
            }

            fullDetailsCell!.avatarImg.image = UIImage(named: "Default-Avatar")
            fullDetailsCell!.usernameLabel.text = self.users[indexPath.row]![1]

            //Set color to #444444
            fullDetailsCell!.usernameLabel.textColor = UIColor.rocketMainFontColor()
            
            //Set the timestamp
            fullDetailsCell!.timeLabel.text = "\(dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: self.ts[indexPath.row]![0])))"
            fullDetailsCell!.timeLabel.textColor = UIColor.rocketTimestampColor()
            fullDetailsCell!.messageLabel.text = "has joined the channel"
            fullDetailsCell?.messageLabel.font = UIFont.italicSystemFontOfSize(15)
            fullDetailsCell!.messageLabel.textColor = UIColor.rocketSecondaryFontColor()

            return fullDetailsCell!
        }
        //If different user - return a non detailed cell
        else {
            
            
            var fullDetailsCell:MainTableViewCell? = mainTableview.dequeueReusableCellWithIdentifier("fullDetailsCell", forIndexPath: indexPath) as? MainTableViewCell
            
            
            if fullDetailsCell == nil{
                
                fullDetailsCell = MainTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "fullDetailsCell")
                
            }
            

            fullDetailsCell!.avatarImg.image = UIImage(named: "Default-Avatar")
            fullDetailsCell!.usernameLabel.text = self.users[indexPath.row]![1]

            //Set color to #444444
            fullDetailsCell!.usernameLabel.textColor = UIColor.rocketMainFontColor()
            
            //Set the timestamp
            fullDetailsCell!.timeLabel.text = "\(dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: self.ts[indexPath.row]![0])))"
            fullDetailsCell!.timeLabel.textColor = UIColor.rocketTimestampColor()
            
            //Set the message text
            fullDetailsCell!.messageLabel.text = self.users[indexPath.row]![2]
            fullDetailsCell?.messageLabel.font = UIFont(name: "Roboto-Regular.ttf", size: 15)
            fullDetailsCell!.messageLabel.textColor = UIColor.rocketSecondaryFontColor()
            
            return fullDetailsCell!
        }
        
    }
    
    
    
    //Function to close the keyboard when send button is pressed
    @IBAction func sendMsg(sender: AnyObject) {

        
/*** TESTING THIS ***/
        
//        let formData = NSDictionary(dictionary: [
//            "message": composeMsg.text!,
//            ])
//
//        if composeMsg.text != "" {
//            meteor.callMethodName("sendMessage", parameters: [formData], responseCallback: { (responce, error) -> Void in
//                
//                if (error != nil) {
//                    
//                    print("Error: \(error.description)")
//                    return
//                    
//                }else {
//                    print("Message sent")
//                }
//                
//            })
//
//        }
        
/******/


        
//        //If there is text
//        if composeMsg.text != "" {
//            //create current message
////            let currentMsg:Message = Message(id: "", text: composeMsg.text, tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: currentUser!)
//          let currentMsg:Message = Message(id: "", text: composeMsg.text, tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: User?)	// FIXME!
//            //add it to the messages array
//            mArray1 += [currentMsg]
//            
//            
//            //update the messages array of the chatroom
//            cR1?.messages = mArray1
//            
//            //reset the text input
//            composeMsg.text = ""
//            
//            //dismiss keyboard - Uncomment the next line if you want keyboard to hide when you send a message
//            //dismissKeyboard()
//            
//            //reload the tableview data
//            mainTableview.reloadData()
//            
//            
//            //get the bottom index - THIS NEEDS TO BE REMOVED -
//            //bottomIndexPath = NSIndexPath(forRow: cR1!.messages.count-1, inSection: 0)
//            
//            //If we are the bottom
//            if (bottomIndexPath.row == cR1!.messages.count - 1) {
//            //scroll to bottom
//                mainTableview.scrollToRowAtIndexPath(bottomIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
//                //calling it twice because something is wrong with scrolling the tableview to the bottom in iOS 9
//                mainTableview.scrollToRowAtIndexPath(bottomIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
//            }
//            
//        }
//        //If text is empty
//        else{
//        
//            //dismiss keyboard
//            dismissKeyboard()
//        }
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
    
    
    //Function to get random number between 1-60 to create different timestamps
    func randomTime() -> Double {
        let r = arc4random_uniform(60) + 1
        return Double(r)
    }

    
    //Function to dismiss keyboard
    func dismissKeyboard() {
        
        //dismiss keyboard
        composeMsg.resignFirstResponder()
    }
    
    
    //Function to toggle message's timestamp
    func showHiddenTimestamp(gesture: UITapGestureRecognizer) {
        
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
//
//  ViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/6/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import MMDrawerController

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var bottomViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewTopConstraint: NSLayoutConstraint!
    
    
    //Variable to keep the logged in user
    var currentUser = User?()
    
    //Array to keep dummy messages
    var mArray1:[Message] = []
    

    @IBOutlet var mainTableview: UITableView!
    @IBOutlet var composeMsg: UITextView!
    
    // Variable to access the dummy chatroom
    var cR1:ChatRoom?
    
    // indexPath to find the bottom of the tableview
    var bottomIndexPath:NSIndexPath = NSIndexPath()
    
    
    var dateFormatter = NSDateFormatter()
    
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
        
        
        /********* Dummy data *********/
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.stack!.context

        
        //Create user u1
        let u1:User = User(context: context, id: "1", username: "Komic", avatar: UIImage(named: "Default-Avatar")!, status: User.Status.ONLINE, timezone: NSTimeZone.systemTimeZone())
        
        //Create some messages for u1
        let msg1:Message = Message(id: "1", text: "Message 1 from Komic", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u1)
        let msg2:Message = Message(id: "2", text: "Bigger Message, number 2 from Komic just for fun", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u1)
        let msg3:Message = Message(id: "3", text: "Message 3 from Komic just to see what's up with the cell height", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u1)
        let msg4:Message = Message(id: "4", text: "Message 4 from Komic, a little smaller", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u1)
        let msg5:Message = Message(id: "5", text: "Message 5 from Komic is message 5", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u1)
    
        
        //Create user u2
        let u2:User = User(context: context, id: "2", username: "Yorgos", avatar: UIImage(named: "Default-Avatar")!, status: User.Status.ONLINE, timezone: NSTimeZone.systemTimeZone())
        
        //Create some messages for u2
        let msg6:Message = Message(id: "6", text: "Message 6 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        let msg7:Message = Message(id: "7", text: "Message 7 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        let msg8:Message = Message(id: "8", text: "Message 8 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        let msg9:Message = Message(id: "9", text: "Message 9 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        let msg10:Message = Message(id: "10", text: "Message 10 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        let msg11:Message = Message(id: "11", text: "Message 11 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        
        
        //Create user u3
        let u3:User = User(context: context, id: "3", username: "GeorgeP", avatar: UIImage(named: "Default-Avatar")!, status: User.Status.ONLINE, timezone: NSTimeZone.systemTimeZone())
        
        //Create some messages for u3
        let msg12:Message = Message(id: "12", text: "Message 12 from GeorgeP", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u3)
        let msg13:Message = Message(id: "13", text: "Message 13 from GeorgeP", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u3)
        let msg14:Message = Message(id: "14", text: "Message 14 from GeorgeP", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u3)
        let msg15:Message = Message(id: "15", text: "Message 15 from GeorgeP", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u3)
        let msg16:Message = Message(id: "16", text: "Message 16 from GeorgeP", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u3)
        let msg17:Message = Message(id: "17", text: "Message 17 from GeorgeP", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u3)
        let msg18:Message = Message(id: "18", text: "Message 18 from GeorgeP", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u3)
        let msg19:Message = Message(id: "19", text: "Message 19 from GeorgeP", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u3)
        let msg20:Message = Message(id: "20", text: "Message 20 from GeorgeP", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u3)
        
        //Create set of users
        let uSet1:Set<User> = [u1, u2, u3]
        
        
    
        //Inserting messages in an array (DUMB way)
        mArray1 = [msg1, msg2, msg3, msg4, msg5, msg6, msg7, msg8, msg9, msg10, msg11, msg12, msg13, msg14, msg15, msg16, msg17, msg18, msg19, msg20]
        
       
        
        //BubbleSort to keep messages in order by tstamps
        let nElements = mArray1.count
        
        var didSwap = true
        
        while didSwap {
            didSwap = false
            
            for i in 0..<nElements - 1 {
                if (mArray1[i].tstamp.compare(mArray1[i+1].tstamp) == NSComparisonResult.OrderedDescending)  {
                    let tmp = mArray1[i]
                    mArray1[i] = mArray1[i+1]
                    mArray1[i+1] = tmp
                    didSwap = true
                }
            }
        }
        
        
          //Logs
//        for i in mArray1 {
//            
//            print(i.text + " " + "\(i.user.username)")
//            
//        }
        
        
        
        //Create chatroom 1
        let c1:ChatRoom = ChatRoom(id: "1", name: "c1", type: .PUBLIC, users: uSet1, messages: mArray1)
        
        
        //store the created chatroom c1 into global variable cR1
        cR1 = c1
        
        /********* End of Dummy data *********/
        
        
        //Remove lines between cells
        mainTableview.separatorStyle = UITableViewCellSeparatorStyle.None
        
        mainTableview.rowHeight = UITableViewAutomaticDimension
        mainTableview.estimatedRowHeight = 75
        
        
        
        //Set bottomIndexpath to last cell's index
        bottomIndexPath = NSIndexPath(forRow: cR1!.messages.count-1, inSection: 0)
        mainTableview.scrollToRowAtIndexPath(bottomIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        
        //fix for tableview not scrolling all the way to the bottom in iOS 9
        mainTableview.reloadData()
        
        
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
    
    override func viewDidLayoutSubviews() {
        
        //scroll tableview at the bottomIndexPath
//        mainTableview.scrollToRowAtIndexPath(bottomIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        
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
        
        return cR1!.messages.count + 1 //plus 1 to put the loadMore button at the top
        
    }
    
    //Populating data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Get visible cells indexes
        let visible = mainTableview.indexPathsForVisibleRows
        
        //Set bottomIndexpath to last visible cell's index
        bottomIndexPath = NSIndexPath(forRow: visible!.last!.row, inSection: 0)
        
        
        //Boolean to check if previous and current user are the same user
        var sameUser = false
        
        
        //Get current row
        let row = indexPath.row - 1 //minus 1 to stay in range of the array
        
        //Get previous row
        let prevRow = row - 1
        
        
        //Check previous and current user
        if(row > 0){
            
            if(cR1!.messages[row].user == cR1!.messages[prevRow].user){
            
                //If true then set sameUser to true
                sameUser = true
            
            }
        }
        
        
        
        //Create cell and set data
        
        //if we scrolled at the top
        if (indexPath.row == 0) {
            
            //try create the cell for the load button
            var loadMoreHeader:LoadMoreHeaderTableViewCell? = mainTableview.dequeueReusableCellWithIdentifier("loadMoreHeader", forIndexPath: indexPath) as? LoadMoreHeaderTableViewCell
            
            //if the cell is nil
            if loadMoreHeader == nil{
                
                //create it
                loadMoreHeader = LoadMoreHeaderTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "loadMoreHeader")
                
            }
            
            //return it
            return loadMoreHeader!
        }
        
        
        //If same user
        if sameUser {
            
            //Try to create cell
            var noDetailsCell:NoDetailsTableViewCell? = mainTableview.dequeueReusableCellWithIdentifier("noDetailsCell", forIndexPath: indexPath) as? NoDetailsTableViewCell
            
            //If it is nill
            if noDetailsCell == nil{
                
                //Create the cell
                noDetailsCell = NoDetailsTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "noDetailsCell")
            
            }
            
            //Set hidden timestamp
            let defaultTimeZoneStr = dateFormatter.stringFromDate(cR1!.messages[indexPath.row - 1].tstamp)
            print(defaultTimeZoneStr)
            noDetailsCell!.hiddenTimeStamp.text = "\(defaultTimeZoneStr)"
            noDetailsCell!.hiddenTimeStamp.hidden = true
            
            //Set text to noDetailsMessage label
            noDetailsCell!.noDetailsMessage.text = "\(cR1!.messages[indexPath.row - 1].text)"
            
            //Set color to #444444
            noDetailsCell!.noDetailsMessage.textColor = UIColor.colorWithHexValue(44, greenValue: 44, blueValue: 44, alpha: 1)
            
            //return the no detailed cell
            return noDetailsCell!
            
        }
        //If different user
        else{
            
            //Try to create the cell
            var fullDetailsCell:MainTableViewCell? = mainTableview.dequeueReusableCellWithIdentifier("fullDetailsCell", forIndexPath: indexPath) as? MainTableViewCell
            
            //If nill
            if fullDetailsCell == nil{
                
                //Create the cell
                fullDetailsCell = MainTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "fullDetailsCell")
                
                
            }
            
            //Set the image
            fullDetailsCell!.avatarImg.image = UIImage(data: (cR1?.messages[indexPath.row - 1].user.avata)!)
            
            //Set the text for the username label
            fullDetailsCell!.usernameLabel.text = "\(cR1!.messages[indexPath.row - 1].user.username)"
            
            //Set color to #444444
            fullDetailsCell!.usernameLabel.textColor = UIColor.colorWithHexValue(44, greenValue: 44, blueValue: 44, alpha: 1)
            
            //Set the timestamp
            let defaultTimeZoneStr = dateFormatter.stringFromDate(cR1!.messages[indexPath.row - 1].tstamp)
            print(defaultTimeZoneStr)
            fullDetailsCell!.timeLabel.text = "\(defaultTimeZoneStr)"
            
            
            //Set the message text
            fullDetailsCell!.messageLabel.text = "\(cR1!.messages[indexPath.row - 1].text)"
            
            //Return the full detailed cell
            return fullDetailsCell!
        }
        
        
    }
    
    
    
    //Function to close the keyboard when send button is pressed
    @IBAction func sendMsg(sender: AnyObject) {
        
        //If there is text
        if composeMsg.text != "" {
            //create current message
//            let currentMsg:Message = Message(id: "", text: composeMsg.text, tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: currentUser!)
            let currentMsg:Message = Message(id: "", text: composeMsg.text, tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: currentUser!)
            //add it to the messages array
            mArray1 += [currentMsg]
            
            
            //update the messages array of the chatroom
            cR1?.messages = mArray1
            
            //reset the text input
            composeMsg.text = ""
            
            //dismiss keyboard - Uncomment the next line if you want keyboard to hide when you send a message
            //dismissKeyboard()
            
            //reload the tableview data
            mainTableview.reloadData()
            
            
            //get the bottom index - THIS NEEDS TO BE REMOVED -
            //bottomIndexPath = NSIndexPath(forRow: cR1!.messages.count-1, inSection: 0)
            
            //If we are the bottom
            if (bottomIndexPath.row == cR1!.messages.count - 1) {
            //scroll to bottom
                mainTableview.scrollToRowAtIndexPath(bottomIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                //calling it twice because something is wrong with scrolling the tableview to the bottom in iOS 9
                mainTableview.scrollToRowAtIndexPath(bottomIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
            }
            
        }
        //If text is empty
        else{
        
            //dismiss keyboard
            dismissKeyboard()
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

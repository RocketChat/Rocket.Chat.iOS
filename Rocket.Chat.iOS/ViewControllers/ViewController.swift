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
        
        
       
        
        
        //Remove lines between cells
        mainTableview.separatorStyle = UITableViewCellSeparatorStyle.None
        
        mainTableview.rowHeight = UITableViewAutomaticDimension
        mainTableview.estimatedRowHeight = 75
        
        
        
        //Set bottomIndexpath to last cell's index
        
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
        

        return 1
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
            noDetailsCell!.hiddenTimeStamp.text = "\(defaultTimeZoneStr)"
            noDetailsCell!.hiddenTimeStamp.hidden = true
            noDetailsCell!.hiddenTimeStamp.textColor = UIColor.rocketTimestampColor()

            //Set text to noDetailsMessage label
            noDetailsCell!.noDetailsMessage.text = "\(cR1!.messages[indexPath.row - 1].text)"
            
            //Set color to #444444
//            noDetailsCell!.noDetailsMessage.textColor = UIColor.colorWithHexValue(44, greenValue: 44, blueValue: 44, alpha: 1)
            noDetailsCell!.noDetailsMessage.textColor = UIColor.rocketSecondaryFontColor()
            
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
//            fullDetailsCell!.usernameLabel.textColor = UIColor.colorWithHexValue(44, greenValue: 44, blueValue: 44, alpha: 1)
            fullDetailsCell!.usernameLabel.textColor = UIColor.rocketMainFontColor()
            
            //Set the timestamp
            let defaultTimeZoneStr = dateFormatter.stringFromDate(cR1!.messages[indexPath.row - 1].tstamp)
            fullDetailsCell!.timeLabel.text = "\(defaultTimeZoneStr)"
            fullDetailsCell!.timeLabel.textColor = UIColor.rocketTimestampColor()
            
            //Set the message text
            fullDetailsCell!.messageLabel.text = "\(cR1!.messages[indexPath.row - 1].text)"
            
            fullDetailsCell!.messageLabel.textColor = UIColor.rocketSecondaryFontColor()
            
            //Return the full detailed cell
            return fullDetailsCell!
        }
        
        
    }
    
    
    
    //Function to close the keyboard when send button is pressed
    @IBAction func sendMsg(sender: AnyObject) {
        
        //If there is text
        if composeMsg.text != "" {
            //create current message
            
            //add it to the messages array
            
            
            //update the messages array of the chatroom
            
            
            //reset the text input
            
            
            //dismiss keyboard - Uncomment the next line if you want keyboard to hide when you send a message
            //dismissKeyboard()
            
            //reload the tableview data
            
            
            //If we are the bottom
           
            //scroll to bottom
           
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
    
    //Function to dismiss keyboard
    func dismissKeyboard() {
        
        //dismiss keyboard
        composeMsg.resignFirstResponder()
        
    }
    
    
    //WE MIGHT NEED THIS LATER
    
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
    
    //THIS IS NOT NEEDED ANYMORE (???)
    
    //Function to get random number between 1-60 to create different timestamps
    func randomTime() -> Double {
        let r = arc4random_uniform(60) + 1
        return Double(r)
    }
    
}
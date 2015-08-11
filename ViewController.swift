//
//  ViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/6/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var mainTableview: UITableView!
    
    //Variable to access the dummy chatroom
    var cR1:ChatRoom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        /********* Dummy data *********/
        
        //Create user u1
        let u1:User = User(id: "1", username: "Komic", avatar: "avatar.png", status: User.Status.ONLINE, timezone: NSTimeZone.systemTimeZone())
    
        //Create some messages for u1
        let msg1:Message = Message(id: "1", text: "Message 1 from Komic", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u1)
        let msg2:Message = Message(id: "2", text: "Message 2 from Komic", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u1)
        let msg3:Message = Message(id: "3", text: "Message 3 from Komic", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u1)
        let msg4:Message = Message(id: "4", text: "Message 4 from Komic", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u1)
        let msg5:Message = Message(id: "5", text: "Message 5 from Komic", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u1)
    
        
        //Create user u2
        let u2:User = User(id: "2", username: "Yorgos", avatar: "avatar.png", status: User.Status.ONLINE, timezone: NSTimeZone.systemTimeZone())
        
        //Create some messages for u2
        let msg6:Message = Message(id: "6", text: "Message 6 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        let msg7:Message = Message(id: "7", text: "Message 7 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        let msg8:Message = Message(id: "8", text: "Message 8 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        let msg9:Message = Message(id: "9", text: "Message 9 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        let msg10:Message = Message(id: "10", text: "Message 10 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        let msg11:Message = Message(id: "11", text: "Message 11 from Yorgos", tstamp: NSDate(timeInterval: randomTime(), sinceDate: NSDate()), user: u2)
        
        
        //Create user u3
        let u3:User = User(id: "3", username: "GeorgeP", avatar: "avatar.png", status: User.Status.ONLINE, timezone: NSTimeZone.systemTimeZone())
        
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
        var mArray1:[Message] = [msg1, msg2, msg3, msg4, msg5, msg6, msg7, msg8, msg9, msg10, msg11, msg12, msg13, msg14, msg15, msg16, msg17, msg18, msg19, msg20]
        
       
        
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
        mainTableview.estimatedRowHeight = 100
        
        
        
        //Start tableview scroll from the bottom up
        let indexPath:NSIndexPath = NSIndexPath(forRow: cR1!.messages.count-1, inSection: 0)
        mainTableview.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)

        
        
        
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
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return 1 //Just for now?
    }
    
    //Number of table rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cR1!.messages.count
        
    }
    
    //Populating data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:MainTableViewCell = mainTableview.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MainTableViewCell
        
        
        //Boolean to check if previous and current user are the same user
        var sameUser = false
        
        
        //Get current row
        let row = indexPath.row
        
        //Get previous row
        let prevRow = row - 1
        
        
        //Check previous and current user
        if(row > 0){
            
            if(cR1!.messages[row].user == cR1!.messages[prevRow].user){
            
                //If true then set sameUser to true
                sameUser = true
            
            }
        }
        

        //Setting the data for the cell
        
        //If same user
        if sameUser {
            
            cell.avatarImg.image = nil
            cell.usernameLabel.text = ""
            cell.timeLabel.text = "\(cR1!.messages[indexPath.row].tstamp)"
            cell.messageLabel.text = "\(cR1!.messages[indexPath.row].text)"
            
            
            
        }
        //If different user
        else{
            
            //Setting data
            cell.avatarImg.image = UIImage(named: "avatar.png")
            cell.usernameLabel.text = "\(cR1!.messages[indexPath.row].user.username)"
            cell.timeLabel.text = "\(cR1!.messages[indexPath.row].tstamp)"
            cell.messageLabel.text = "\(cR1!.messages[indexPath.row].text)"
            
        }
        
        
        return cell
        
    }
    
    
    
    //Function to get random number between 1-60 to create different timestamps
    func randomTime() -> Double {
        let r = arc4random_uniform(60) + 1
        return Double(r)
    }
    
}

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
    
    var cR1:ChatRoom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let u1:User = User(id: "1", username: "Komic", avatar: "komic.png", status: User.Status.ONLINE, timezone: NSTimeZone.systemTimeZone())
        
        let msg1:Message = Message(id: "1", text: "Message 1 from u1", tstamp: NSDate(), user: u1)
        
        let u2:User = User(id: "2", username: "Yorgos", avatar: "yorgos.png", status: User.Status.ONLINE, timezone: NSTimeZone.systemTimeZone())
        let msg2:Message = Message(id: "2", text: "Message 2 from u2", tstamp: NSDate(), user: u2)
        
        let u3:User = User(id: "3", username: "GeorgeP", avatar: "georgeP.png", status: User.Status.ONLINE, timezone: NSTimeZone.systemTimeZone())
        let msg3:Message = Message(id: "3", text: "Message 3 from u3", tstamp: NSDate(), user: u3)
        
        let uSet1:Set<User> = [u1, u2, u3]
        
        let mArray1:[Message] = [msg1, msg2, msg3]
        
        
        let c1:ChatRoom = ChatRoom(id: "1", name: "c1", type: .PUBLIC, users: uSet1, messages: mArray1)
        
        cR1 = c1
        
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
    
    
    //MARK: TableView Data
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cR1!.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:MainTableViewCell = mainTableview.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MainTableViewCell
        
        print("\(cR1?.messages[indexPath.row].text)")
        cell.messageLabel.text = "\(cR1!.messages[indexPath.row].text)"
        
        return cell
    }
    
    
    
    
    
    
    
    
}

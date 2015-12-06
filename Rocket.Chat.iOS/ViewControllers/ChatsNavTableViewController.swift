//
//  ChatsNavTableViewController.swift
//  Rocket.Chat.iOS
//
//  Created by giorgos on 8/24/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import ObjectiveDDP
import SwiftyJSON

class ChatsNavTableViewController: UITableViewController {
    
    var meteor:MeteorClient?
    var channelsData = [Room]()
    var directMessagesData = [Room]()
    var privateGroupsData = [Room]()
    var ad:AppDelegate?
    var delegate:SwitchRoomDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ad = UIApplication.sharedApplication().delegate as? AppDelegate
        self.meteor = self.ad?.meteorClient
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "roomAdded:", name: "rocketchat_subscription_added", object: nil)
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("connectedWithSessionToken") {
            
            let rocketchat_subscription = self.meteor?.collections["rocketchat_subscription"] as? M13MutableOrderedDictionary
            print(rocketchat_subscription)
            
            for var i:UInt = 0 ; i < (rocketchat_subscription?.count()) ; i++ {
                
                print(rocketchat_subscription?.objectAtIndex(i)!)
                
                let room = Room(_id: (rocketchat_subscription?.objectAtIndex(i)!["_id"])! as! String, unread: (rocketchat_subscription?.objectAtIndex(i)!["unread"])! as! Int, t: (rocketchat_subscription?.objectAtIndex(i)!["t"])! as! String, open: (rocketchat_subscription?.objectAtIndex(i)!["open"])! as! Bool, ts: (rocketchat_subscription?.objectAtIndex(i)!["ts"])! as? Double, rid: (rocketchat_subscription?.objectAtIndex(i)!["rid"])! as! String, ls: (rocketchat_subscription?.objectAtIndex(i)!["ls"])! as? Double, alert: (rocketchat_subscription?.objectAtIndex(i)!["alert"])! as! Bool, name: (rocketchat_subscription?.objectAtIndex(i)!["name"])! as! String)
                
                if (room.t == "c"){
                    self.channelsData.append(room)
                } else if (room.t == "d") {
                    self.directMessagesData.append(room)
                } else if (room.t == "p") {
                    self.privateGroupsData.append(room)
                }
                
                
            }
            
            //            print("reloading")
            //            print(self.channelsData)
            //            print(self.directMessagesData)
            //            print(self.privateGroupsData)
            self.tableView.reloadData()
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // this is to remove the bottom line 'border' on the table view cells
        tableView.separatorColor = UIColor.clearColor()
        
    }
    
    
    func roomAdded(notification: NSNotification) {
        
        let incomingRoom = JSON(notification.userInfo!)
        //        print(incomingRoom)
        
        let room = Room(_id: incomingRoom["_id"].string!, unread: incomingRoom["unread"].int!, t: incomingRoom["t"].string!, open: incomingRoom["open"].bool!, ts: incomingRoom["ts"]["$date"].double, rid: incomingRoom["rid"].string!, ls: incomingRoom["ls"]["$date"].double, alert: incomingRoom["alert"].bool!, name: incomingRoom["name"].string!)
        //        print(room.t)
        if (room.t == "c"){
            self.channelsData.append(room)
        } else if (room.t == "d") {
            self.directMessagesData.append(room)
        } else if (room.t == "p") {
            self.privateGroupsData.append(room)
        }
        //        print(self.channelsData)
        self.tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch LeftMenuHeaders(rawValue: section)!.rawValue{
            
        case LeftMenuHeaders.Channels.rawValue:
            
            if self.channelsData.count == 0 {
                return 1
            }else {
                return self.channelsData.count
            }
            
        case LeftMenuHeaders.DirectMessages.rawValue:
            
            if self.directMessagesData.count == 0 {
                return 1
            }else {
                return self.directMessagesData.count
            }
        case LeftMenuHeaders.PrivateGroups.rawValue:
            
            if self.privateGroupsData.count == 0 {
                return 1
            }else {
                return self.privateGroupsData.count
            }
            
        default:
            
            return 1
            
        }
        
        
    }
    
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return LeftMenuHeaders(rawValue: section)?.toString()
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // for some reason, the background color on ipads does not respect the storyboard value.
        cell.backgroundColor = UIColor(red: 4, green: 67, blue: 106, alpha: 0)
        
        //TODO: replace this with hex value once we merge with @kormic's branch
    }
    
}

/** The cell ids used in the UITableView in order to identify the different prototype cells. */
enum LeftMenuCellIds: String {
    case Channels = "channelsCell"
    case DirectMessages = "dmCell"
    case PrivateGroups = "groupsCell"
    case History = "historyCell"
    
    static let allValues = [Channels, DirectMessages, PrivateGroups, History]
    
}

/** The section IDs and names for the Left Menu UITableView */
enum LeftMenuHeaders: Int {
    
    case Channels = 0
    case DirectMessages
    case PrivateGroups
    case History
    
    func toString()-> String {
        switch self{
        case .Channels:
            return "Channels"
        case .DirectMessages:
            return "Direct Messages"
        case .PrivateGroups:
            return "Private Groups"
        case .History:
            return "History"
        }
        
    }
    
}


/** This protocol is used for handling events from the AccountBar. */
protocol SwitchRoomDelegate {
    func didSelectRoom(rid: String, roomName: String)
}

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
    
    var meteor:MeteorClient!
    var channelsData = [Room]()
    var directMessagesData = [Room]()
    var privateGroupsData = [Room]()
    var ad:AppDelegate!
    var delegate:SwitchRoomDelegate?
    var currentCenterVCWhenSettingsSelected:ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ad = UIApplication.sharedApplication().delegate as! AppDelegate
        self.meteor = self.ad.meteorClient
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "roomAdded:", name: "rocketchat_subscription_added", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "roomRemoved:", name: "rocketchat_subscription_removed", object: nil)

        if !NSUserDefaults.standardUserDefaults().boolForKey("connectedWithSessionToken") {
            
            let rocketchat_subscription = self.meteor.collections["rocketchat_subscription"] as! M13MutableOrderedDictionary
            print(rocketchat_subscription)
            
            for var i:UInt = 0 ; i < (rocketchat_subscription.count()) ; i++ {
                
                print(rocketchat_subscription.objectAtIndex(i)!)
                
                let room = Room(_id: (rocketchat_subscription.objectAtIndex(i)!["_id"])! as! String,
                    unread: (rocketchat_subscription.objectAtIndex(i)!["unread"])! as! Int,
                    t: (rocketchat_subscription.objectAtIndex(i)!["t"])! as! String,
                    open: (rocketchat_subscription.objectAtIndex(i)!["open"])! as! Bool,
                    ts: (rocketchat_subscription.objectAtIndex(i)!["ts"])! as? Double,
                    rid: (rocketchat_subscription.objectAtIndex(i)!["rid"])! as! String,
                    ls: (rocketchat_subscription.objectAtIndex(i)!["ls"])! as? Double,
                    alert: (rocketchat_subscription.objectAtIndex(i)!["alert"])! as! Bool,
                    name: (rocketchat_subscription.objectAtIndex(i)!["name"])! as! String)
                
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        var cell: UITableViewCell?
        
        if indexPath.section == LeftMenuHeaders.Channels.rawValue {
            
            let mycell = tableView.dequeueReusableCellWithIdentifier(LeftMenuCellIds.Channels.rawValue, forIndexPath: indexPath) as! ChannelsTableViewCell
            drawChannelsCell(mycell, currentTableView: tableView, currentIndexPath: indexPath)
            
            cell = mycell
            
        }else if indexPath.section == LeftMenuHeaders.DirectMessages.rawValue {
            
            let mycell = tableView.dequeueReusableCellWithIdentifier(LeftMenuCellIds.DirectMessages.rawValue, forIndexPath: indexPath) as! DirectMessagesTableViewCell
            drawMessagesCell(mycell, currentTableView: tableView, currentIndexPath: indexPath)
            
            cell = mycell
            
        }else if indexPath.section == LeftMenuHeaders.PrivateGroups.rawValue {
            
            let mycell = tableView.dequeueReusableCellWithIdentifier(LeftMenuCellIds.PrivateGroups.rawValue, forIndexPath: indexPath) as! PrivateGroupsTableViewCell
            drawGroupsCell(mycell, currentTableView: tableView, currentIndexPath: indexPath)
            
            cell = mycell
            
        }else if indexPath.section == LeftMenuHeaders.History.rawValue {
            
            let mycell = tableView.dequeueReusableCellWithIdentifier(LeftMenuCellIds.History.rawValue, forIndexPath: indexPath) as! HistoryTableViewCell
            drawHistoryCell(mycell, currentTableView: tableView, currentIndexPath: indexPath)
            
            cell = mycell
            
        }
        
        return cell!
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // for some reason, the background color on ipads does not respect the storyboard value.
        cell.backgroundColor = UIColor(red: 4, green: 67, blue: 106, alpha: 0)
        
        //TODO: replace this with hex value once we merge with @kormic's branch
    }
    
    func drawChannelsCell(currentCell: ChannelsTableViewCell, currentTableView: UITableView, currentIndexPath: NSIndexPath){
        
        
        if self.channelsData.count == 0 {
            currentCell.nameLabel?.text = "You haven't joined any rooms yet"
        }else {
            currentCell.statusLabel?.text = "#"
            currentCell.nameLabel?.text = "\(self.channelsData[currentIndexPath.row].name)"
        }
    }
    
    func drawMessagesCell(currentCell: DirectMessagesTableViewCell, currentTableView: UITableView, currentIndexPath: NSIndexPath){
        
        if self.directMessagesData.count == 0 {
            currentCell.nameLabel?.text = "You haven't started any conversations yet"
        }else {
            currentCell.statusLabel?.text = "@"
            currentCell.nameLabel?.text = "\(self.directMessagesData[currentIndexPath.row].name)"
        }
    }
    
    func drawGroupsCell(currentCell: PrivateGroupsTableViewCell, currentTableView: UITableView, currentIndexPath: NSIndexPath){
        
        if self.privateGroupsData.count == 0 {
            //            currentCell.nameLabel.font = UIFont.italicSystemFontOfSize(15)
            //            currentCell.nameLabel.textColor = UIColor.rocketSecondaryFontColor()
            currentCell.nameLabel?.text = "You have no private groups yet"
        }else {
            currentCell.statusLabel?.text = "g"
            currentCell.nameLabel?.text = "\(self.privateGroupsData[currentIndexPath.row].name)"
        }
        
    }
    
    func drawHistoryCell(currentCell: HistoryTableViewCell, currentTableView: UITableView, currentIndexPath: NSIndexPath){
        
        currentCell.nameLabel.hidden = true
        currentCell.userInteractionEnabled = false
        //        currentCell.nameLabel?.text = "History \(currentIndexPath.section) Row \(currentIndexPath.row)"
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let currentVC = self.ad?.centerContainer?.centerViewController as! UINavigationController

        if indexPath.section == LeftMenuHeaders.Channels.rawValue {

            checkIfWeAreOnSettingsAndSetCenterContainer(currentVC)
            
            if ((delegate) != nil){ // let delegate know about event
                print("selectroom")
                delegate!.didSelectRoom(self.channelsData[indexPath.row].rid, roomName: self.channelsData[indexPath.row].name)
            }
            
        }else if indexPath.section == LeftMenuHeaders.DirectMessages.rawValue {

            checkIfWeAreOnSettingsAndSetCenterContainer(currentVC)
            
            if ((delegate) != nil){ // let delegate know about event
                delegate!.didSelectRoom(self.directMessagesData[indexPath.row].rid, roomName: self.directMessagesData[indexPath.row].name)
            }
            
        }else if indexPath.section == LeftMenuHeaders.PrivateGroups.rawValue {

            checkIfWeAreOnSettingsAndSetCenterContainer(currentVC)
            
            if ((delegate) != nil){ // let delegate know about event
                delegate!.didSelectRoom(self.privateGroupsData[indexPath.row].rid, roomName: self.privateGroupsData[indexPath.row].name)
            }
            
        }else if indexPath.section == LeftMenuHeaders.History.rawValue {
            print("History")
        }
        
        self.ad?.centerContainer?.closeDrawerAnimated(true, completion: nil)
    }
    
    
    
    func checkIfWeAreOnSettingsAndSetCenterContainer(navController: UINavigationController) {
        
        if ((navController.viewControllers.first?.isKindOfClass(MySettingsViewController)) == true) {
            let centerNewNav = UINavigationController(rootViewController: self.currentCenterVCWhenSettingsSelected!)
            self.ad!.centerContainer?.setCenterViewController(centerNewNav, withCloseAnimation: false, completion: nil)
        }
        
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

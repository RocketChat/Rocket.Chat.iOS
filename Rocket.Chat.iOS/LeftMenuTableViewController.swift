//
//  LeftMenuTableViewController.swift
//  Rocket.Chat.iOS
//
//  Created by giorgos on 8/24/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class LeftMenuTableViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    return 1
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
    return LeftMenuHeaders(rawValue: section)?.toString()
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    // Table view cells are reused and should be dequeued using a cell identifier.

    var cell: UITableViewCell?
    
    if indexPath.section == LeftMenuHeaders.Favorites.rawValue {
      let mycell = tableView.dequeueReusableCellWithIdentifier(LeftMenuCellIds.Favorites.rawValue, forIndexPath: indexPath) as! FavoritesTableViewCell
      drawFavoritesCell(mycell, currentTableView: tableView, currentIndexPath: indexPath)
      cell = mycell
    }else if indexPath.section == LeftMenuHeaders.Channels.rawValue {
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
    }
    
    return cell!
  }
  
  
  func drawFavoritesCell(currentCell: FavoritesTableViewCell, currentTableView: UITableView, currentIndexPath: NSIndexPath){
    //TODO
    currentCell.nameLabel?.text = "Favorites \(currentIndexPath.section) Row \(currentIndexPath.row)"
  }
  
  func drawChannelsCell(currentCell: ChannelsTableViewCell, currentTableView: UITableView, currentIndexPath: NSIndexPath){
    //TODO
    currentCell.statusLabel?.text = "#"
    currentCell.nameLabel?.text = "Channels \(currentIndexPath.section) Row \(currentIndexPath.row)"
  }
  
  func drawMessagesCell(currentCell: DirectMessagesTableViewCell, currentTableView: UITableView, currentIndexPath: NSIndexPath){
    //TODO
    currentCell.statusLabel?.text = "@"
    currentCell.nameLabel?.text = "Messages \(currentIndexPath.section) Row \(currentIndexPath.row)"
  }
  
  func drawGroupsCell(currentCell: PrivateGroupsTableViewCell, currentTableView: UITableView, currentIndexPath: NSIndexPath){
    //TODO
    currentCell.statusLabel?.text = "g"
    currentCell.nameLabel?.text = "Groups \(currentIndexPath.section) Row \(currentIndexPath.row)"
  }



  
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the specified item to be editable.
  return true
  }
  */
  
  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */
  
  /*
  // Override to support rearranging the table view.
  override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
  
  }
  */
  
  /*
  // Override to support conditional rearranging of the table view.
  override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return false if you do not want the item to be re-orderable.
  return true
  }
  */
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}

/** The cell ids used in the UITableView in order to identify the different prototype cells. */
enum LeftMenuCellIds: String {
  case Favorites = "favoritesCell"
  case Channels = "channelsCell"
  case DirectMessages = "dmCell"
  case PrivateGroups = "groupsCell"
  
  static let allValues = [Favorites, Channels, DirectMessages, PrivateGroups]

}

/** The section IDs and names for the Left Menu UITableView */
enum LeftMenuHeaders: Int {
  
  case Favorites = 0
  case Channels
  case DirectMessages
  case PrivateGroups
  
  func toString()-> String {
    switch self{
    case .Favorites:
      return "Favorites"
    case .Channels:
      return "Channels"
    case .DirectMessages:
      return "Direct Messages"
    case .PrivateGroups:
      return "Private Groups"
    }
    
  }
  
}

//
//  SMSettingsViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 26/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit

class SMSettingsViewController: UITableViewController {

    var SettingCellIdentifierCommon = "SettingCellIdentifierCommon"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Настройки")
        
        var v = UIView()
        v.backgroundColor = UIColor.blackColor()
        self.tableView.backgroundView = v
        
        self.tableView.registerClass(SMSettingsCellCommon.self, forCellReuseIdentifier: SettingCellIdentifierCommon)
        
        var doneButton = UIButton()
        doneButton.setTitle(NSLocalizedString("Готово"), forState: UIControlState.Normal)
        let size = doneButton.sizeThatFits(CGSizeMake(self.view.bounds.size.width, 44))
        doneButton.frame = CGRectMake(0, 0, size.width, 44)
        doneButton.addTarget(self, action: "doneAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
    }
    
    func doneAction() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var result = 1
        return result
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = 0
        if section == 0 {
            result = 2
        }
        return result
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var tableViewCell: UITableViewCell!
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(SettingCellIdentifierCommon, forIndexPath: indexPath) as! SMSettingsCellCommon
            if indexPath.row == 0 {
                cell.textLabel?.text = NSLocalizedString("Аккаунт")
                cell.detailTextLabel?.text = SMStateManager.sharedInstance.userLogin
            } else if indexPath.row == 1 {
                cell.textLabel?.text = NSLocalizedString("Подписка до")
                var f = NSDateFormatter()
                f.dateStyle = NSDateFormatterStyle.ShortStyle
                if let tt = SMStateManager.sharedInstance.tokenTill {
                    cell.detailTextLabel?.text = f.stringFromDate(tt)
                }
            }
            tableViewCell = cell
        }

        return tableViewCell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
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
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

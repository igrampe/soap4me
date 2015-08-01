//
//  SMSettingsViewController.swift
//  soap4me
//
//  Created by Sema Belokovsky on 26/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import MessageUI

class SMSettingsViewController: UITableViewController, UIActionSheetDelegate, MFMailComposeViewControllerDelegate {

    var SettingCellIdentifierCommon = "SettingCellIdentifierCommon"
    var SettingCellIdentifierAction = "SettingCellIdentifierAction"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Настройки")
        
        var v = UIView()
        v.backgroundColor = UIColor.blackColor()
        self.tableView.backgroundView = v
        
        self.tableView.registerClass(SMSettingsCellCommon.self, forCellReuseIdentifier: SettingCellIdentifierCommon)
        self.tableView.registerClass(SMSettingsCellAction.self, forCellReuseIdentifier: SettingCellIdentifierAction)
        
        var doneButton = UIButton()
        doneButton.setTitle(NSLocalizedString("Готово"), forState: UIControlState.Normal)
        let size = doneButton.sizeThatFits(CGSizeMake(self.view.bounds.size.width, 44))
        doneButton.frame = CGRectMake(0, 0, size.width, 44)
        doneButton.addTarget(self, action: "doneAction", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)        
    }
    
    func reloadUI() {
        self.tableView.reloadData()
    }
    
    func doneAction() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func showFeedback() {
        YMMYandexMetrica.reportEvent("APP.ACTION.FEEDBACK", onFailure: nil)
        let toRecipents = ["soap4me@app-plus.com"]
        var ctl = MFMailComposeViewController()
        ctl.mailComposeDelegate = self
        var s = String(format: "[soap4me][%@][ios][%@]", SMStateManager.sharedInstance.currentVersion, UIDevice.currentDevice().systemVersion)
        ctl.setSubject(s)
        ctl.setToRecipients(toRecipents)
        self.navigationController?.presentViewController(ctl, animated: true, completion: nil)
    }
    
    func showRate() {
        YMMYandexMetrica.reportEvent("APP.ACTION.RATE", onFailure: nil)
        //TODO go to app store
    }
    
    func logoutAction() {
        YMMYandexMetrica.reportEvent("APP.ACTION.SIGNOUT", onFailure: nil)
        SMStateManager.sharedInstance.logout()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var result = 3
        return result
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = 0
        if section == 0 {
            result = 3
        } else if section == 1 {
            result = 3
        } else if section == 2 {
            result = 3
        }
        return result
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var tableViewCell: UITableViewCell!
        
        if indexPath.section == 0 {
            if indexPath.row != 2 {
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
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(SettingCellIdentifierAction, forIndexPath: indexPath) as! SMSettingsCellAction
                cell.textLabel?.text = NSLocalizedString("Выйти")
                tableViewCell = cell
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(SettingCellIdentifierCommon, forIndexPath: indexPath) as! SMSettingsCellCommon
            var title = ""
            var value = ""
            
            if indexPath.row == 0 {
                title = NSLocalizedString("Качество видео")
                if SMStateManager.sharedInstance.preferedQuality == SMEpisodeQuality.SD {
                    value = "SD"
                } else if SMStateManager.sharedInstance.preferedQuality == SMEpisodeQuality.HD {
                    value = "HD"
                }
            } else if indexPath.row == 1 {
                title = NSLocalizedString("Перевод")
                if SMStateManager.sharedInstance.preferedTranslation == SMEpisodeTranslateType.Subs {
                    value = NSLocalizedString("Субтитры")
                } else if SMStateManager.sharedInstance.preferedTranslation == SMEpisodeTranslateType.Voice {
                    value = NSLocalizedString("Озвучка")
                }
            } else if indexPath.row == 2 {
                title = NSLocalizedString("Сортировка")
                if SMStateManager.sharedInstance.catalogSorting == SMSorting.Ascending {
                    value = NSLocalizedString("Прямая")
                } else {
                    value = NSLocalizedString("Обратная")
                }
            }
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = value
            tableViewCell = cell
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(SettingCellIdentifierCommon, forIndexPath: indexPath) as! SMSettingsCellCommon
                cell.textLabel?.text = NSLocalizedString("Версия приложения")
                if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
                    cell.detailTextLabel?.text = version
                }
                tableViewCell = cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(SettingCellIdentifierAction, forIndexPath: indexPath) as! SMSettingsCellAction
                var title = ""
                switch indexPath.row {
                    case 1: title = NSLocalizedString("Написать разработчику")
                    case 2: title = NSLocalizedString("Оценить приложение")
                    default: break
                }
                cell.textLabel?.text = title
                tableViewCell = cell
            }
        }

        return tableViewCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                self.logoutAction()
            }
        } else if indexPath.section == 1 {
            var actionSheet = UIActionSheet()
            actionSheet.delegate = self
            actionSheet.tag = indexPath.row
            var title = ""
            var items = [String]()
            if indexPath.row == 0 {
                items.append("HD")
                items.append("SD")
                title = NSLocalizedString("Качество видео")
            } else if indexPath.row == 1 {
                items.append(NSLocalizedString("Озвучка"))
                items.append(NSLocalizedString("Субтитры"))
                title = NSLocalizedString("Перевод")
            } else if indexPath.row == 2 {
                items.append(NSLocalizedString("Прямая"))
                items.append(NSLocalizedString("Обратная"))
                title = NSLocalizedString("Сортировка")
            }
            actionSheet.title = title
            for item in items {
                actionSheet.addButtonWithTitle(item)
            }
            actionSheet.addButtonWithTitle(NSLocalizedString("Отмена"))
            actionSheet.cancelButtonIndex = items.count
            actionSheet.showInView(self.view)
        } else if indexPath.section == 2 {
            switch indexPath.row {
                case 1: self.showFeedback()
                case 2: self.showRate()
                default: break
            }
        }
    }

    //MARK: UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if actionSheet.tag == 0 {
            var value: SMEpisodeQuality?
            if buttonIndex == 0 {
                value = SMEpisodeQuality.HD
            } else if buttonIndex == 1 {
                value = SMEpisodeQuality.SD
            }
            if let v = value {
                SMStateManager.sharedInstance.preferedQuality = v
            }
        } else if actionSheet.tag == 1 {
            var value: SMEpisodeTranslateType?
            if buttonIndex == 0 {
                value = SMEpisodeTranslateType.Voice
            } else if buttonIndex == 1 {
                value = SMEpisodeTranslateType.Subs
            }
            if let v = value {
                SMStateManager.sharedInstance.preferedTranslation = v
            }
        } else if actionSheet.tag == 2 {
            var value: SMSorting?
            if buttonIndex == 0 {
                value = SMSorting.Ascending
            } else if buttonIndex == 1 {
                value = SMSorting.Descending
            }
            if let v = value {
                SMStateManager.sharedInstance.catalogSorting = v
            }
        }
        self.reloadUI()
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        var str = ""
        
        switch result.value {
            case MFMailComposeResultCancelled.value: str = "CANCELLED"
            case MFMailComposeResultSaved.value: str = "SAVED"
            case MFMailComposeResultSent.value: str = "SENT"
            case MFMailComposeResultFailed.value: str = "FAILED"
            default: break
        }
        
        str = "APP.FEEDBACK."+str
        
        YMMYandexMetrica.reportEvent(str, onFailure: nil)
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

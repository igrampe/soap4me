//
//  SMCatalogNavigationController.swift
//  soap4me
//
//  Created by Semyon Belokovsky on 21/09/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit

class SMCatalogNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showSerialVCWithSid(sid: Int)
    {
        let c: SMSerialViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SerialVC") as! SMSerialViewController
        c.sid = sid
        self.pushViewController(c, animated: false)
    }
    
}

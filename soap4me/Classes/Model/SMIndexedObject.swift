//
//  SMIndexedObject.swift
//  soap4me
//
//  Created by Semyon Belokovsky on 21/09/15.
//  Copyright © 2015 App Plus. All rights reserved.
//

import UIKit

protocol SMIndexedProtocol
{
    func indexedObject() -> SMIndexedObject
}

class SMIndexedObject
{
    var title: String?
    var desc: String?
    var identifier: String! = ""
    var imageURL: String?
}

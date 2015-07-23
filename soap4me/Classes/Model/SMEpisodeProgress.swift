//
//  SMEpisodeProgress.swift
//  soap4me
//
//  Created by Sema Belokovsky on 23/07/15.
//  Copyright (c) 2015 App Plus. All rights reserved.
//

import UIKit
import Realm

class SMEpisodeProgress: RLMObject {
    dynamic var progress: Double = 0
    dynamic var season_id: Int = 0
    dynamic var episode_number: Int = 0
}

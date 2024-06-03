//
//  Plant.swift
//  PlantScape
//
//  Created by Daud on 03/06/24.
//

import Foundation
import SwiftData

@Model
class Plant: Hashable {
    var name: String
    var desc: String
    var growingTips: String
    var image: String
    
    init(name: String, desc: String, growingTips: String, image: String) {
        self.name = name
        self.desc = desc
        self.growingTips = growingTips
        self.image = image
    }
}

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
    var id = UUID()
    var identifier: String
    var name: String
    var desc: String
    var growingTips: GrowingTips
    var image: String
    var location: String
    var modelUrl: URL?
    
    init(id: UUID = UUID(), identifier: String, name: String, desc: String, growingTips: GrowingTips, image: String, location: String, modelUrl: URL? = nil) {
        self.id = id
        self.identifier = identifier
        self.name = name
        self.desc = desc
        self.growingTips = growingTips
        self.image = image
        self.location = location
        self.modelUrl = modelUrl
    }
}

struct GrowingTips: Codable {
    var sun: String
    var water: String
}

//
//  Router.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 09/06/24.
//

import SwiftUI

class Router : ObservableObject {
    @Published var path = [NavigationDestination]()
    
    func reset() {
        path.removeAll()
    }
}

//
//  DetectionResultViewModel.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 05/06/24.
//

import Foundation
import SwiftUI

enum ScannedItemType: Identifiable {
    case produce(Prediction)
    
    var id: String {
        switch self {
        case .produce(let prediction):
            return prediction.identifier
        }
    }
}

final class DetectionResultViewModel: ObservableObject {
    @Published var isShowingPlantdexView = false
    @Published var scannedItemView: ScannedItemType?
    @Published var scannedPlant: ScannedItemType?
    @Published var plants: [Plant] = []

    private var plantDictionary: [String: Plant] = [:]
    
    init() {
        self.plants = plantDataset
        
        for plant in plantDataset {
            plantDictionary[plant.identifier] = plant
        }
    }
    
    func plant(for identifier: String) -> Plant? {
        return plantDictionary[identifier]
    }
}

extension DetectionResultViewModel: ObjectScannerDelegate {
    func didDetectObject(prediction: Prediction?) {
        guard let prediction else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.scannedItemView = .produce(prediction)
            self.scannedPlant = .produce(prediction)
        }
    }
}

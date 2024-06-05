//
//  ObjectScannerDelegate.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 05/06/24.
//

import Foundation

protocol ObjectScannerDelegate: AnyObject {
    func didDetectObject(prediction: Prediction?)
}

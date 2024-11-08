//
//  ARViewControllerRepresentable.swift
//  PlantScape
//
//  Created by Eldenabih Tavirazin Lutvie on 05/06/24.
//

import SwiftUI
import ARKit
import RealityKit

struct ARViewControllerRepresentable: UIViewControllerRepresentable {
    var plantModelUrl: String
    
    func makeUIViewController(context: Context) -> ARViewController {
        let arViewController = ARViewController()
        arViewController.plantModelUrl = plantModelUrl
        return arViewController
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        // No need to update for now
    }
}

class ARViewController: UIViewController, ARSessionDelegate, ARCoachingOverlayViewDelegate {
    var arView: ARView!
    var coachingOverlay = ARCoachingOverlayView()
    var selectedEntity: ModelEntity?
    var initialScale: SIMD3<Float>?
    var plantModelUrl: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView = ARView(frame: self.view.frame)
        self.view.addSubview(arView)
        
        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
        arView.session.delegate = self
        
        // Set up coaching overlay
        setupCoachingOverlay()
        
        // Add gesture recognizers
        addGestureRecognizers()
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
    }
    
    func setupCoachingOverlay() {
        // Set up coaching view
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = self
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        arView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: arView.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: arView.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: arView.heightAnchor)
        ])
        
        setActivatesAutomatically()
        setGoal()
    }
    
    func setActivatesAutomatically() {
        coachingOverlay.activatesAutomatically = true
    }
    
    func setGoal() {
        coachingOverlay.goal = .horizontalPlane
    }
    
    // ARCoachingOverlayViewDelegate methods
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        // Handle UI changes when coaching overlay activates
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        // Handle UI changes when coaching overlay deactivates
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        restartExperience()
    }
    
    func restartExperience() {
        // Reset the AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func addGestureRecognizers() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        arView.addGestureRecognizer(panGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        arView.addGestureRecognizer(rotationGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .existingPlaneInfinite, alignment: .horizontal)
        
        if let firstResult = results.first {
            placeObject(at: firstResult)
        } else if let entity = arView.entity(at: location) as? ModelEntity {
            selectedEntity = entity
            initialScale = entity.scale
        }
    }
    
    func placeObject(at raycastResult: ARRaycastResult) {
        let anchor = ARAnchor(name: "objectAnchor", transform: raycastResult.worldTransform)
        arView.session.add(anchor: anchor)
        
        let name = plantModelUrl.components(separatedBy: "Documents/").last ?? ""
        
        // Load models from local storage
        guard let plantURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(name)") else {

            print("Failed to find USDZ files in local storage.")
            return
        }
        let cardname = plantModelUrl.components(separatedBy: "Models/").last ?? ""
        print("ini woii", plantURL)
        let cardEntity = try! ModelEntity.loadModel(named: "plantscape-\(cardname)")
        
        let plantEntity = try! ModelEntity.load(contentsOf: plantURL)
        
        // Generate collision shapes
        plantEntity.generateCollisionShapes(recursive: true)
        cardEntity.generateCollisionShapes(recursive: true)
        
        // Position the cardEntity above the plantEntity
        let plantBounds = plantEntity.visualBounds(relativeTo: nil)
        let cardBounds = cardEntity.visualBounds(relativeTo: nil)
        
        let cardHeight = cardBounds.extents.y
        let plantHeight = plantBounds.extents.y
        
        cardEntity.position = SIMD3(x: 0, y: plantHeight + cardHeight, z: 0)
        
        // Create a parent entity to group both models
        let parentEntity = ModelEntity()
        parentEntity.addChild(plantEntity)
        parentEntity.addChild(cardEntity)
        
        // Create an anchor entity and add the parent entity to it
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(parentEntity)
        
        arView.scene.addAnchor(anchorEntity)
        
        selectedEntity = parentEntity
        initialScale = parentEntity.scale
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let entity = selectedEntity else { return }
        
        let location = sender.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .existingPlaneInfinite, alignment: .horizontal)
        
        if let firstResult = results.first {
            let newPosition = simd_make_float3(firstResult.worldTransform.columns.3)
            entity.position = newPosition
        }
    }
    
    @objc func handleRotation(_ sender: UIRotationGestureRecognizer) {
        guard let entity = selectedEntity else { return }
        
        if sender.state == .changed {
            entity.transform.rotation *= simd_quatf(angle: Float(sender.rotation), axis: [0, 1, 0])
            sender.rotation = 0
        }
    }
    
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        guard let entity = selectedEntity, let initialScale = initialScale else { return }
        
        if sender.state == .changed || sender.state == .ended {
            let scale = Float(sender.scale)
            entity.scale = initialScale * scale
        }
    }
}

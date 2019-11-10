//
//  SandboxScene.swift
//  Circles
//
//  Created by Oliver Still on 07/11/2019.
//  Copyright © 2019 Oliver Still. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import CoreMotion

class SandboxScene: SKScene, SKPhysicsContactDelegate {
    
    // Define application managers.
    var motionManager:          CMMotionManager!
    var audioManager:           AudioManager!
    
    // Define scene varibles.
    var orbArray:               [Orb]!
    var orbProperties:          (position: CGPoint, size: CGSize)!
    var orbGraphicArray:        [SKSpriteNode]!
    var orbSelected:            String!
    
    override func didMove(to view: SKView) {
        
        // Set the scale mode to scale to fit the SKView.
        self.scaleMode = .resizeFill
        
        // Setup the physics properties and user interaction.
        self.physicsWorld.contactDelegate = self
        self.isUserInteractionEnabled = true
        
        // Setup audio engine.
        audioManager = AudioManager()
        
        // Setup motion manager.
        motionManager = CMMotionManager()
        
        motionManager.startAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) {
            (data, error) in
            self.physicsWorld.gravity = CGVector(dx: CGFloat((data?.acceleration.x)!) * 2, dy: CGFloat((data?.acceleration.y)!) * 2)
        }
        
        // Initalise scene varibles.
        orbArray = [Orb]()
        orbGraphicArray = [SKSpriteNode]()
        orbProperties = (CGPoint(x: 0.0, y: 0.0), CGSize(width: 0.0, height: 0.0))
        orbSelected = "blue"
        
        // Add pinch gesture.
        let pinch = UIPinchGestureRecognizer(target: scene, action: #selector(pinchRecognised(pinch:)))
        view.addGestureRecognizer(pinch)
        
        // Add double tap gesture.
//        let doubleTap = UITapGestureRecognizer(target: scene, action: #selector(tapRecognised(tap:)))
//        view.addGestureRecognizer(doubleTap)
        
        print("[SandboxScene.swift] Sandbox Scene Active")
    }
    
    @objc func pinchRecognised(pinch: UIPinchGestureRecognizer) {
        guard pinch.view != nil else { return }
        
        // Reset orb graphic array.
        self.removeChildren(in: orbGraphicArray)
        orbGraphicArray.removeAll()
        
        // If a pinch gesture is detected or changed...
        if pinch.state == .began || pinch.state == .changed {
            
            // ... selected the respective orb graphic to overlay dependant on the orb colour selected.
            var orbGraphic: SKSpriteNode!
            
            if orbSelected == "blue" {
                orbGraphic = SKSpriteNode(imageNamed: "blueOrbSprite")
            }
            else if orbSelected == "purple" {
                orbGraphic = SKSpriteNode(imageNamed: "purpleOrbSprite")
            }
            else if orbSelected == "red" {
                orbGraphic = SKSpriteNode(imageNamed: "redOrbSprite")
            }
            else {
                // Default orb sprite selection catch.
                orbGraphic = SKSpriteNode(imageNamed: "blueOrbSprite")
            }
            
            // If two touch points are detected...
            if pinch.numberOfTouches == 2 {
                // ... update the position of the graphic to the middle point between the two touch coordinates.
                orbProperties.position.x = (pinch.location(ofTouch: 0, in: pinch.view).x + pinch.location(ofTouch: 1, in: pinch.view).x) / 2
                orbProperties.position.y = 0.0 - (pinch.location(ofTouch: 0, in: pinch.view).y + pinch.location(ofTouch: 1, in: pinch.view).y) / 2
            }
            else {
                // ... else cancel the orb.
                //pinch.state = .cancelled
            }
            
            // Scale and normalise the orb graphic size from 80 to 400.
            var orbSize = 100 * pinch.scale
            
            if orbSize > 400 {
                orbSize = 400
            }
            else if orbSize < 80 {
                orbSize = 80
            }
            orbProperties.size = CGSize(width: orbSize, height: orbSize)
            
            // Commit the orb graphic properties to the real visable graphic.
            orbGraphic.position = orbProperties.position
            orbGraphic.size = orbProperties.size
            
            // Add the real graphic to the graphic array and the scene.
            // (This will later be removed if the gesture is updated.)
            orbGraphicArray.append(orbGraphic)
            self.addChild(orbGraphicArray[orbGraphicArray.count - 1])
        }
        
        if pinch.state == .ended {
            
            // Create a new dynamic orb with the position and size of the temporary orb graphic.
            var newOrb: Orb!
            
            if orbSelected == "blue" {
                newOrb = BlueOrb(position: orbProperties.position, size: orbProperties.size)
            }
            else if orbSelected == "purple" {
                newOrb = PurpleOrb(position: orbProperties.position, size: orbProperties.size)
            }
            else if orbSelected == "red" {
                newOrb = RedOrb(position: orbProperties.position, size: orbProperties.size)
            }
            else {
                // Default orb initalisation catch.
                newOrb = Orb(position: orbProperties.position, size: orbProperties.size)
            }
            
            // Add new dynamic orb to scene and the orb array.
            orbArray.append(newOrb)
            self.addChild(orbArray[orbArray.count - 1])
            
            // Add new orb's synth to the audio mixer.
            newOrb.orbSynth.connectOrbSynthOutput(to: audioManager.mixer)
            
            print("[GameScene.swift] Orb Spawned at x: \(Int(newOrb.position.x)), y: \(Int(newOrb.position.y)) of size: \(Int(newOrb.size.width)) and mass: \(Int(newOrb.physicsBody!.mass))")
        }
        
        if pinch.state == .cancelled {
            print("[GameScene.swift] Orb cancelled.")
        }
    }
    
}

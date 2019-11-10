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
    
    // Define tutorial varibles.
    var tutorialOverlay:        SKNode!
    var tutorialActive:         Bool!
    var tutorialState:          Int!
    
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
        
        if tutorialActive {
            startTutorialSequence()
        }
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
            
            print("[SandboxScene.swift] Orb Spawned at x: \(Int(newOrb.position.x)), y: \(Int(newOrb.position.y)) of size: \(Int(newOrb.size.width)) and mass: \(Int(newOrb.physicsBody!.mass))")
        }
        
        if pinch.state == .cancelled {
            print("[SandboxScene.swift] Orb cancelled.")
        }
    }


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * TUTORIAL FUNCTIONS  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    public func setTutorialActive(bool: Bool) {
        tutorialActive = bool
    }
    
    private func startTutorialSequence() {
        
        tutorialOverlay = self.childNode(withName: "tutorialSceneNode")
        
        // Get 'tutorialGuideLabel' SKLabelNode from tutorialSceneNode.
        if let label = tutorialOverlay.childNode(withName: "tutorialGuideLabel") as? SKLabelNode {
            // Fade in and pulse label.
            label.alpha = 0.0
            label.run(SKAction.repeatForever(SKAction.init(named: "PulseScale125", duration: 2)!))
            label.run(SKAction.sequence([SKAction.wait(forDuration: 1),
                                         SKAction.fadeIn(withDuration: 3)]))
        }
        
        // Get 'menuTutorialLabel' SKLabelNode from tutorialSceneNode.
        if let label = tutorialOverlay.childNode(withName: "tutorialSkipLabel") as? SKLabelNode {
            // Fade in and pulse label.
            label.alpha = 0.0
            label.run(SKAction.repeatForever(SKAction.init(named: "PulseScale105", duration: 3)!))
            label.run(SKAction.sequence([SKAction.wait(forDuration: 1),
                                         SKAction.fadeIn(withDuration: 3)]))
        }
        
        
//        if let label = tutorialOverlay.childNode(withName: "tutorialInfoLabel") as? SKLabelNode {
//            tutorialInfoLabel = NSMutableAttributedString(string: "WELCOME TO CIRCLES!  THE INTERACTIVE AUDIO SOUNDSCAPE.", attributes: label.attributedText?.attributes(at: 0, effectiveRange: nil))
//
//            print("\(String(describing: label.attributedText?.attributes(at: 0, effectiveRange: nil)))")
//            label.attributedText = tutorialInfoLabel
//            //                    tutorialInfoLabel = label.attributedText as? NSMutableAttributedString
//        }
        

        // Set tutorial state to 0 and initalise the sequence.
        tutorialState = 0
        tutorialSequence()
    }
    
    private func tutorialPromptToggle() {
        if let tutorialOverlay = self.childNode(withName: "tutorialSceneNode") {
            
            if tutorialOverlay.alpha == 0 {
                // Fade in overlay.
                tutorialOverlay.run(SKAction.fadeIn(withDuration: 1))
                tutorialOverlay.isUserInteractionEnabled = true
            }
            else if tutorialOverlay.alpha == 1 {
                // Fade out overlay.
                tutorialOverlay.run(SKAction.fadeOut(withDuration: 1))
                tutorialOverlay.isUserInteractionEnabled = false
            }
        }
    }
    
    private func tutorialSequence() {
        
        print("[SandboxScene.swift] Tutorial State \(tutorialState!).")
        
        switch tutorialState! {
            case 0: // Welcome screen.
                tutorialPromptToggle()
//            case 1:
//                tutorialInfoLabel.mutableString.setString("NEW STRING")
            default:
                break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Guard to ignore all other touches if multiple touches are registered.
        guard let touch = touches.first else { return }
        
        // Find the location and nodes of the first touch.
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        // Within the touchedNodes array, ...
        for node in touchedNodes {
            //... if 'tutorialSkipLabel' is touched, ...
            if node.name == "tutorialSkipLabel" {
                // ... reset tutorial sequence and fade tutorial overlay out.
                tutorialState = 99
                tutorialPromptToggle()
            }
            // Else, if 'tutorialSceneNode' is touched, ...
            else if node.name == "tutorialSceneNode" {
                // ... adavance tutorial sequence.
                tutorialState += 1
            }
        }
        tutorialSequence()
    }
}

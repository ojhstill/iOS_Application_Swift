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
    
    /* CLASS VARIABLES */
    
    // Define application managers.
    public var motionManager:               CMMotionManager!
    public var audioManager:                AudioManager!
    
    // Define SandboxScene varibles.
    private var sandboxScene:               SKNode!
    private var orbSelected:                String!
    private var orbProperties:              (position: CGPoint, size: CGSize)!
    private var orbGraphicArray:            [SKSpriteNode]!
    private var orbArray:                   [Orb]!
    
    // Define TutorialScene varibles.
    private var tutorialActive:             Bool!
    private var tutorialOverlay:            SKNode!
    private var tutorialInfoLabel:          SKLabelNode!
    private var tutorialNextInfoLabel:      NSMutableAttributedString!
    private var tutorialSequenceState:      Int!
    
    /* INIT() */
    
    override func didMove(to view: SKView) {
        
        // Set the scale mode to scale to fit the SKView.
        self.scaleMode = .resizeFill
        
        // Setup the physics properties and user interaction.
        self.physicsWorld.contactDelegate = self
        self.isUserInteractionEnabled = true
        
        // Setup audio manager (and AudioKit).
        audioManager = AudioManager()
        
        // Setup motion manager.
        motionManager = CMMotionManager()
        
        motionManager.startAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) {
            (data, error) in
            self.physicsWorld.gravity = CGVector(dx: CGFloat((data?.acceleration.x)!) * 2, dy: CGFloat((data?.acceleration.y)!) * 2)
        }
        
        // Initalise class varibles.
        sandboxScene = self.childNode(withName: "sandboxSceneNode")
        
        orbArray = [Orb]()
        orbGraphicArray = [SKSpriteNode]()
        orbProperties = (CGPoint(x: 0.0, y: 0.0), CGSize(width: 0.0, height: 0.0))
        orbSelected = "blue"
        
        // Create BlueOrb in the centre of the scene to transition from MenuScene.
        let startingOrb = BlueOrb(position: CGPoint(x: 380, y: -500), size: CGSize(width: 300, height: 300))
        
        // Setup starting orb.
        orbArray.append(startingOrb)
        sandboxScene.addChild(orbArray[orbArray.count - 1])
        startingOrb.orbSynth.connectOrbSynthOutput(to: audioManager.mixer)
        
        // Add pinch gesture to view to trigger pinchRecognised() function.
        let pinch = UIPinchGestureRecognizer(target: scene, action: #selector(pinchRecognised(pinch:)))
        view.addGestureRecognizer(pinch)
        
        // Add double tap gesture.
//        let doubleTap = UITapGestureRecognizer(target: scene, action: #selector(tapRecognised(tap:)))
//        view.addGestureRecognizer(doubleTap)
        
        print("[SandboxScene.swift] Sandbox scene active.")
        
        // If the tutorial is set 'true', start the tutorial sequence.
        if tutorialActive { startTutorialSequence() }
    }
    
    @objc func pinchRecognised(pinch: UIPinchGestureRecognizer) {
        guard pinch.view != nil else { return }
        
        // Reset orb graphic array.
        sandboxScene.removeChildren(in: orbGraphicArray)
        orbGraphicArray.removeAll()
        
        // If a pinch gesture is detected or changed...
        if pinch.state == .began || pinch.state == .changed {
            
            // ... and if two touch points are detected...
            if pinch.numberOfTouches == 2 {
                // ... update the position of the graphic to the middle point between the two touch coordinates.
                orbProperties.position.x = (pinch.location(ofTouch: 0, in: pinch.view).x + pinch.location(ofTouch: 1, in: pinch.view).x) / 2
                orbProperties.position.y = 0 - (pinch.location(ofTouch: 0, in: pinch.view).y + pinch.location(ofTouch: 1, in: pinch.view).y) / 2
            }
            else {
                // ... (else cancel the orb).
                pinch.state = .cancelled
            }
            
            // ... selected the respective orb graphic to overlay dependant on the orb colour selected.
            var orbGraphic: SKSpriteNode!
            
            switch orbSelected {
                case "blue": // Blue orb sprite selected.
                    orbGraphic = SKSpriteNode(imageNamed: "blueOrbSprite")
                case "purple": // Purple orb sprite selected.
                    orbGraphic = SKSpriteNode(imageNamed: "purpleOrbSprite")
                case "red": // Red orb sprite selected.
                    orbGraphic = SKSpriteNode(imageNamed: "redOrbSprite")
                default: // Default orb sprite selection catch.
                    print("[SandboxScene.swift] Error: 'orbSelected' variable not recognised.")
                    break
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
            sandboxScene.addChild(orbGraphicArray[orbGraphicArray.count - 1])
        }
        
        if pinch.state == .ended {
            
            // Create a new dynamic orb with the position and size of the temporary orb graphic.
            var newOrb: Orb!
            
            switch orbSelected {
            case "blue": // Blue orb sprite selected.
                newOrb = BlueOrb(position: orbProperties.position, size: orbProperties.size)
            case "purple": // Purple orb sprite selected.
                newOrb = PurpleOrb(position: orbProperties.position, size: orbProperties.size)
            case "red": // Red orb sprite selected.
                newOrb = RedOrb(position: orbProperties.position, size: orbProperties.size)
            default: // Default orb initalisation catch.
                print("[SandboxScene.swift] Error: 'orbSelected' variable not recognised.")
                break
            }
            
            // Add new dynamic orb to scene and the orb array.
            orbArray.append(newOrb)
            sandboxScene.addChild(orbArray[orbArray.count - 1])
            
            // Add new orb's synth to the audio mixer.
            newOrb.orbSynth.connectOrbSynthOutput(to: audioManager.mixer)
            
            print("[SandboxScene.swift] Orb spawned at x: \(Int(newOrb.position.x)), y: \(Int(newOrb.position.y)) of size: \(Int(newOrb.size.width)) and mass: \(Int(newOrb.physicsBody!.mass))")
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
        tutorialInfoLabel = tutorialOverlay.childNode(withName: "tutorialInfoLabel") as? SKLabelNode
        
        
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
 
        
        tutorialNextInfoLabel = NSMutableAttributedString(string: tutorialInfoLabel.attributedText!.string, attributes: tutorialInfoLabel.attributedText!.attributes(at: 0, effectiveRange: nil))
            
        tutorialInfoLabel.attributedText = tutorialNextInfoLabel
        
        tutorialOverlay.alpha = 0.0
        
        // Initalise the tutorial sequence.
        tutorialSequenceState = 0
        tutorialSequence()
    }
    
    private func tutorialPromptToggle() {
        
        // If the tutorial overlay is off, ...
        if tutorialOverlay.alpha == 0 {
            // ... fade in overlay.
            tutorialOverlay.run(SKAction.fadeIn(withDuration: 1))
        }
        // Else, if the tutorial overlay is on, ...
        else if tutorialOverlay.alpha == 1 {
            // ... fade out overlay.
            tutorialOverlay.run(SKAction.fadeOut(withDuration: 1))
        }
    }
    
    private func tutorialSequence() {
        
        print("[SandboxScene.swift] Tutorial state \(tutorialSequenceState!).")
        
        // Switch-Case to keep track of the tutorial sequenece, including triggering the overlay and setting the text.
        switch tutorialSequenceState! {
            case 0: // Overlay with welcome text.
                tutorialPromptToggle()
            case 1:
                tutorialNextInfoLabel.mutableString.setString("TEST")
                tutorialInfoLabel.attributedText = tutorialNextInfoLabel
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
        
        for node in touchedNodes {
            if node.name == "tutorialSceneNode" {
                let location = touch.location(in: node)
                let tutorialNodes = nodes(at: location)
                
                for node in tutorialNodes {
                    if node.name == "tutorialSkipLabel" {
                        // ... reset tutorial sequence and fade out tutorial overlay.
                        tutorialSequenceState = 0
                        tutorialOverlay.run(SKAction.fadeOut(withDuration: 1))
                        return
                    }
                }
                
                tutorialSequenceState += 1
                tutorialSequence()
                break
            }
        }
    }
}

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
    public  var orbArray:                   [Orb]!
    public  var hasOrbCollided:              Bool!
    
    // Define TutorialScene varibles.
    private var tutorialIsActive:           Bool!
    private var tutorialScene:              TutorialScene!
    
    
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
        hasOrbCollided = false
        
        // Create BlueOrb in the centre of the scene to transition from MenuScene.
        let startingOrb = BlueOrb(position: CGPoint(x: frame.width / 2, y: 0 - (frame.height / 2)), size: CGSize(width: 300, height: 300))
        
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
        if tutorialIsActive { tutorialScene = TutorialScene(sandbox: self) }
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
    
    @objc func tapRecognised(tap: UITapGestureRecognizer) {
        guard tap.view != nil else { return }
        tap.numberOfTapsRequired = 2
        
        // After the second tap in the same area...
        if tap.state == .ended {
            print("Double Tap")
            
            // Index through each orb within the orb array.
            var i = 0
            for orb in orbArray {
                // If the position on the gesture is inside the area of one of the orbs...
                if sqrt(pow(tap.location(in: tap.view).x - orb.position.x, 2) + pow((0.0 - tap.location(in: tap.view).y) - orb.position.y, 2)) < (orb.size.width / 2) {
                    // ... remove the orb within the array.
                    orbArray.remove(at: i)
                    
                    // Disconnect from audio manager and scene.
                    orb.orbSynth.disconnectOrbSynthOutput()
                    orb.removeFromParent()
                    orb.removeAllActions()
                    
                    print("[GameScene.swift] Orb removed - Array count at \(orbArray.count)")
                    
                    // Stop cycling through array.
                    break
                }
                i += 1
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA.node! as! SKSpriteNode
        let bodyB = contact.bodyB.node! as! SKSpriteNode
        
        // Scale impulse of collision to around the velocity range.
        var velocity = Int(contact.collisionImpulse / 30000)
        
        // Normalise velocity value for UInt8 MIDI data.
        if velocity > 127 {
            velocity = 127
        }
        
        // Trigger soundscape if collision inpulse is significant enough.
        // (Prevents notes playing when contact bodies are rolling.)
        if velocity >= 10 {
            
            print("Collision between \(bodyA.name!) and \(bodyB.name!)")
            
            // If a BLUE and BLUE orb collide - SOFT REVERB
            if bodyA.name == "blueOrb" && bodyB.name == "blueOrb" {
                
                hasOrbCollided = true
                
                print("[GaneScene.swift] Collision of impulse: \(Int(contact.collisionImpulse))")
                
                if let orb = bodyA as? Orb {
                    orb.orbSynth.reverb.dryWetMix = 0.9
                    orb.orbSynth.delay.dryWetMix = 0.0
                    orb.orbSynth.tremolo.depth = 0.1
                    orb.orbSynth.tremolo.frequency = 2.0
                    orb.play(velocity: UInt8(velocity))
                }
            }
                // Else if a RED and BLUE orb collide - SOFT DELAY
            else if (bodyA.name == "redOrb" && bodyB.name == "blueOrb") || (bodyA.name == "blueOrb" && bodyB.name == "redOrb") {
                
                hasOrbCollided = true
                
                print("[GaneScene.swift] Collision of impulse: \(Int(contact.collisionImpulse))")
                
                //if Int.random(in: 0 ... 1) == 0 {
                if let orb = bodyA as? Orb {
                    orb.orbSynth.reverb.dryWetMix = 0.5
                    orb.orbSynth.delay.dryWetMix = 1.0
                    orb.orbSynth.tremolo.depth = 0.7
                    orb.orbSynth.tremolo.frequency = 4.0
                    orb.play(velocity: UInt8(velocity))
                }
                //}
                //else {
                if let orb = bodyB as? Orb {
                    orb.orbSynth.reverb.dryWetMix = 0.5
                    orb.orbSynth.delay.dryWetMix = 1.0
                    orb.orbSynth.tremolo.depth = 0.7
                    orb.orbSynth.tremolo.frequency = 4.0
                    orb.play(velocity: UInt8(velocity))
                }
                //}
            }
                // Else if a RED and Red collide - HARD DELAY
            else if bodyA.name == "redOrb" && bodyB.name == "redOrb" {
                
                hasOrbCollided = true
                
                print("[GaneScene.swift] Collision of impulse: \(Int(contact.collisionImpulse))")
                
                if let orb = bodyA as? Orb {
                    orb.orbSynth.reverb.dryWetMix = 0.3
                    orb.orbSynth.delay.dryWetMix = 0.7
                    orb.orbSynth.tremolo.depth = 1.0
                    orb.orbSynth.tremolo.frequency = 8.0
                    orb.play(velocity: UInt8(velocity))
                }
            }
        }
    }


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * TUTORIAL FUNCTIONS  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    public func setTutorialActive(_ bool: Bool) {
        tutorialIsActive = bool
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Guard to ignore all other touches if multiple touches are registered.
        guard let touch = touches.first else { return }
        
        if tutorialIsActive { tutorialScene.overlayTouched(touch, with: event) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if tutorialIsActive {
            tutorialScene.update()
        }
        
        hasOrbCollided = false
    }
}

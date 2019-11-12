//
//  TutorialScene.swift
//  Circles
//
//  Created by Oliver Still on 09/11/2019.
//  Copyright © 2019 Oliver Still. All rights reserved.
//

import Foundation
import SpriteKit
import CoreMotion

class TutorialScene {
    
    private var sandboxScene:       SandboxScene!
    private var tutorialOverlay:    SKNode!
    private var currentInfoLabel:   SKLabelNode!
    private var nextInfoLabel:      NSMutableAttributedString!
    private var sequenceState:      Int!
    public  var readyToAdvance:     Bool!
    
    private let tutorialText = [0 : "WELCOME TO CIRCLES!  THE INTERACTIVE AUDIO SANDBOX.",
                                1 : "THIS TUTORIAL WILL GUIDE YOU THROUGH ALL THE CONTROLS NEEDED TO PRODUCE YOUR OWN UNIQUE AMBIENT SOUNDSCAPES.",
                                2 : "IN THE CENTRE IS AN ORB - THESE HAVE SPECIAL PROPERTIES, AND ARE THE BUILDING BLOCKS OF YOUR SOUNDSCAPE.",
                                3 : "ORBS ARE EFFECTED BY GRAVITY - TRY TILTLING THE SCREEN TO MOVE THE ORB AROUND...",
                                4 : "",
                                5 : "",
                                6 : "",
                                7 : "",
                                8 : "",
                                9 : "",
                                10: ""]
    
    init(sandbox: SandboxScene) {
        
        // Set sandboxScene as the taget scene.
        sandboxScene = sandbox
        
        // Set class varibles from nodes in sandboxScene.
        tutorialOverlay = sandboxScene.childNode(withName: "tutorialSceneNode")
        currentInfoLabel = tutorialOverlay.childNode(withName: "tutorialInfoLabel") as? SKLabelNode
        
        
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
        
        // Create a mutable attributed string using the text and attributes of the existant tutorialInfoLabel.
        // (This allows the editing of attributed text without changing the look that can then be assigned to an SKLabelNode.)
        nextInfoLabel = NSMutableAttributedString(string: currentInfoLabel.attributedText!.string, attributes: currentInfoLabel.attributedText!.attributes(at: 0, effectiveRange: nil))
        
        // Prcautionary alpha set to allow the tutorialOverlayToggle() function to work correctly.
        tutorialOverlay.alpha = 0.0
        
        // Initalise the tutorial sequence.
        sequenceState = 0
        readyToAdvance = true
        tutorialSequence()
    }
    
    private func toggleTutorialOverlay() {
        
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
        
        print("[SandboxScene.swift] Tutorial state \(sequenceState!).")
        
        // Switch-Case to keep track of the tutorial sequenece, including triggering the overlay and setting the text.
        switch sequenceState! {
            
        case 0: // Overlay with welcome text.
            toggleTutorialOverlay()
        case 4:
            readyToAdvance = false
            toggleTutorialOverlay()
            waitForUser(at: sequenceState)
        default:
            nextInfoLabel.mutableString.setString(tutorialText[sequenceState]!)
            currentInfoLabel.attributedText = nextInfoLabel
        }
    }
    
    public func overlayTouched(_ touch: UITouch, with event: UIEvent?) {
        
        // Find the location and nodes of the first touch.
        let location = touch.location(in: tutorialOverlay)
        let touchedNodes = sandboxScene.nodes(at: location)
                
        for node in touchedNodes {
            if node.name == "tutorialSkipLabel" {
                // ... reset tutorial sequence and fade out tutorial overlay.
                sequenceState = 0
                tutorialOverlay.run(SKAction.fadeOut(withDuration: 1))
                return
            }
        }
        if readyToAdvance {
            sequenceState += 1
            tutorialSequence()
        }
    }
    
    private func waitForUser(at tutorialState: Int) {
        switch tutorialState {
        case 4:
            //if sandboxScene!.physicsWorld > 4 {
                readyToAdvance = true
                sequenceState += 1
                tutorialSequence() // ***********
            //}
        default:
            break
        }
    }
    
    public func setTutorialReadyToAdvance(_ bool: Bool) {
        readyToAdvance = bool
    }
}

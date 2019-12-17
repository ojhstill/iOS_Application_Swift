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
    
    /* CLASS VARIABLES */
    
    private var sandboxScene:       SandboxScene!                   // Target scene for the tutorial to run over.
    
    private var sandboxParentNode:  SKNode!
    private var tutorialOverlay:    SKNode!                         // Main parent that holds all nodes associated with the sandbox scene.
    private var userGuideLabel:     SKLabelNode!
    private var currentInfoLabel:   SKLabelNode!
    private var nextInfoLabel:      NSMutableAttributedString!
    
    private var sequenceState:      Int!
    private var readyToAdvance:     Bool!
    
    
    /* CLASS CONSTANTS */
    
    private let tutorialText = [0 : "WELCOME TO CIRCLES!\n THE INTERACTIVE AUDIO SANDBOX BY Y3857872",
                                1 : "THIS TUTORIAL WILL GUIDE YOU THROUGH ALL THE CONTROLS NEEDED TO PRODUCE YOUR OWN UNIQUE AMBIENT SOUNDSCAPES.",
                                2 : "IN THE CENTRE IS AN ORB.\n THESE HAVE SPECIAL PROPERTIES, AND ARE THE BUILDING BLOCKS OF YOUR SOUNDS.",
                                3 : "ORBS ARE EFFECTED BY GRAVITY.\n TRY TILTLING THE SCREEN TO MOVE THE ORB AROUND...",
                                5 : "GREAT!\n NOW LET'S ADD ANOTHER ORB.",
                                6 : "PINCH AND HOLD ON THE SCREEN TO CREATE AN ORB.\n YOU CAN RESIZE BY ADJUSTING YOUR PINCH...",
                                8 : "PERFECT! ORBS ALSO HAVE THEIR OWN SOUNDS AND EFFECTS.",
                                9 : "TILT THE SCREEN TO MAKE THE ORBS COLLIDE TO HEAR WHAT HAPPENS... ",
                                11: "WOAH!\n HEAR THAT?",
                                12: "THE SIZE OF EACH ORB WILL CHANGE THE OCTAVE RANGE.\n THE LARGER THE ORB, THE LOWER THE OCTAVE RANGE",
                                13: "THE IMPACT OF THE COLLISION ALSO EFFECTS THE LOUDNESS OF THE SOUND.",
                                14: "AT THE BOTTOM OF THE SCREEN IS A SETTINGS ICON.",
                                15: "YOU CAN CHANGE A VARIETY OF SETTINGS BY TAPPING ON THE ICON TO DISPLAY A CONTROL PANEL.",
                                16: "LET'S CHANGE THE TYPE OF ORB.\n TAP THE ICON IN THE BOTTOM RIGHT CORNER OF THE SCREEN...",
                                18: "THERE ARE THREE DIFFERENT TYPES OF ORBS TO CHOOSE FROM.",
                                19: "SELECT A DIFFERENT ORB AND ADD IT TO THE SANDBOX...",
                                21: "AMAZING!\n NOTICE THE DIFFERENT SOUND THAT THE ORB PRODUCES?",
                                22: "DEPENDING ON THE TYPE OF ORBS THAT IT COLLDIES WITH, THE EFFECTS OF THE SOUND WILL CHANGE.",
                                23: "YOU CAN USE THIS TO CREATE DYNAMIC AND EVOLVING SOUNDSCPAES.",
                                24: " ",
                                25: " ",
                                26: " ",
                                27: " ",
                                28: " ",
                                29: "IF YOU NEED HELP AT ANY POINT, YOU CAN TAP THE HELP ICON AT THE TOP RIGHT CORNER OF THE SCREEN."]
    
    
    /* INIT() */
    
    init(target scene: SKScene) {
        
        // Set sandboxScene as the taget scene class varible.
        sandboxScene = scene as? SandboxScene
        
        // Set class varibles from nodes in sandboxScene.
        sandboxParentNode = sandboxScene.childNode(withName: "sandboxSceneNode")
        tutorialOverlay   = sandboxScene.childNode(withName: "tutorialSceneNode")
        currentInfoLabel  = tutorialOverlay.childNode(withName: "tutorialInfoLabel") as? SKLabelNode
        userGuideLabel    = tutorialOverlay.childNode(withName: "tutorialGuideLabel") as? SKLabelNode
        
        // Fade in and pulse tutorialGuideLabel.
        userGuideLabel.alpha = 0.0
        userGuideLabel.run(SKAction.repeatForever(SKAction.init(named: "PulseScale125", duration: 2)!))
        userGuideLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.fadeIn(withDuration: 3)]))
        
        // Get 'menuTutorialLabel' SKLabelNode from tutorialSceneNode.
        // (Properties of this varible can remain the same, therefore doesn't need to be a class varible.)
        if let label = tutorialOverlay.childNode(withName: "tutorialSkipLabel") as? SKLabelNode {
            // Fade in and pulse label forever.
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
        readyToAdvance = false
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
        
        // Switch-case to keep track of the tutorial sequenece, including triggering the overlay and setting the text.
        switch sequenceState! {
            
        case 0: // Welcome screen.
            readyToAdvance = true
            toggleTutorialOverlay()
            return
        case 4, 7, 10, 17, 20: // Tutorial user prompts.
            readyToAdvance = false
            toggleTutorialOverlay()
            return
        case 14: // Fade in control panel icon.
            if let panelIcon = sandboxParentNode.childNode(withName: "controlPanelIcon") as? SKSpriteNode {
                panelIcon.run(SKAction.fadeIn(withDuration: 1))
            }
        case 29: // Fade in help icon.
            if let panelIcon = sandboxParentNode.childNode(withName: "helpIcon") as? SKSpriteNode {
                panelIcon.run(SKAction.fadeIn(withDuration: 1))
            }
            
        default:
            // Ignore and continue.
            break
        }
        
        // If sequence state case hasnt been called, advance info text.
        nextInfoLabel.mutableString.setString(tutorialText[sequenceState]!)
        currentInfoLabel.attributedText = nextInfoLabel
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
        
        if readyToAdvance && tutorialOverlay.alpha == 1.0 {
            sequenceState += 1
            tutorialSequence()
        }
    }
    
    private func waitForUser(at tutorialState: Int) {
        
        switch tutorialState {
        case 4:
            let gravity = sandboxScene.getGravity()
            if abs(gravity.dx) >= 2.0 || abs(gravity.dy) >= 2.0 {
                readyToAdvance = true
            }
        case 7:
            if sandboxScene.getOrbArray().count > 1 {
                readyToAdvance = true
            }
        case 10:
            if sandboxScene.hasOrbCollided() {
                readyToAdvance = true
            }
        case 17:
            if sandboxScene.isControlPanelActive() {
                userGuideLabel.run(SKAction.moveTo(y: 160, duration: 0))
                readyToAdvance = true
            }
        case 20:
            let orbs = sandboxScene.getOrbArray()
            let orbName = orbs[orbs.count - 1].name
            if orbName == "purpleOrb" || orbName == "redOrb"{
                userGuideLabel.run(SKAction.moveTo(y: -420, duration: 0))
                readyToAdvance = true
            }
        default:
            // Ignore and return.
            return
        }
        
        if readyToAdvance && tutorialOverlay.alpha == 0.0 {
            toggleTutorialOverlay()
            sequenceState += 1
            tutorialSequence()
        }
    }
    
    public func update() {
        waitForUser(at: sequenceState)
    }
}

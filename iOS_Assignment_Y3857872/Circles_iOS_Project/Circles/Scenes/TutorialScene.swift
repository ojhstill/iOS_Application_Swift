//
//  TutorialScene.swift
//  Circles
//
//  Created by Y3857872 on 09/11/2019.
//  Copyright © 2020 Crcl App Studios (Y3857872). All rights reserved.
//

// Import Core Libraries
import Foundation
import SpriteKit
import CoreMotion

class TutorialScene {
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS VARIABLES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Define tutorial scene varibles:
    private var sandboxScene:       SandboxScene!                   // Target scene for the tutorial to run over.
    private var sequenceState:      Int!                            // Integer to keep track of the current location of the tutorial sequence.
    private var readyToAdvance:     Bool!                           // Boolean to represent that a tutorial task has been completed.
    
    // Define tutorial scene nodes:
    private var sandboxParentNode:  SKNode!                         // Main parent that holds all nodes associated with the sandbox scene.
    private var tutorialOverlay:    SKNode!                         // Main parent that holds all nodes associated with the tutorial.
    private var userGuideLabel:     SKLabelNode!                    // Label to guide the user through the tutorial sequence.
    private var currentInfoLabel:   SKLabelNode!                    // Current tutorial text displayed from the tutorialText dictionary.

    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS CONSTANTS * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Dictionary containing the tutorial text at each sequence state.
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
                                21: "AMAZING!\n NOW LET'S MAKE THEM COLLIDE AGAIN...",
                                23: "NOTICE THE DIFFERENT SOUND THAT THE ORB PRODUCES?",
                                24: "DEPENDING ON THE TYPE OF ORBS THAT IT COLLDIES WITH, THE EFFECTS OF THE SOUND WILL CHANGE.",
                                25: "USE THIS FEATURE TO CREATE UNIQUE AND EVOLVING SOUNDSCPAES!",
                                26: "TO REMOVE AN ORB, DOUBLE TAP ON THE ORB YOU WANT TO REMOVE. TRY REMOVING SOME OF THE ORBS ON THE SCREEN...",
                                28: "YOU'RE GREAT AT THIS!",
                                29: "YOU CAN ALSO CHANGE THE PENTATONIC KEY AND THE VOLUME OF THE SOUNDSCAPE FROM WITHIN THE CONTROL PANEL.",
                                30: "IF YOU NEED HELP AT ANY POINT, YOU CAN TAP THE HELP ICON AT THE TOP RIGHT CORNER OF THE SCREEN.",
                                31: "IT'S ALL OVER TO YOU NOW - ENJOY CIRCLES!"]


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
        if let skipLabel = tutorialOverlay.childNode(withName: "tutorialSkipLabel") as? SKLabelNode {
            // Fade in and pulse label forever.
            skipLabel.alpha = 0.0
            skipLabel.run(SKAction.repeatForever(SKAction.init(named: "PulseScale105", duration: 3)!))
            skipLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1),
                                             SKAction.fadeIn(withDuration: 3)]))
        }
        
        // Prcautionary alpha set to allow the tutorialOverlayToggle() function to work correctly.
        tutorialOverlay.alpha = 0.0
        
        // Initalise the tutorial sequence.
        sequenceState = 0
        sandboxScene.setTutorialSequenceState(to: 0)
        readyToAdvance = false
        tutorialSequence()
    }

    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    // Called after each frame update within the SandboxScene update() protocol.
    public func update() {
        waitForUser(at: sequenceState)
    }
    

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PRIVATE CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Main tutorial sequenece:
    private func tutorialSequence() {
        
        print("[SandboxScene.swift] Tutorial state \(sequenceState!).")
        
        // Switch-case to keep track of the tutorial sequenece, including triggering the overlay and setting the text.
        switch sequenceState! {
            
            case 0: // Welcome screen.
                readyToAdvance = true
                toggleTutorialOverlay()
                return
            case 4, 7, 10, 17, 20, 22, 27: // Tutorial user prompts.
                // Disable tutorial user interaction.
                sandboxScene.setTutorialUserInteraction(false)
                readyToAdvance = false
                toggleTutorialOverlay()
                return
            case 14: // Fade in control panel icon.
                if let panelIcon = sandboxParentNode.childNode(withName: "controlPanelIcon") as? SKSpriteNode {
                    panelIcon.run(SKAction.fadeIn(withDuration: 1))
                }
            case 30: // Fade in help icon.
                if let panelIcon = sandboxParentNode.childNode(withName: "helpIcon") as? SKSpriteNode {
                    panelIcon.run(SKAction.fadeIn(withDuration: 1))
                }
            case 32: // End tutorial sequence.
                toggleTutorialOverlay()
                // Disable tutorial user interaction.
                sandboxScene.setTutorialUserInteraction(false)
                sandboxScene.setTutorialActive(false)
                return
            default:
                // Ignore and continue.
                break
        }
        
        // Create a mutable attributed string using the text and attributes of the existant currentInfoLabel.
        // (This allows the editing of attributed text without changing the look and style of the SKLabelNode.)
        let nextInfoLabel = NSMutableAttributedString(string: currentInfoLabel.attributedText!.string,
                                                  attributes: currentInfoLabel.attributedText!.attributes(at: 0, effectiveRange: nil))
        
        // If sequence state tast hasnt been set, advance info text.
        nextInfoLabel.mutableString.setString(tutorialText[sequenceState]!)
        currentInfoLabel.attributedText = nextInfoLabel
    }
    
    // Sequence states to wait for a defined user interaction to advance the tutorial sequence:
    private func waitForUser(at tutorialState: Int) {
        
        switch tutorialState {
            case 4: // Wait for user to tilt the screen.
                let gravity = sandboxScene.getGravity()
                if abs(gravity.dx) >= 1.0 || abs(gravity.dy) >= 1.0 {
                    readyToAdvance = true
                }
            case 7: // Wait for user to add another orb to the sandbox.
                if sandboxScene.hasOrbBeenAdded() {
                    readyToAdvance = true
                }
            case 10: // Wait for user to make the orbs collide.
                if sandboxScene.hasOrbCollided() {
                    readyToAdvance = true
                }
            case 17: // Wait for user to activate the control panel.
                if sandboxScene.isControlPanelActive() {
                    userGuideLabel.run(SKAction.moveTo(y: 160, duration: 0))
                    readyToAdvance = true
                }
            case 20: // Wait for user to add a different orb to the screen.
                if sandboxScene.hasOrbBeenAdded() {
                    let orbs = sandboxScene.getOrbArray()
                    let orbName = orbs[orbs.count - 1].name
                    // Check that orb is other than blue.
                    if orbName == "purpleOrb" || orbName == "redOrb" {
                        
                        // Collapse control panel is it is active.
                        if sandboxScene.isControlPanelActive() {
                            sandboxScene.toggleControlPanel()
                        }
                        
                        userGuideLabel.run(SKAction.moveTo(y: -420, duration: 0))
                        readyToAdvance = true
                    }
                }
            case 22: // Wait for user to make the orbs collide.
                if sandboxScene.hasOrbCollided() {
                    readyToAdvance = true
                }
            case 27: // Wait for user to remove orbs down to 2.
                if sandboxScene.getOrbArray().count < 3 {
                    readyToAdvance = true
                }
            default:
                // Ignore and return.
                return
        }
        
        // If user has completed the tutorial task and the overlay is off, increase the sequence to the next state.
        if readyToAdvance && tutorialOverlay.alpha == 0.0 {
            
            // Enable tutorial user interaction.
            sandboxScene.setTutorialUserInteraction(true)
            
            toggleTutorialOverlay()
            sequenceState += 1
            sandboxScene.setTutorialSequenceState(to: sequenceState)
            tutorialSequence()
        }
    }
    
    // Toggles the tutorial overlay, triggered automatically in the tutorial sequenece:
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
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * TUTORIALSCENE PROTOCOLS * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Function triggered when a touch from a user is detected on the scene:
    public func overlayTouched(_ touch: UITouch, with event: UIEvent?) {
        
        // Find the location and nodes of the first touch.
        let location = touch.location(in: tutorialOverlay)
        let touchedNodes = sandboxScene.nodes(at: location)
                
        for node in touchedNodes {
            // If user touches 'Skip Tutorial' label,...
            if node.name == "tutorialSkipLabel" {
                
                // ... fade out tutorial overlay.
                
                tutorialOverlay.run(SKAction.fadeOut(withDuration: 1))
                
                // Fade in the control panel icon.
                if let panelIcon = sandboxParentNode.childNode(withName: "controlPanelIcon") as? SKSpriteNode {
                    panelIcon.run(SKAction.fadeIn(withDuration: 1))
                }
                // Fade in the help icon.
                if let panelIcon = sandboxParentNode.childNode(withName: "helpIcon") as? SKSpriteNode {
                    panelIcon.run(SKAction.fadeIn(withDuration: 1))
                }
                
                // End tutorial and disable tutorial user interaction.
                sequenceState = 32
                sandboxScene.setTutorialSequenceState(to: 32)
                sandboxScene.setTutorialUserInteraction(false)
                sandboxScene.setTutorialActive(false)
                
                return
            }
        }
        
        // If the overlay is on and a task has not been set, increase the sequence to the next state.
        if readyToAdvance && tutorialOverlay.alpha == 1.0 {
            sequenceState += 1
            sandboxScene.setTutorialSequenceState(to: sequenceState)
            tutorialSequence()
        }
    }
}

//
//  MenuScene.swift
//  Circles
//
//  Created by Y3857872 on 07/11/2019.
//  Copyright © 2019 Y3857872. All rights reserved.
//

// Import Core Libraries
import Foundation
import SpriteKit

class MenuScene: SKScene {
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS VARIABLES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Define menu scene varibles:
    weak    var viewController:     GameViewController!         // Weak storage of the scene's view to communicate with controller.
    private var tutorialActive:     Bool!                       // Boolean to trigger the tutorial when game starts.


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    override func didMove(to view: SKView) {
        
        // Set the scale mode to scale to fit the SKView.
        self.scaleMode = .resizeFill
        
        // Initialise tutorialActive boolean to false.
        tutorialActive = false
        
        // Call private function to animate MenuScene.
        animateMenuScreen(in: view)
        
        print("[MenuScene.swift] Menu scene active.")
    }
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PRIVATE CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    private func animateMenuScreen(in view: SKView) {
        
        // Get 'menuOrbSprite' SKSpriteNode from MenuScene.
        if let orbSprite = self.childNode(withName: "menuOrbSprite") as? SKSpriteNode {
            // Fade in and pulse label.
            orbSprite.alpha = 0.0
            orbSprite.run(SKAction.repeatForever(SKAction.init(named: "PulseScale105", duration: 10)!))
            orbSprite.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                             SKAction.fadeIn(withDuration: 1)]))
            
            // Get 'orbLightNode' SKLightNode from MenuScene.
            if let lightNode = orbSprite.childNode(withName: "orbLightNode") as? SKLightNode {
                // Fade in light.
                lightNode.falloff = 2.0
                lightNode.run(SKAction.fadeIn(withDuration: 2))
            }
            
            // Get 'menuTitleLabel' SKLabelNode from MenuScene.
            if let titleLabel = orbSprite.childNode(withName: "menuTitleLabel") as? SKLabelNode {
                // Pulse label with 'menuOrbSprite'.
                titleLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1),
                                                  SKAction.repeatForever(SKAction.init(named: "PulseScale105", duration: 10)!)]))
            }
        }
        
        // Get 'menuGuideLabel' SKLabelNode from MenuScene.
        if let guideLabel = self.childNode(withName: "menuGuideLabel") as? SKLabelNode {
            // Fade in and pulse label.
            guideLabel.alpha = 0.0
            guideLabel.run(SKAction.repeatForever(SKAction.init(named: "PulseScale125", duration: 2)!))
            guideLabel.run(SKAction.sequence([SKAction.wait(forDuration: 1),
                                              SKAction.fadeIn(withDuration: 3)]))
        }
        
        // Get 'menuTutorialLabel' SKLabelNode from MenuScene.
        if let tutorialLabel = self.childNode(withName: "menuTutorialLabel") as? SKLabelNode {
            // Fade in and pulse label.
            tutorialLabel.alpha = 0.0
            tutorialLabel.run(SKAction.repeatForever(SKAction.init(named: "PulseScale105", duration: 3)!))
            tutorialLabel.run(SKAction.sequence([SKAction.wait(forDuration: 2),
                                                 SKAction.fadeIn(withDuration: 3)]))
        }
    }
    
    private func presentSandboxScene() {
            
        // Load the SKScene from 'SandboxScene.sks'
        if let sandboxScene = SandboxScene(fileNamed: "SandboxScene") {
            
            // Assign weak storage of sandboxScene inside the viewController.
            viewController.setCurrentScene(to: sandboxScene)
            viewController.sandboxScene = sandboxScene
            sandboxScene.viewController = self.viewController
            
            // Get 'menuOrbSprite' SKSpriteNode from MenuScene.
            if let orbSprite = self.childNode(withName: "menuOrbSprite") as? SKSpriteNode {
                // Scale orb sprite to original size.
                orbSprite.removeAllActions()
                orbSprite.run(SKAction.scale(to: 1, duration: 1))
                
                // Get 'menuTitleLabel' SKLabelNode from MenuScene.
                if let titleLabel = orbSprite.childNode(withName: "menuTitleLabel") as? SKLabelNode {
                    // Fade out title label with 'menuOrbSprite'.
                    titleLabel.removeAllActions()
                    titleLabel.run(SKAction.fadeOut(withDuration: 1))
                }
            }
            
            // If the tutorial is toggled 'true', set the tutorial active within the sandbox to present the tutorial.
            sandboxScene.setTutorialActive(tutorialActive)
            
            // Create SKTransition to crossfade between scenes.
            let transition = SKTransition.crossFade(withDuration: 3)
            transition.pausesOutgoingScene = false
            
            // Present scene to the SKView.
            self.view!.presentScene(sandboxScene, transition: transition)
        }
    }


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * MENUSCENE PROTOCOLS * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Function triggered when a touch from a user is detected on the scene:
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Guard to ignore all other touches if multiple touches are registered.
        guard let touch = touches.first else { return }
        
        // Find the location and nodes of the first touch.
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        // Within the touchedNodes array, ...
        for node in touchedNodes {
            
            //... if 'menuOrbSprite' is touched, present the SandboxScene.
            if node.name == "menuOrbSprite" {
                // Transition to sandbox scene.
                presentSandboxScene()
                return
            }
                
            //... if 'menuTutorialLabel' is touched, toggle the tutorialActive boolean and update the tutorial label.
            else if node.name == "menuTutorialLabel" {
                
                // Get 'menuTutorialLabel' SKLabelNode from MenuScene.
                if let tutorialLabel = self.childNode(withName: "menuTutorialLabel") as? SKLabelNode {
                    
                    if tutorialActive {
                        tutorialLabel.text = "TUTORIAL OFF"
                        tutorialActive = false
                        print("[MenuScene.swift] Tutorial set off.")
                    }
                    else {
                        tutorialLabel.text = "TUTORIAL ON"
                        tutorialActive = true
                        print("[MenuScene.swift] Tutorial set on.")
                    }
                }
                return
            }
        }
    }
}

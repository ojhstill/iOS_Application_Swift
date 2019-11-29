//
//  MenuScene.swift
//  Circles
//
//  Created by Oliver Still on 07/11/2019.
//  Copyright © 2019 Oliver Still. All rights reserved.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    
    /* CLASS VARIABLES */
    
    weak var viewController: GameViewController!        // Manages the scene's view and communicates with the UIKit.
    private var tutorialActive: Bool!                   // Boolean to trigger the tutorial when game starts.
    
    
    /* INIT() */
    
    override func didMove(to view: SKView) {
        
        // Set the scale mode to scale to fit the SKView.
        self.scaleMode = .resizeFill
        
        // Initialise tutorialActive boolean to false.
        tutorialActive = false
        
        // Call private function to animate static menuScene.
        animateMenuScreen(in: view)
        
        print("[MenuScene.swift] Menu scene active.")
    }
    
    private func animateMenuScreen(in view: SKView) {
        
        // Get 'menuOrbSprite' SKSpriteNode from menuScene.
        if let sprite = self.childNode(withName: "menuOrbSprite") as? SKSpriteNode {
            // Pulse sprite.
            sprite.run(SKAction.repeatForever(SKAction.init(named: "PulseScale105", duration: 10)!))
            
            // Get 'orbLightNode' SKLightNode from menuScene.
            if let light = sprite.childNode(withName: "orbLightNode") as? SKLightNode {
                // Fade in light.
                light.falloff = 2.0
                light.run(SKAction.fadeIn(withDuration: 2))
            }
            
            // Get 'menuTitleLabel' SKLabelNode from menuScene.
            if let label = sprite.childNode(withName: "menuTitleLabel") as? SKLabelNode {
                // Pulse label with 'menuOrbSprite'.
                label.run(SKAction.sequence([SKAction.wait(forDuration: 0.4),
                                             SKAction.repeatForever(SKAction.init(named: "PulseScale105", duration: 10)!)]))
            }
        }
        
        // Get 'menuGuideLabel' SKLabelNode from menuScene.
        if let label = self.childNode(withName: "menuGuideLabel") as? SKLabelNode {
            // Fade in and pulse label.
            label.alpha = 0.0
            label.run(SKAction.repeatForever(SKAction.init(named: "PulseScale125", duration: 2)!))
            label.run(SKAction.sequence([SKAction.wait(forDuration: 1),
                                         SKAction.fadeIn(withDuration: 3)]))
        }
        
        // Get 'menuTutorialLabel' SKLabelNode from menuScene.
        if let label = self.childNode(withName: "menuTutorialLabel") as? SKLabelNode {
            // Fade in and pulse label.
            label.alpha = 0.0
            label.run(SKAction.repeatForever(SKAction.init(named: "PulseScale105", duration: 3)!))
            label.run(SKAction.sequence([SKAction.wait(forDuration: 2),
                                         SKAction.fadeIn(withDuration: 3)]))
        }
    }
    
    private func presentSandboxScene() {
            
        // Load the SKScene from 'SandboxScene.sks'
        if let scene = SandboxScene(fileNamed: "SandboxScene") {
            
            // Set the current scene to menuScene.
            viewController.currentScene = scene
            
            // Assign weak storage of sandboxScene inside the viewController.
            viewController.sandboxScene = scene
            scene.viewController = self.viewController
            
            // Get 'menuOrbSprite' SKSpriteNode from menuScene.
            if let sprite = self.childNode(withName: "menuOrbSprite") as? SKSpriteNode {
                // Scale sprite to original size.
                sprite.removeAllActions()
                sprite.run(SKAction.scale(to: 1, duration: 1))
                
                // Get 'menuTitleLabel' SKLabelNode from menuScene.
                if let label = sprite.childNode(withName: "menuTitleLabel") as? SKLabelNode {
                    // Fade out label with 'menuOrbSprite'.
                    label.removeAllActions()
                    label.run(SKAction.fadeOut(withDuration: 1))
                }
            }
            
            // If the tutorial is toggled 'ON', present the tutorial overlay.
            scene.setTutorialActive(tutorialActive)
            
            // Create SKTransition to crossfade between scenes.
            let transition = SKTransition.crossFade(withDuration: 3)
            transition.pausesOutgoingScene = false
            
            // Present scene to the SKView.
            self.view!.presentScene(scene, transition: transition)
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
            
            //... if 'menuOrbSprite' is touched, present the sandboxScene.
            if node.name == "menuOrbSprite" {
                
                // Transition to sandbox scene.
                presentSandboxScene()
                break
            }
                
            //... if 'menuTutorialLabel' is touched, toggle the tutorialActive boolean and update label.
            else if node.name == "menuTutorialLabel" {
                
                if let label = self.childNode(withName: "menuTutorialLabel") as? SKLabelNode {
                    if tutorialActive {
                        label.text = "TUTORIAL OFF"
                        tutorialActive = false
                        print("[MenuScene.swift] Tutorial set off.")
                    }
                    else {
                        label.text = "TUTORIAL ON"
                        tutorialActive = true
                        print("[MenuScene.swift] Tutorial set on.")
                    }
                }
                break
            }
        }
    }
}

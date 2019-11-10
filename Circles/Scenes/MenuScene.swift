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
    
    /* Class Varibles */
    var tutorialActive: Bool!
    
    /* init() */
    override func didMove(to view: SKView) {
        
        // Set the scale mode to scale to fit the SKView.
        self.scaleMode = .resizeFill
        
        // Initialise tutorialActive boolean to false.
        tutorialActive = false
        
        // Call private function to animate static menuScene.
        animateMenuScreen(in: view)
        
        print("[MenuScene.swift] Menu Scene Active")
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
            scene.setTutorialActive(bool: tutorialActive)
            
            // Create SKTransition to crossfade between scenes.
            let transition = SKTransition.crossFade(withDuration: 3)
            transition.pausesOutgoingScene = false
            
            // Wait for 1 second to allow animation to finish.
//            sleep(1)
            
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
                
                /*
                // Create SKView to overlay tutorial infomation.
                let overlayView = SKView(frame: self.view!.frame)
                
                // Allow transparency and user interaction.
                overlayView.allowsTransparency = true
                overlayView.isUserInteractionEnabled = true
                
                // Add overlay SKView as a subview to main SKView and bring to front.
                self.view!.addSubview(overlayView)
                self.view!.bringSubviewToFront(overlayView)
                */
                
                // Transition to sandbox scene.
                presentSandboxScene()
            }
            //... if 'menuTutorialLabel' is touched, toggle the tutorialActive boolean and update label.
            else if node.name == "menuTutorialLabel" {
                
                if let label = self.childNode(withName: "menuTutorialLabel") as? SKLabelNode {
                    if tutorialActive {
                        label.text = "TUTORIAL OFF"
                        tutorialActive = false
                        print("[MenuScene.swift] Tutorial set OFF")
                    }
                    else {
                        label.text = "TUTORIAL ON"
                        tutorialActive = true
                        print("[MenuScene.swift] Tutorial set ON")
                    }
                }
            }
        }
    }
}

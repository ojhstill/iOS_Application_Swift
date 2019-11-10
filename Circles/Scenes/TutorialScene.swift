//
//  TutorialScene.swift
//  Circles
//
//  Created by Oliver Still on 09/11/2019.
//  Copyright © 2019 Oliver Still. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import CoreMotion

class TutorialScene: SKScene {
  
//    var sandboxScene: SKScene!
    
    override func didMove(to view: SKView) {
        
        // Set the scale mode to scale to fit the SKView overlay.
        self.scaleMode = .resizeFill
        
        // Setup user interaction.
        self.isUserInteractionEnabled = true
        
        print("[TutorialScene.swift] Tutorial Scene Active")
        
        startTutorialSequence()
    }
    
    private func startTutorialSequence() {
        
        if let node = self.childNode(withName: "tutorialSceneNode") {
            // Fade in and pulse label.
            node.alpha = 0.0
            node.run(SKAction.sequence([SKAction.wait(forDuration: 1),
                                         SKAction.fadeIn(withDuration: 2)]))
        }
        
    }
    
}

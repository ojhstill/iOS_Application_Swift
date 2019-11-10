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
  
    override func didMove(to view: SKView) {
        
        // Set the scale mode to scale to fit the SKView.
        self.scaleMode = .resizeFill
        
        // Setup user interaction.
        self.isUserInteractionEnabled = true
        
        print("[TutorialScene.swift] Tutorial Scene Active")
    }
    
}

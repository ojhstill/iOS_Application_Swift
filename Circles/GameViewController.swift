//
//  GameViewController.swift
//  Circles
//
//  Created by Oliver Still on 07/11/2019.
//  Copyright © 2019 Oliver Still. All rights reserved.
//

import SpriteKit

class GameViewController: UIViewController {
    
    var currentScene: SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
                        
            // Load the SKScene from 'GameScene.sks'
            if let menuScene = SKScene(fileNamed: "MenuScene") {
                
                // Present the main menuScene.
                view.presentScene(menuScene)
                
                // Update the current scene to menuScene.
                currentScene = menuScene
            }
            
            // Allow transparency for tutorial scene overlay.
            view.allowsTransparency = false
            
            // DEBUG TOOLS
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

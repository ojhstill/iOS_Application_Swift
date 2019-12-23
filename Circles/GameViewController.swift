//
//  GameViewController.swift
//  Circles
//
//  Created by Y3857872 on 07/11/2019.
//  Copyright © 2019 Y3857872. All rights reserved.
//

// Import Core Libraries
import SpriteKit

class GameViewController: UIViewController {
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS VARIABLES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    public var currentScene:    SKScene!                    //
    weak   var menuScene:       MenuScene!                  //
    weak   var sandboxScene:    SandboxScene!               //


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
                        
            // Load the SKScene from 'MenuScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                
                // Present the application main menu.
                view.presentScene(scene)
                
                // Store the currently presented scene.
                currentScene = scene
                
                // Assign weak storage of menuScene and viewController.
                menuScene = scene as? MenuScene
                menuScene.viewController = self
            }
            
            // DEBUG TOOLS:
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * GAMEVIEWCONTROLLER PROTOCOLS * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

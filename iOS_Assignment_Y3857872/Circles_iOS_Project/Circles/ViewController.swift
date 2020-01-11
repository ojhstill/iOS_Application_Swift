//
//  ViewController.swift
//  Circles
//
//  Created by Y3857872 on 07/11/2019.
//  Copyright © 2020 Crcl App Studios (Y3857872). All rights reserved.
//

// Import Core Libraries
import SpriteKit

class ViewController: UIViewController {
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS VARIABLES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Define controller varibles:
    private var currentScene:   SKScene!                    // SKScene to store the currently active displayed scene.


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
                        
            // Load the SKScene from 'MenuScene.sks'
            if let mainMenu = SKScene(fileNamed: "MenuScene") {
                
                // Present the application main menu.
                view.presentScene(mainMenu)
                
                // Store the currently presented scene.
                currentScene = mainMenu
                
                // Assign weak storage of menuScene and viewController.
                let scene = mainMenu as? MenuScene
                scene!.viewController = self
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


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * SETTERS / GETTERS * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    // Stores the currently displayed SKScene in a local varible:
    public func setCurrentScene(to scene: SKScene) {
        // Store the currently presented scene in a local varible.
        currentScene = scene
    }
}

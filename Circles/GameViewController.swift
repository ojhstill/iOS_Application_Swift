//
//  GameViewController.swift
//  Circles
//
//  Created by Oliver Still on 07/11/2019.
//  Copyright © 2019 Oliver Still. All rights reserved.
//

import SpriteKit

class GameViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    /* CLASS VARIABLES */
    
    public var currentScene:    SKScene!
    weak   var menuScene:      MenuScene!
    weak   var sandboxScene:   SandboxScene!
    
    /* CLASS CONSTANTS */
    
    let pickerData = [["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"],
                      ["maj", "min"]]
    
    /* INIT() */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
                        
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                // Present the menuScene.
                view.presentScene(scene)
                
                // Set the current scene to menuScene.
                currentScene = scene
                
                // Assign weak storage of menuScene and viewController.
                menuScene = scene as? MenuScene
                menuScene.viewController = self
            }
            
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: pickerData[component][row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

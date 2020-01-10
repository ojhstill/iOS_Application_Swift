//
//  SandboxScene.swift
//  Circles
//
//  Created by Y3857872 on 07/11/2019.
//  Copyright © 2019 Y3857872. All rights reserved.
//

// Import Core Libraries
import Foundation
import CoreMotion
import GameplayKit
import SpriteKit
import UIKit

class SandboxScene: SKScene, SKPhysicsContactDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS VARIABLES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Define application managers:
    weak    var viewController:             ViewController!                     // Weak storage of the scene's view to communicate with controller.
    private var motionManager:              CMMotionManager!                    // Manages CoreMotion library and accelerometer data.
    private var audioManager:               AudioManager!                       // Manages audio output using AudioKit.
    private var frameCount:                 Int!                                // Current number of frames that have passed since last reset.
    
    // Define sandbox scene varibles:
    private var sandboxParentNode:          SKNode!                             // Main parent that holds all nodes associated with the sandbox scene.
    private var orbSelected:                String!                             // String to hold the currently selected orb type.
    private var orbProperties:              (pos: CGPoint, size: CGSize)!       // Tuple to store the orb properties before an orb's creation.
    private var orbArray:                   [Orb]!                              // Array to hold all active orbs in the sandbox.
    private var orbAdded:                   Bool!                               // Boolean to trigger momentarily after an ord has been added.
    private var orbCollision:               Bool!                               // Boolean to trigger momentarily after each orb collision.
    private var blackHoleGravity:           SKFieldNode!                        // Radial gravity field located in the middle of the sandbox.
    private var helpOverlay:                SKSpriteNode!                       // Node to display the help overlay triggered by the help icon.
    
    // Define control panel varibles:
    private var panelParentNode:            SKNode!                             // Sub parent that holds all nodes associated with the control panel.
    private var panelActive:                Bool!                               // Boolean to trigger when the control panel is active.
    private var panelIcon:                  SKSpriteNode!                       // Control panel sprite node to open the control panel.
    private var helpIcon:                   SKSpriteNode!                       // Help sprite node to open the help overlay.
    private var volSlider:                  UISlider!                           // UI volume slider to change the master volume within AudioManager.
    private var keyPicker:                  UIPickerView!                       // UI picker to change the key of the audio soundscape within OrbSynth.
    private var keyRoot:                    String!                             // The selected root key from the keyPicker data array.
    private var keyTonality:                String!                             // The selected major or minor tonality from the keyPicker data array.
    
    // Define tutorial scene varibles:
    private var tutorialScene:              TutorialScene!                      // TutorialScene variable to initalise the tutorial if active.
    private var tutorialIsActive:           Bool!                               // Boolean to trigger the TutorialScene, set from the MenuScene.
    private var tutorialOverlayActive:      Bool!                               // Boolean to signify the tutorial overlay is active within TutorialScene.
    private var tutorialSequenceState:      Int!                                // Current state of the tutorial sequence within TutorialScene.


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS CONSTANTS * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Define the displayed data array for the UIPicker keyPicker.
    let pickerData = [["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"], ["maj", "min"]]


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    override func didMove(to view: SKView) {
        
        // Set the scale mode to scale to fit the SKView.
        self.scaleMode = .resizeFill
        
        // Setup the physics world properties and user interaction.
        self.physicsWorld.contactDelegate = self
        self.isUserInteractionEnabled = true
        
        // Set the physics body to the edge of the screen.
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        // Reset frame count.
        frameCount = 0
        
        // Setup audio manager (and AudioKit).
        audioManager = AudioManager()
        audioManager.start()
        
        // Setup motion manager.
        motionManager = CMMotionManager()
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) {
            (data, error) in
            // Setup sandbox gravity to the external device accelerometer.
            self.physicsWorld.gravity = CGVector(dx: CGFloat((data?.acceleration.x)!) * 2, dy: CGFloat((data?.acceleration.y)!) * 2)
        }
        
        // Setup 'black hole' gravity point (disabled by default).
        blackHoleGravity = SKFieldNode.radialGravityField()
        blackHoleGravity.categoryBitMask = 1
        blackHoleGravity.strength = 1.0
        blackHoleGravity.falloff = 1.7
        blackHoleGravity.minimumRadius = 300
        blackHoleGravity.position = .zero
        blackHoleGravity.isEnabled = false
        blackHoleGravity.isExclusive = true
        self.addChild(blackHoleGravity)
        
        // Setup all scene nodes to accessible class vairbles.
        sandboxParentNode = self.childNode(withName: "sandboxSceneNode")
        panelParentNode = sandboxParentNode.childNode(withName: "controlPanelNode")
        
        panelIcon = sandboxParentNode.childNode(withName: "controlPanelIcon") as? SKSpriteNode
        helpIcon  = sandboxParentNode.childNode(withName: "helpIcon") as? SKSpriteNode
        
        // Initalise the sandbox node's class varibles.
        orbSelected = "blue"
        
        orbProperties = (CGPoint(x: 0.0, y: 0.0), CGSize(width: 0.0, height: 0.0))
        orbArray = [Orb]()
        
        orbCollision = false
        panelActive = false
        tutorialOverlayActive = false
        
        // Create BlueOrb in the centre of the scene to transition from MenuScene.
        let startingOrb = BlueOrb(position: CGPoint(x: frame.width / 2, y: 0 - (frame.height / 2)), size: CGSize(width: 300, height: 300))

        // Setup starting orb.
        startingOrb.physicsBody = SKPhysicsBody(circleOfRadius: 150)
        spawnOrb(orb: startingOrb)
        orbArray.append(startingOrb)
        sandboxParentNode.addChild(orbArray[orbArray.count - 1])
        startingOrb.orbSynth.connectOrbSynthOutput(to: audioManager.mixer)
        
        // Create volume slider and add to view controller.
        volSlider = UISlider(frame: CGRect(x: 30, y: 1040, width: 150, height: 100))
        volSlider.minimumValue = 0
        volSlider.maximumValue = 1
        volSlider.value = 1
        volSlider.addTarget(self, action: #selector(changeVolume(_:)), for: .valueChanged)
        viewController.view?.addSubview(volSlider)
        
        // Create key picker and add to view controller.
        keyPicker = UIPickerView(frame: CGRect(x: 30, y: 1115, width: 150, height: 100))
        keyPicker.delegate = self
        keyPicker.dataSource = self
        keyPicker.backgroundColor = .clear
        viewController.view?.addSubview(keyPicker)
        
        // Set key defaults.
        keyRoot = "C"
        keyTonality = "maj"
        
        // Add pinch gesture to view to trigger 'pinchRecognised()' function.
        let pinch = UIPinchGestureRecognizer(target: scene, action: #selector(pinchRecognised(pinch:)))
        view.addGestureRecognizer(pinch)
        
        // Add double tap gesture to view to trigger 'doubleTapRecognised()' function.
        let doubleTap = UITapGestureRecognizer(target: scene, action: #selector(doubleTapRecognised(tap:)))
        view.addGestureRecognizer(doubleTap)
        
        print("[SandboxScene.swift] Sandbox scene active.")
        
        // If the tutorial is set 'true', start the tutorial sequence.
        if tutorialIsActive {
            
            // Set tutorial user interaction.
            tutorialOverlayActive = true
            
            // Hide icons.
            helpIcon.alpha = 0.0
            panelIcon.alpha = 0.0
            
            // Begin tutorial.
            tutorialScene = TutorialScene(target: self)
        }
    }

    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Toggles the control panel, triggered by the control panel icon:
    public func toggleControlPanel() {
        
        if panelActive {
            panelIcon.texture = SKTexture(imageNamed: "icons_control.png")
            
            let popOutSK = SKAction.moveBy(x: 0, y: -200, duration: 0.3)
            popOutSK.timingMode = .linear
            
            let popOutCA = CABasicAnimation(keyPath: "transform")
            popOutCA.fillMode = .forwards
            popOutCA.timingFunction = CAMediaTimingFunction(name: .linear)
            popOutCA.duration = 0.3
            popOutCA.byValue = CGAffineTransform(translationX: 0, y: 200)
            
            // Run animations.
            panelParentNode.run(popOutSK)
            volSlider.layer.add(popOutCA, forKey: "transform")
            keyPicker.layer.add(popOutCA, forKey: "transform")
            
            // Update the position of the UIKit elements.
            volSlider.transform.ty += 200
            keyPicker.transform.ty += 200
            
            panelActive = false
        }
        else {
            panelIcon.texture = SKTexture(imageNamed: "icons_close.png")
            
            let popInSK = SKAction.moveBy(x: 0, y: 200, duration: 0.3)
            popInSK.timingMode = .linear
            
            let popInCA = CABasicAnimation(keyPath: "transform")
            popInCA.fillMode = .forwards
            popInCA.timingFunction = CAMediaTimingFunction(name: .linear)
            popInCA.duration = 0.3
            popInCA.byValue = CGAffineTransform(translationX: 0, y: -200)
            
            // Run animations.
            panelParentNode.run(popInSK)
            volSlider.layer.add(popInCA, forKey: "transform")
            keyPicker.layer.add(popInCA, forKey: "transform")
            
            // Update the position of the UIKit elements.
            volSlider.transform.ty -= 200
            keyPicker.transform.ty -= 200
            
            panelActive = true
        }
    }
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * USER GESTURE ACTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // User pinch gesture recogniser target function:
    @objc func pinchRecognised(pinch: UIPinchGestureRecognizer) {
        guard pinch.view != nil else { return }
        
        // Disable user gestures while tutorial is active and you have not reached the add orb tutorial prompt.
        if tutorialIsActive {
            if tutorialOverlayActive || tutorialSequenceState < 6 {
                pinch.state = .cancelled
                return
            }
        }
        
        if pinch.numberOfTouches == 2 {
            
            // ... update the position of the graphic to the middle point between the two touch coordinates.
            orbProperties.pos.x = (pinch.location(ofTouch: 0, in: pinch.view).x + pinch.location(ofTouch: 1, in: pinch.view).x) / 2
            orbProperties.pos.y = 0 - (pinch.location(ofTouch: 0, in: pinch.view).y + pinch.location(ofTouch: 1, in: pinch.view).y) / 2
            
            // Scale and normalise the orb graphic size from 80 to 400.
            var orbSize = 100 * pinch.scale
            
            if orbSize > 400 {
                orbSize = 400
            }
            else if orbSize < 80 {
                orbSize = 80
            }
            
            orbProperties.size = CGSize(width: orbSize, height: orbSize)
        }
        // If a pinch gesture is detected or changed...
        if pinch.state == .began {
            // Create a new dynamic orb with the position and size of the temporary orb graphic.
            var newOrb: Orb!
            
            // ... and if two touch points are detected...
            if pinch.numberOfTouches == 2 {
            
                switch orbSelected {
                    case "blue": // Blue orb sprite selected.
                        newOrb = BlueOrb(position: orbProperties.pos, size: orbProperties.size)
                    case "purple": // Purple orb sprite selected.
                        newOrb = PurpleOrb(position: orbProperties.pos, size: orbProperties.size)
                    case "red": // Red orb sprite selected.
                        newOrb = RedOrb(position: orbProperties.pos, size: orbProperties.size)
                    default: // Default orb initalisation catch.
                        print("[SandboxScene.swift] *** ERROR *** 'orbSelected' variable not recognised.")
                        return
                }
                
                // Add new dynamic orb to scene and the orb array.
                orbArray.append(newOrb)
                sandboxParentNode.addChild(orbArray[orbArray.count - 1])
                
                // Give the orb a unique lighting bit mask to ensure light sources do not constructively interfere.
                newOrb.lightingBitMask = UInt32(pow(2, Double(orbArray!.count)))
                newOrb.lightNode.categoryBitMask = UInt32(pow(2, Double(orbArray!.count)))
            }
            else {
                // ... (else cancel the orb).
                pinch.state = .cancelled
            }
        }
        
        let newOrb = orbArray[orbArray.count - 1]
        
        if pinch.state == .changed {
            newOrb.position = orbProperties.pos
            newOrb.size = orbProperties.size
            newOrb.physicsBody = SKPhysicsBody(circleOfRadius: orbProperties.size.width / 2)
            // Disbale gravity effects temporarily by assigning an arbitrary categorybitmask temporarily.
            newOrb.physicsBody?.categoryBitMask = 16
        }
        
        if pinch.state == .ended {
            
            if orbArray.count <= 15 {
                
                spawnOrb(orb: newOrb)
                
                orbAdded = true
                
                print("[SandboxScene.swift] Orb spawned at (x: \(Int(newOrb.position.x)), y: \(Int(newOrb.position.y))) of size: \(Int(newOrb.size.width)) and octave range: \(newOrb.octaveRange!).")
            }
            else {
                removeOrb(orb: newOrb, index: orbArray.count - 1)
                
                // ... (else cancel the orb).
                pinch.state = .cancelled
            }
            
            
        }
        
        if pinch.state == .cancelled {
            
            print("[SandboxScene.swift] Orb cancelled.")
        }
    }
    
    // User double tap gesture recogniser target function:
    @objc func doubleTapRecognised(tap: UITapGestureRecognizer) {
        guard tap.view != nil else { return }
        
        // Disable user gestures while tutorial is active and you have not reached the remove orb tutorial prompt.
        if tutorialIsActive {
            if tutorialOverlayActive || tutorialSequenceState < 26 {
                tap.state = .cancelled
                return
            }
        }
        
        tap.numberOfTapsRequired = 2
        
        // After the second tap in the same area...
        if tap.state == .ended {
            
            // Index through each orb within the orb array.
            var i = 0
            for orb in orbArray {
                // If the position on the gesture is inside the area of one of the orbs...
                if sqrt(pow(tap.location(in: tap.view).x - orb.position.x, 2) + pow((0.0 - tap.location(in: tap.view).y) - orb.position.y, 2)) < (orb.size.width / 2) {
                    
                    // ... remove the orb.
                    removeOrb(orb: orbArray[i], index: i)
                    
                    // Stop cycling through array.
                    break
                }
                i += 1
            }
        }
    }
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * SANDBOXSCENE PROTOCOLS * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Function triggered when contact or collision is detected between two SKPhysics bodies:
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Calibrate impulse of collision to around the velocity range.
        var velocity = Int(contact.collisionImpulse / 100000)
        
        // Normalise velocity value for UInt8 MIDI data.
        if velocity > 127 {
            velocity = 127
        }
        
        // Setup two variables to store the contacted bodies.
        let bodyA = contact.bodyA.node!
        let bodyB = contact.bodyB.node!
        
        // Trigger soundscape if collision is between two orbs and if impluse is significant enough.
        // (Prevents notes playing when contact bodies are rolling over each other / velocities of 20 or less.)
        if (bodyA.name == "blueOrb" || bodyA.name == "purpleOrb" || bodyA.name == "redOrb") &&
           (bodyB.name == "blueOrb" || bodyB.name == "purpleOrb" || bodyB.name == "redOrb") &&
           (velocity >= 20) {
            
            orbCollision = true
            
            print("[SandboxScene.swift] Orb collision of impulse: \(Int(contact.collisionImpulse)).")
            
            // Soundscape trigger for orb A:
            
            if let orb = bodyA as? BlueOrb {
                orb.changeEffects(collisionWith: bodyB.name)
                orb.play(velocity: UInt8(velocity))
            }
            
            else if let orb = bodyA as? PurpleOrb {
                orb.changeEffects(collisionWith: bodyB.name)
                orb.play(velocity: UInt8(velocity))
            }
            
            else if let orb = bodyA as? RedOrb {
                orb.changeEffects(collisionWith: bodyB.name)
                orb.play(velocity: UInt8(velocity))
            }
            
            // Soundscape trigger for orb B:
            
            if let orb = bodyB as? BlueOrb {
                orb.changeEffects(collisionWith: bodyA.name)
                orb.play(velocity: UInt8(velocity))
            }
            
            else if let orb = bodyB as? PurpleOrb {
                orb.changeEffects(collisionWith: bodyA.name)
                orb.play(velocity: UInt8(velocity))
            }
            
            else if let orb = bodyB as? RedOrb {
                orb.changeEffects(collisionWith: bodyA.name)
                orb.play(velocity: UInt8(velocity))
            }
        }
    }
    
    // Function triggered when a touch from a user is detected on the scene:
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Guard to ignore all other touches if multiple touches are registered.
        guard let touch = touches.first else { return }
        
        if tutorialOverlayActive {
            // Send touch events to tutorialScene.
            tutorialScene.overlayTouched(touch, with: event)
        }
        else {
            // Take the node at the top of the screen.
            let location = touch.location(in: self)
            let frontTouchedNode = atPoint(location).name
            
            // Dependant on the name of the touched node, perform a program action.
            switch frontTouchedNode {
                
                // Control panel button.
                case "controlPanelIcon":
                    toggleControlPanel()
                
                // Orb selection buttons.
                case "controlPanelBlueOrb":
                    selectOrb(colour: "blue")
                case "controlPanelPurpleOrb":
                    selectOrb(colour: "purple")
                case "controlPanelRedOrb":
                    selectOrb(colour: "red")
                
                // Black hole toggle label.
                case "controlPanelBlackHoleLabel":
                    toggleBlackHole()
                
                // Main menu label.
                case "controlPanelMenuLabel":
                    presentMenuScene()
                
                // Help overlay button.
                case "helpIcon":
                    toggleHelpOverlay()
                
                // Not registered - ignore and break.
                default:
                    break
            }
        }
    }
    
    // Function is called after each frame update:
    override func update(_ currentTime: TimeInterval) {
        
        if tutorialIsActive {
            tutorialScene.update()
        }
        
        orbAdded = false
        orbCollision = false
        
        for orb in orbArray {
            if orb.lightNode.falloff < 12 {
                orb.lightNode.falloff += 0.2
            }
            else {
                orb.lightNode.falloff = 12
            }
        }
        
        // Every 500 frames, ...
        if frameCount >= 500 {
            
            // ... update the frame in each orb.
            updateKey()
            
            // * Note from Developer *
            // - This feature been implemented to help with an AudioKit bug where the orb synths will stop playing after a number of collisions.
            // - It was found that reseting the synth note array helped, but did not fix the issue.
            // - This bug is to be removed in a future update patch.
            
            // Reset frame count.
            frameCount = 0
        }
        
        // Increment frame count.
        frameCount += 1
    }
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PRIVATE CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Visually displays the currently selected orb by fading out other orb buttons:
    private func removeOrb(orb: Orb, index: Int) {
        
        // Disconnect from audio manager and scene.
        orb.orbSynth.disconnectOrbSynthOutput()
        orb.removeAllChildren()
        orb.removeFromParent()
        orb.removeAllActions()
        
        orbArray.remove(at: index)
        
        print("[SandboxScene.swift] Orb Removed - \(orbArray.count) orbs left.")
    }
    
    private func selectOrb(colour: String) {
        let blueOrbButton   = panelParentNode.childNode(withName: "controlPanelBlueOrb")
        let purpleOrbButton = panelParentNode.childNode(withName: "controlPanelPurpleOrb")
        let redOrbButton    = panelParentNode.childNode(withName: "controlPanelRedOrb")
        
        switch colour {
            
        case "blue":
            blueOrbButton?.alpha    = 1.0
            purpleOrbButton?.alpha  = 0.6
            redOrbButton?.alpha     = 0.6
        case "purple":
            blueOrbButton?.alpha    = 0.6
            purpleOrbButton?.alpha  = 1.0
            redOrbButton?.alpha     = 0.6
        case "red":
            blueOrbButton?.alpha    = 0.6
            purpleOrbButton?.alpha  = 0.6
            redOrbButton?.alpha     = 1.0
        default:
            print("[SandboxScene.swift] *** Error *** 'orbSelected' variable not recognised.")
            return
        }
        
        orbSelected = colour
    }
    
    // Spawns an orb to the sandbox by initalising its physics properties and audio:
    private func spawnOrb(orb: Orb) {
        
        // Initalise orb physics.
        orb.initOrbPhysics()
        
        // Update the orb's synth key.
        orb.updateSynthKey(root: keyRoot, tonality: keyTonality)
        
        // Add new orb's synth to the audio mixer.
        orb.orbSynth.connectOrbSynthOutput(to: audioManager.mixer)
    }
    
    // Toggles the black hole gravity effect, triggered by the black hole label in the control panel:
    private func toggleBlackHole() {
        
        // Get the 'controlPanelBlackHoleLabel' node from SandboxScene.
        if let blackHoleLabel = panelParentNode.childNode(withName: "controlPanelBlackHoleLabel") as? SKLabelNode {
            
            // If gravityPoint is enabled, ...
            if blackHoleGravity.isEnabled {
                // Change the label text and disable the radial field.
                blackHoleLabel.text = "BLACK HOLE OFF"
                blackHoleGravity.isEnabled = false
                
                // Set gravity to device accelerometer.
                motionManager.startAccelerometerUpdates(to: OperationQueue.main) {
                    (data, error) in
                    // Setup sandbox gravity to the external device accelerometer.
                    self.physicsWorld.gravity = CGVector(dx: CGFloat((data?.acceleration.x)!) * 2, dy: CGFloat((data?.acceleration.y)!) * 2)
                }
            }
            else {
                // Change the label text and enable the radial field.
                blackHoleLabel.text = "BLACK HOLE ON"
                blackHoleGravity.isEnabled = true
                
                // Stop accelermeter updates.
                motionManager.stopAccelerometerUpdates()
                self.physicsWorld.gravity = .zero
            }
            
            print("[SandboxScene.swift] Black Hole gravity set \(blackHoleGravity.isEnabled)")
        }
    }
    
    // Toggles the help overlay, triggered by the help icon:
    private func toggleHelpOverlay() {
        
        // Get the 'helpOverlay' node from SandboxScene.
        if let helpOverlay = self.childNode(withName: "helpOverlayNode") {
            
            // If overlay is off, fade in.
            if helpOverlay.alpha == 0 {
                helpIcon.texture = SKTexture(imageNamed: "icons_close.png")
                helpOverlay.run(SKAction.fadeIn(withDuration: 0.2))
            }
                // Else if the overlay is on, fade out.
            else if helpOverlay.alpha == 1 {
                helpIcon.texture = SKTexture(imageNamed: "icons_help.png")
                helpOverlay.run(SKAction.fadeOut(withDuration: 0.2))
            }
        }
    }
    
    // Updates all orbs to the new selected key from the data picker:
    private func updateKey() {
        for orb in orbArray {
            orb.updateSynthKey(root: keyRoot, tonality: keyTonality)
        }
    }
    
    private func presentMenuScene() {
        
        // Load the SKScene from 'MenuScene.sks'
        if let menuScene = MenuScene(fileNamed: "MenuScene") {
            
            // Assign weak storage of sandboxScene inside the viewController.
            viewController.setCurrentScene(to: menuScene)
            menuScene.viewController = self.viewController
            
            volSlider.removeFromSuperview()
            keyPicker.removeFromSuperview()
            
            motionManager.stopAccelerometerUpdates()
            audioManager.stop()
            
            // Create SKTransition to crossfade between scenes.
            let transition = SKTransition.crossFade(withDuration: 1)
            transition.pausesOutgoingScene = true
            
            // Present scene to the SKView.
            self.view!.presentScene(menuScene, transition: transition)
        }
    }
    
    // Action function to change the master volume based on the UISlider 'volSlider' value:
    @IBAction private func changeVolume(_ sender: UISlider!) {
        audioManager.setVolume(to: Double(volSlider!.value))
    }
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * DATA PICKER PROTOCOLS * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: pickerData[component][row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        keyRoot = pickerData[0][pickerView.selectedRow(inComponent: 0)]
        keyTonality = pickerData[1][pickerView.selectedRow(inComponent: 1)]
        
        updateKey()
        
        print("[SandboxScene.swift] Scale set to \(keyRoot ?? "ERROR")\(keyTonality ?? " ERROR")")
    }
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * SETTERS / GETTERS * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Sets the tutorial to trigger at initalisation if active:
    public func setTutorialActive(_ bool: Bool) {
        tutorialIsActive = bool
    }
    
    // Toggles the user interaction to be sent to the tutorial scene if active:
    public func setTutorialUserInteraction(_ bool: Bool) {
        tutorialOverlayActive = bool
    }
    
    // Sets the internal integer to keep track of tutorial state:
    public func setTutorialSequenceState(to state: Int) {
        tutorialSequenceState = state
    }
    
    // Returns true when an orb is added to the sandbox:
    public func hasOrbBeenAdded() -> Bool {
        return orbAdded
    }
    
    // Returns true when a collision between two orbs is registered:
    public func hasOrbCollided() -> Bool {
        return orbCollision
    }
    
    // Returns true when the control panel is active:
    public func isControlPanelActive() -> Bool {
        return panelActive
    }
    
    // Returns the array containing all active orbs on the screen:
    public func getOrbArray() -> [Orb] {
        return orbArray
    }
    
    // Returns the current gravity as a CGVector:
    public func getGravity() -> CGVector {
        return self.physicsWorld.gravity
    }
}

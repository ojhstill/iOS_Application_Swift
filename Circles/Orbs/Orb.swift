//
//  Orb.swift
//  Circles
//
//  Created by Y3857872 on 10/10/2019.
//  Copyright © 2019 Y3857872. All rights reserved.
//


// Import Core Libraries
import Foundation
import SpriteKit
import AudioKit

class Orb: SKSpriteNode {

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS VARIABLES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    // Define orb varibles:
    public var orbSynth:    OrbSynth!               // The main audio source for sound generation.
    public var lightNode:   SKLightNode!            // Node containing the dynamic light source in the centre of the orb.
    public var octaveRange: Int!                    // Octave range that the orb's synth is limited to, dependent on the orb's size.
    
    // Define AudioKit effects:
    var reverb:      AKReverb!                      // Reverb effect processing module from AudioKit (originates within OrbSynth).
    var delay:       AKDelay!                       // Delay effect processing module from AudioKit (originates within OrbSynth).
    var flanger:     AKFlanger!                     // Flanger effect processing module from AudioKit (originates within OrbSynth).
    var distortion:  AKDecimator!                   // Distortion effect processing module from AudioKit (originates within OrbSynth).
    var tremolo:     AKTremolo!                     // Tremolo effect processing module from AudioKit (originates within OrbSynth).


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    // Designated init() function:
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        // Set orb defaults.
        self.name = "defaultOrb"
        self.texture = SKTexture(imageNamed: "blueOrbSprite")
        
        // Set default orb light mask values.
        self.lightingBitMask = 1
        
        // Create SKLightNode.
        lightNode = SKLightNode()
        lightNode.categoryBitMask = 1
        lightNode.position = .zero
        lightNode.lightColor = .init(red: 50, green: 75, blue: 255, alpha: 1)
        lightNode.ambientColor = .init(red: 50, green: 75, blue: 255, alpha: 1)
        lightNode.falloff = 12
        lightNode.isEnabled = true
        self.addChild(lightNode)
        
        // Initalise orb synth.
        orbSynth = OrbSynth()
        
        // Access orb synth effect varibles.
        reverb      = self.orbSynth.reverb
        delay       = self.orbSynth.delay
        flanger     = self.orbSynth.flanger
        distortion  = self.orbSynth.distortion
        tremolo     = self.orbSynth.tremolo
        
        // Set key to default.
        updateSynthKey(root: "C", tonality: "maj")
    }
    
    // Convenience init() function:
    public convenience init(position: CGPoint, size: CGSize) {
        
        self.init()
        self.position = position
        self.size = size
        
        // Set orb octave range based on the size of the orb:
        // 1) Subtract the orb's size away from the maxium size.
        // 2) Divide by the size range over the number of octaves.
        // 3) Round down to the nearest integer.
        octaveRange = Int(floor((400 - size.height) / (320 / 6)))
        
        // Set the orb's octave range.
        orbSynth.setOctaveRange(octave: octaveRange)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Triggers the orb synth to play with a given velocity:
    public func play(velocity: UInt8) {
        lightNode.falloff = 10
        orbSynth.playRandom(MIDIVelocity: velocity)
    }
    
    // Updates the synths key from a given root and tonality:
    public func updateSynthKey(root: String!, tonality: String!) {
        orbSynth.setScale(scale: "\(root ?? "C")" + "\(tonality ?? "maj")")
    }
    
    // Sets up the orbs physics properties:
    public func initOrbPhysics() {
        
        // Set sprite node's physics body and gravity properties.
        self.physicsBody!.usesPreciseCollisionDetection = false
        self.physicsBody!.affectedByGravity = true
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.isDynamic = true
        self.physicsBody!.pinned = false
        
        // Calculate mass using volume of sphere equation.
        self.physicsBody!.mass = (4/3) * CGFloat.pi * pow((self.size.width / 2), 3)
        
        // Set sprite node's material properties.
        self.physicsBody!.restitution = 0.8
        self.physicsBody!.linearDamping = 0.4
        self.physicsBody!.angularDamping = 1.0
        self.physicsBody!.friction = 0.0
        
        // Set sprite node's physics mask values.
        self.physicsBody!.categoryBitMask = 1
        self.physicsBody!.collisionBitMask = 1
        self.physicsBody!.fieldBitMask = 1
        self.physicsBody!.contactTestBitMask = 1
    }
}

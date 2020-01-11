//
//  Orb.swift
//  Circles
//
//  Created by Y3857872 on 10/10/2019.
//  Copyright © 2020 Crcl App Studios (Y3857872). All rights reserved.
//


// Import Core Libraries
import Foundation
import SpriteKit
import AudioKit

class Orb: SKSpriteNode {

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS VARIABLES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    // Define orb varibles:
    public var orbSynth:            OrbSynth!               // The main audio source for sound generation.
    public var lightNode:           SKLightNode!            // Node containing the dynamic light source in the centre of the orb.
    
    private var targetDelay:        Double!                 // Target delay dry/wet value for reverb module to adjust to in 'updateOrbEffects' function.
    private var targetReverb:       Double!                 // Target reverb dry/wet value for reverb module to adjust to in 'updateOrbEffects' function.
    private var targetFlanger:      Double!                 // Target flanger dry/wet value for reverb module to adjust to in 'updateOrbEffects' function.
    private var targetDistortion:   Double!                 // Target distortion dry/wet value for reverb module to adjust to in 'updateOrbEffects' function.
    private var targetTremolo:      Double!                 // Target tremolo dry/wet value for reverb module to adjust to in 'updateOrbEffects' function.
    
    // Define AudioKit effects:
    private var reverb:             AKReverb!               // Reverb effect processing module from AudioKit (originates within OrbSynth).
    private var delay:              AKDelay!                // Delay effect processing module from AudioKit (originates within OrbSynth).
    private var flanger:            AKFlanger!              // Flanger effect processing module from AudioKit (originates within OrbSynth).
    private var distortion:         AKDecimator!            // Distortion effect processing module from AudioKit (originates within OrbSynth).
    private var tremolo:            AKTremolo!              // Tremolo effect processing module from AudioKit (originates within OrbSynth).


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
        delay       = self.orbSynth.delay
        reverb      = self.orbSynth.reverb
        flanger     = self.orbSynth.flanger
        distortion  = self.orbSynth.distortion
        tremolo     = self.orbSynth.tremolo
        
        targetDelay = 0
        targetReverb = 0
        targetFlanger = 0
        targetDistortion = 0
        targetTremolo = 0
        
        // Set key to default.
        updateSynthKey(root: "C", tonality: "maj")
    }
    
    // Convenience init() function:
    public convenience init(position: CGPoint, size: CGSize) {
        
        self.init()
        self.position = position
        self.size = size
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Sets up the orbs physics properties:
    public func initOrbPhysics() {
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
        
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
        
        // Set orb octave range based on the size of the orb:
        // 1) Subtract the orb's size away from the maxium size.
        // 2) Divide by the size range over the number of octaves.
        // 3) Round down to the nearest integer.
        let octaveRange = Int(floor((400 - size.height) / (320 / 6)))
        
        // Set the orb's octave range.
        self.orbSynth.setOctaveRange(octave: octaveRange)
    }
    
    // Updates the synths key from a given root and tonality:
    public func updateSynthKey(root: String!, tonality: String!) {
        orbSynth.setScale(scale: "\(root ?? "C")" + "\(tonality ?? "maj")")
    }
    
    // Triggers the orb synth to play with a given velocity:
    public func play(velocity: UInt8) {
        lightNode.falloff = 10
        orbSynth.playRandom(MIDIVelocity: velocity)
    }

    // Grandually changes each effect dryness from the current value to the target value:
    public func updateOrbEffects() {
        
        // Adjust delay dry/wet.
        if delay.dryWetMix < targetDelay {
            delay.dryWetMix += 0.02
        }
        else if delay.dryWetMix > targetDelay {
            delay.dryWetMix -= 0.02
        }
        
        // Adjust reverb dry/wet.
        if reverb.dryWetMix < targetReverb {
            reverb.dryWetMix += 0.02
        }
        else if reverb.dryWetMix > targetReverb {
            reverb.dryWetMix -= 0.02
        }
        
        // Adjust flanger dry/wet.
        if flanger.dryWetMix < targetFlanger {
            flanger.dryWetMix += 0.02
        }
        else if flanger.dryWetMix > targetFlanger {
            flanger.dryWetMix -= 0.02
        }
        
        // Adjust distortion mix.
        if distortion.mix < targetDistortion {
            distortion.mix += 0.02
        }
        else if distortion.mix > targetDistortion {
            distortion.mix -= 0.02
        }
        
        // Adjust tremolo depth.
        if tremolo.depth < targetTremolo {
            tremolo.depth += 0.02
        }
        else if tremolo.depth > targetTremolo {
            tremolo.depth -= 0.02
        }
    }
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * SETTERS / GETTERS * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    public func setTargetDelay(target: Double) {
        targetDelay = target
    }
    
    public func setTargetReverb(target: Double) {
        targetReverb = target
    }
    
    public func setTargetFlanger(target: Double) {
        targetFlanger = target
    }
    
    public func setTargetDistortion(target: Double) {
        targetDistortion = target
    }
    
    public func setTargetTremolo(target: Double) {
        targetTremolo = target
    }
    
    public func setTremoloFreq(freq: Double) {
        tremolo.frequency = freq
    }
}

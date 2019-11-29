//
//  Orb.swift
//  Circles
//
//  Created by Oliver Still on 10/10/2019.
//  Copyright © 2019 Oliver Still. All rights reserved.
//

import Foundation
import SpriteKit
import AudioKit

class Orb: SKSpriteNode {
    
    var orbSynth: OrbSynth!
    private var lightNode: SKLightNode!
    
    /* Designated 'init' function */
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        // Set orb defaults.
        self.name = "defaultOrb"
        self.texture = SKTexture(imageNamed: "blueOrbSprite")
        
        // Create SKLightNode
        lightNode = SKLightNode()
        lightNode.position = .zero
        lightNode.categoryBitMask = 1
        lightNode.lightColor = .init(red: 50, green: 75, blue: 255, alpha: 1)
        lightNode.falloff = 11
        lightNode.isEnabled = true
        self.addChild(lightNode)
        
        // Initalise orb synth.
        orbSynth = OrbSynth()
    }
    
    /* Convenience 'init' function */
    public convenience init(position: CGPoint, size: CGSize) {
        
        self.init()
        self.position = position
        self.size = size
        
        // Create physics body.
        initOrbPhysics()
        
        // Set orb octave range based on the size of the orb:
        // 1) Subtract the orb's size away from the maxium size.
        // 2) Divide by the size range over the number of octaves.
        // 3) Round down to the nearest integer.
        let oct = Int(floor((400 - size.height) / (320 / 6)))
        
        // Set the orb's octave range.
        orbSynth.setOctaveRange(octave: oct)
        
        print("[Orb.swift] Orb spawned at x: \(Int(self.position.x)), y: \(Int(self.position.y)) of size: \(Int(self.size.width)) and mass: \(Int(self.physicsBody!.mass)). Octave range: \(oct)")
    }
    
    public func play(velocity: UInt8){
        orbSynth.playRandom(MIDIVelocity: velocity)
    }
    
    private func initOrbPhysics() {

        // Set sprite node's physics body and gravity properties.
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
        self.physicsBody!.usesPreciseCollisionDetection = true
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
        
        // Set sprite node's light mask values.
        self.lightingBitMask = 1
        self.shadowedBitMask = 0
        self.shadowCastBitMask = 0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

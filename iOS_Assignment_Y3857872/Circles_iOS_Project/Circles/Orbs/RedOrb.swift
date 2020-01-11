//
//  RedOrb.swift
//  Circles
//
//  Created by Y3857872 on 14/10/2019.
//  Copyright © 2020 Crcl App Studios (Y3857872). All rights reserved.
//

// Import Core Libraries
import Foundation
import SpriteKit
import AudioKit

class RedOrb: Orb {

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Designated init() function:
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        // Setup red orb properties.
        self.name = "redOrb"
        self.texture = SKTexture(imageNamed: "redOrbSprite")
        self.lightNode.lightColor = .init(red: 18, green: 75, blue: 50, alpha: 0.5)
        self.lightNode.ambientColor = .white
        self.lightNode.falloff = 12
        
        // Red orb -> Triangle wave.
        self.orbSynth.waveform = AKTable(.triangle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Changes the effects of the orb's synth based on the type of orb that it collides with:
    public func changeEffects(collisionWith orbName: String!) {
        
        switch orbName {
            case "blueOrb":
                // Effect: SOFT CRUSHED DELAY
                setTargetDelay(target: 0.5)
                setTargetReverb(target: 0.7)
                setTargetFlanger(target: 0.0)
                setTargetDistortion(target: 0.2)
                setTargetTremolo(target: 0.0)
                
            case "purpleOrb":
                // Effect: HARD CRUSHED TREMOLO FLANGER
                setTargetDelay(target: 0.2)
                setTargetReverb(target: 0.0)
                setTargetFlanger(target: 0.8)
                setTargetDistortion(target: 0.5)
                setTargetTremolo(target: 0.9)
                
            case "redOrb":
                // Effect: HARD DELAY
                setTargetDelay(target: 0.5)
                setTargetReverb(target: 0.1)
                setTargetFlanger(target: 0.0)
                setTargetDistortion(target: 0.0)
                setTargetTremolo(target: 0.0)
                
            default:
                // Ignore and return.
                return
        }
    }
}

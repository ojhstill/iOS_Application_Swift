//
//  PurpleOrb.swift
//  Circles
//
//  Created by Y3857872 on 24/10/2019.
//  Copyright © 2019 Y3857872. All rights reserved.
//

// Import Core Libraries
import Foundation
import SpriteKit
import AudioKit

class PurpleOrb: Orb {

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Designated init() function:
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        // Setup purple orb properties.
        self.name = "purpleOrb"
        self.texture = SKTexture(imageNamed: "purpleOrbSprite")
        self.lightNode.lightColor = .init(red: 100, green: 60, blue: 120, alpha: 0.40)
        self.lightNode.ambientColor = .white
        self.lightNode.falloff = 12
        
        // Purple orb -> Sawtooth wave.
        self.orbSynth.waveform = AKTable(.sawtooth)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Changes the effects of the orb's synth based on the type of orb that it collides with:
    public func changeEffects(collisionWith orbName: String!) {
        
        switch orbName {
            case "blueOrb":
                // Effect: SOFT TREMOLO FLANGER
                setTargetDelay(target: 0.0)
                setTargetReverb(target: 0.6)
                setTargetFlanger(target: 0.7)
                setTargetDistortion(target: 0.0)
                setTargetTremolo(target: 0.6)
                setTremoloFreq(freq: 2.0)
                
            case "purpleOrb":
                // Effect: FAST TREMOLO
                setTargetDelay(target: 0.3)
                setTargetReverb(target: 0.0)
                setTargetFlanger(target: 0.0)
                setTargetDistortion(target: 0.0)
                setTargetTremolo(target: 1.0)
                setTremoloFreq(freq: 6.0)
                
            case "redOrb":
                // Effect: SOFT TREMOLO DELAY
                setTargetDelay(target: 0.4)
                setTargetReverb(target: 0.2)
                setTargetFlanger(target: 0.0)
                setTargetDistortion(target: 0.1)
                setTargetTremolo(target: 0.6)
                setTremoloFreq(freq: 2.0)
            
            default:
                // Ignore and return.
                return
        }
    }
}

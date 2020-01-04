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
        
        self.name = "purpleOrb"
        self.texture = SKTexture(imageNamed: "purpleOrbSprite")
        self.lightNode.lightColor = .init(red: 50, green: 75, blue: 255, alpha: 0.65)
        self.lightNode.ambientColor = .white
        self.lightNode.falloff = 12
        
        self.orbSynth.waveform = AKTable(.positiveSawtooth)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    public func changeEffects(collisionWith orbName: String!) {
        
        // Change the effects of the orb's synth based on the type of orb that it collides with.
        switch orbName {
            case "blueOrb":
                // Effect: SOFT TREMOLO FLANGER
                reverb.dryWetMix    = 0.6
                delay.dryWetMix     = 0.0
                flanger.depth       = 0.7
                distortion.mix      = 0.0
                tremolo.depth       = 0.6
                tremolo.frequency   = 2.0
                
            case "purpleOrb":
                // Effect: FAST TREMOLO
                reverb.dryWetMix    = 0.0
                delay.dryWetMix     = 0.0
                flanger.depth       = 0.0
                distortion.mix      = 0.0
                tremolo.depth       = 1.0
            
                tremolo.frequency   = 6.0
                
            case "redOrb":
                // Effect: SOFT TREMOLO DELAY
                reverb.dryWetMix    = 0.2
                delay.dryWetMix     = 0.4
                flanger.depth       = 0.0
                distortion.mix      = 0.1
                tremolo.depth       = 0.6
                tremolo.frequency   = 2.0
                
            default:
                // Ignore and return.
                return
        }
    }
}

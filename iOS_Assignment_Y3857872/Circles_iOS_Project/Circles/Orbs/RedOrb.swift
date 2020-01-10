//
//  RedOrb.swift
//  Circles
//
//  Created by Y3857872 on 14/10/2019.
//  Copyright © 2019 Y3857872. All rights reserved.
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
        
        self.name = "redOrb"
        self.texture = SKTexture(imageNamed: "redOrbSprite")
        self.lightNode.lightColor = .init(red: 255, green: 75, blue: 50, alpha: 0.5)
        self.lightNode.ambientColor = .white
        self.lightNode.falloff = 12
        
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
                reverb.dryWetMix    = 0.7
                delay.dryWetMix     = 0.5
                flanger.depth       = 0.0
                distortion.mix      = 0.2
                tremolo.depth       = 0.0
                
            case "purpleOrb":
                // Effect: HARD CRUSHED TREMOLO FLANGER
                reverb.dryWetMix    = 0.0
                delay.dryWetMix     = 0.2
                flanger.depth       = 0.8
                distortion.mix      = 0.5
                tremolo.depth       = 0.9
                
            case "redOrb":
                // Effect: HARD DELAY
                reverb.dryWetMix    = 0.1
                delay.dryWetMix     = 0.5
                flanger.depth       = 0.0
                distortion.mix      = 0.0
                tremolo.depth       = 0.0
                
            default:
                // Ignore and return.
                return
        }
    }
}

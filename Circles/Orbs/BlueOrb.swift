//
//  BlueOrb.swift
//  Circles
//
//  Created by Y3857872 on 14/10/2019.
//  Copyright © 2019 Y3857872. All rights reserved.
//

// Import Core Libraries
import Foundation
import SpriteKit
import AudioKit

class BlueOrb: Orb {

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Designated init() function:
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.name = "blueOrb"
        self.texture = SKTexture(imageNamed: "blueOrbSprite")
        self.lightNode.lightColor = .init(red: 50, green: 75, blue: 255, alpha: 1)
        self.lightNode.ambientColor = .white
        self.lightNode.falloff = 12
        
        self.orbSynth.waveform = AKTable(.sine)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    public func changeEffects(collisionWith orbName: String!) {
        
        // Change the effects of the orb's synth based on the type of orb that it collides with.
        switch orbName {
            case "blueOrb":
                // Effect: SOFT REVERB
                reverb.dryWetMix    = 1.0
                delay.dryWetMix     = 0.2
                flanger.depth       = 0.0
                distortion.mix      = 0.0
                tremolo.depth       = 0.1
            
            case "purpleOrb":
                // Effect: SOFT TREMOLO REVERB
                reverb.dryWetMix    = 0.3
                delay.dryWetMix     = 0.0
                flanger.depth       = 0.6
                distortion.mix      = 0.0
                tremolo.depth       = 1.0
            
            case "redOrb":
                // Effect: SOFT CRUSHED REVERB
                reverb.dryWetMix    = 0.6
                delay.dryWetMix     = 0.2
                flanger.depth       = 0.0
                distortion.mix      = 0.2
                tremolo.depth       = 0.1
            
            default:
                // Ignore and return.
                return
        }
    }
}

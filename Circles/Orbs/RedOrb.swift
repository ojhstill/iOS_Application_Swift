//
//  RedOrb.swift
//  Circles
//
//  Created by Oliver Still on 14/10/2019.
//  Copyright © 2019 Oliver Still. All rights reserved.
//

import Foundation
import SpriteKit
import AudioKit

class RedOrb: Orb {
    
    public var reverb:  AKReverb!
    public var delay:   AKDelay!
    public var tremolo: AKTremolo!
    
    /* Designated 'init' function. */
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.name = "redOrb"
        self.texture = SKTexture(imageNamed: "redOrbSprite")
        self.lightNode.lightColor = .init(red: 255, green: 50, blue: 75, alpha: 0.5)
        self.lightNode.ambientColor = .white
        self.lightNode.categoryBitMask = 3
        self.lightingBitMask = 3
        self.shadowedBitMask = 3
        
        self.orbSynth.waveform = AKTable(.triangle)
        
        reverb = self.orbSynth.reverb
        reverb.dryWetMix = 0.6
        reverb.loadFactoryPreset(.largeHall)
        
        delay = self.orbSynth.delay
        delay.dryWetMix = 0.3
        delay.feedback = 0.6
        delay.time = 0.2
        
        tremolo = self.orbSynth.tremolo
        tremolo.depth = 0.1
        tremolo.frequency = 4
    }
    
    public func changeEffects(collisionWith orbName: String!) {
        
        // Change the effects of the orb's synth based on the type of orb that it collides with.
        switch orbName {
        case "blueOrb":
            // Effect: SOFT REVERB
            reverb.dryWetMix = 0.9
            delay.dryWetMix = 0.0
            tremolo.frequency = 1
            tremolo.depth = 0.3
            
        case "purpleOrb":
            // Effect: SOFT TREMOLO
            reverb.dryWetMix = 0.7
            delay.dryWetMix = 0.0
            tremolo.frequency = 2
            tremolo.depth = 0.9
            
        case "redOrb":
            // Effect: SOFT DELAY
            reverb.dryWetMix = 0.4
            delay.dryWetMix = 0.9
            tremolo.depth = 0.0
            
        default:
            // Ignore and return.
            return
        }
    }
        
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS VARIABLES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    public var reverb:      AKReverb!                   //
    public var delay:       AKDelay!                    //
    public var tremolo:     AKTremolo!                  //


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Designated init() function:
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.name = "purpleOrb"
        self.texture = SKTexture(imageNamed: "purpleOrbSprite")
        self.lightNode.lightColor = .init(red: 255, green: 75, blue: 255, alpha: 0.5)
        self.lightNode.ambientColor = .white
        self.lightNode.categoryBitMask = 2
        self.lightingBitMask = 2
        self.shadowedBitMask = 2
        
        self.orbSynth.waveform = AKTable(.positiveSawtooth)
        
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
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    public func changeEffects(collisionWith orbName: String!) {
        
        // Change the effects of the orb's synth based on the type of orb that it collides with.
        switch orbName {
            case "blueOrb":
                // Effect: SOFT REVERB
                reverb.dryWetMix    = 0.9
                delay.dryWetMix     = 0.0
                tremolo.frequency   = 1.0
                tremolo.depth       = 0.3
                
            case "purpleOrb":
                // Effect: SOFT TREMOLO
                reverb.dryWetMix    = 0.7
                delay.dryWetMix     = 0.0
                tremolo.frequency   = 2.0
                tremolo.depth       = 0.9
                
            case "redOrb":
                // Effect: SOFT DELAY
                reverb.dryWetMix    = 0.4
                delay.dryWetMix     = 0.9
                tremolo.depth       = 0.0
                
            default:
                // Ignore and return.
                return
        }
    }
}

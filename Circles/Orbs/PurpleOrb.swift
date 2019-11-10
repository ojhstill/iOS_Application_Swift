//
//  PurpleOrb.swift
//  Circles
//
//  Created by Oliver Still on 24/10/2019.
//  Copyright © 2019 Oliver Still. All rights reserved.
//

import Foundation
import SpriteKit
import AudioKit

class PurpleOrb: Orb {
    
    /* Designated 'init' function. */
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        self.name = "purpleOrb"
        self.texture = SKTexture(imageNamed: "purpleOrbSprite")
        self.orbSynth.waveform = AKTable(.square)
        
        let reverb = self.orbSynth.reverb
        reverb?.dryWetMix = 0.6
        reverb?.loadFactoryPreset(.largeHall)
        
        let delay = self.orbSynth.delay
        delay?.dryWetMix = 0.3
        delay?.feedback = 0.6
        delay?.time = 0.2
        
        let tremolo = self.orbSynth.tremolo
        tremolo?.depth = 0.1
        tremolo?.frequency = 4
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


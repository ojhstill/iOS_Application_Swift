//
//  BlueOrb.swift
//  Circles
//
//  Created by Y3857872 on 14/10/2019.
//  Copyright © 2020 Crcl App Studios (Y3857872). All rights reserved.
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
        
        // Setup blue orb properties.
        self.name = "blueOrb"
        self.texture = SKTexture(imageNamed: "blueOrbSprite")
        self.lightNode.lightColor = .init(red: 50, green: 75, blue: 255, alpha: 0.8)
        self.lightNode.ambientColor = .white
        self.lightNode.falloff = 12
        
        // Blue orb -> Sine wave.
        self.orbSynth.waveform = AKTable(.sine)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Changes the effects of the orb's synth based on the type of orb that it collides with:
    public func changeEffects(collisionWith orbName: String!) {
        
        switch orbName {
            case "blueOrb":
                // Effect: SOFT REVERB
                setTargetDelay(target: 0.2)
                setTargetReverb(target: 1.0)
                setTargetFlanger(target: 0.0)
                setTargetDistortion(target: 0.0)
                setTargetTremolo(target: 0.1)
            
            case "purpleOrb":
                // Effect: SOFT TREMOLO REVERB
                setTargetDelay(target: 0.0)
                setTargetReverb(target: 0.3)
                setTargetFlanger(target: 0.6)
                setTargetDistortion(target: 0.0)
                setTargetTremolo(target: 1.0)
            
            case "redOrb":
                // Effect: SOFT CRUSHED REVERB
                setTargetDelay(target: 0.2)
                setTargetReverb(target: 0.6)
                setTargetFlanger(target: 0.0)
                setTargetDistortion(target: 0.1)
                setTargetTremolo(target: 0.1)
            
            default:
                // Ignore and return.
                return
        }
    }
}

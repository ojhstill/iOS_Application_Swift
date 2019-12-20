//
//  Soundscape.swift
//  Circles
//
//  Created by Oliver Still on 09/10/2019.
//  Copyright © 2019 Oliver Still. All rights reserved.
//

import Foundation
import AudioKit

open class AudioManager {
    
    /* CLASS VARIABLES */
    
    var mixer: AKMixer!
    
    
    /* INIT() */
    
    init() {
        
        // Setup mixer to AudioKit's master.
        mixer = AKMixer()
        
        // Precautionary limiter to prevent clipping distortion.
        let limiter = AKPeakLimiter(mixer, attackDuration: 0.0, decayDuration: 0.1, preGain: 0.0)
        
        // Start AudioKit.
        AudioKit.output = limiter
        try!AudioKit.start()
    }
    
    open func addAudioInput(input: AKNode) {
        mixer.connect(input: input)
    }
    
    open func setVolume(to volume: Double) {
        mixer.volume = volume
    }
    
}

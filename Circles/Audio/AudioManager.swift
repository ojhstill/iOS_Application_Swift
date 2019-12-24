//
//  Soundscape.swift
//  Circles
//
//  Created by Y3857872 on 09/10/2019.
//  Copyright © 2019 Y3857872. All rights reserved.
//

// Import Core Libraries
import Foundation
import AudioKit

open class AudioManager {
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS VARIABLES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Define audio manager varibles:
    var mixer: AKMixer!                     // AKMixer to connect multiple audio sources to the AudioKit output.


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    init() {
        
        // Setup mixer to AudioKit's master.
        mixer = AKMixer()
        
        // Precautionary master limiter to prevent clipping distortion.
        let limiter = AKPeakLimiter(mixer, attackDuration: 0.0, decayDuration: 0.1, preGain: 0.0)
        
        // Start AudioKit.
        AudioKit.output = limiter
        try!AudioKit.start()
    }

    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    public func addAudioInput(input: AKNode) {
        mixer.connect(input: input)
    }
    

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * SETTERS / GETTERS * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    public func setVolume(to volume: Double) {
        mixer.volume = volume
    }
    
}

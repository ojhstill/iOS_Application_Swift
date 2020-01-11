//
//  Soundscape.swift
//  Circles
//
//  Created by Y3857872 on 09/10/2019.
//  Copyright © 2020 Crcl App Studios (Y3857872) All rights reserved.
//

// Import Core Libraries
import Foundation
import AudioKit

open class AudioManager {
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS VARIABLES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Define audio manager varibles:
    var mixer:      AKMixer!                // AKMixer to connect multiple audio sources to the AudioKit output.
    var ambience:   AKReverb!               // AKReverb module to add ambience to the produced sound.


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

    init() {
        // Setup mixer to AudioKit's master.
        mixer = AKMixer()
        
        // Setup ambience.
        ambience = AKReverb()
        mixer.setOutput(to: ambience)
        ambience.dryWetMix = 0.2
        ambience.loadFactoryPreset(.largeHall)
    }

    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Add a new audio AKNode input to the mixer:
    public func addAudioInput(input: AKNode) {
        mixer.connect(input: input)
    }
    
    // Start the audio engine:
    public func start() {
        // Precautionary master limiter to prevent clipping distortion.
        let limiter = AKPeakLimiter(ambience, attackDuration: 0.0, decayDuration: 0.1, preGain: 0.0)
        
        // Start AudioKit.
        AudioKit.output = limiter
        try!AudioKit.start()
    }
    
    // Stop the audio engine:
    public func stop() {
        mixer.disconnectInput()
        AudioKit.disconnectAllInputs()
        try!AudioKit.stop()
    }
    

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * SETTERS / GETTERS * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Set the master volume of the application audio, set by the UISlider in the control panel:
    public func setVolume(to volume: Double) {
        mixer.volume = volume
    }
    
}

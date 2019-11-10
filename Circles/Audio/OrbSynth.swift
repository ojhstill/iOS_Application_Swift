//
//  OrbSynth.swift
//  Circles
//
//  Created by Oliver Still on 23/10/2019.
//  Copyright © 2019 Oliver Still. All rights reserved.
//

import Foundation
import AudioKit

class OrbSynth: AKFMOscillatorBank {
    
    // Define class variables.
    var MIDINoteArray: [Int]!
    
    // Define AudioKit effects.
    var reverb:  AKReverb!
    var delay:   AKDelay!
    var tremolo: AKTremolo!
    
    // Define internal class constants and dictionaries.
    let freqNoteValues = ["A": 220.00, "A#": 233.08, "Bb": 233.08, "B": 246.94,
                          "C": 261.63, "C#": 277.18, "Db": 277.18,
                          "D": 293.66, "D#": 311.13, "Eb": 311.13, "E": 329.63,
                          "F": 349.23, "F#": 369.99, "Gb": 369.99,
                          "G": 392.00, "G#": 415.30, "Ab": 415.30]
    
    let freqOctMultiplier = [0.25, 0.50, 0.00, 2.00]
    
    let MIDINoteValues = ["A": 57, "A#": 58, "Bb": 58, "B": 59,
                          "C": 60, "C#": 61, "Db": 61,
                          "D": 62, "D#": 63, "Eb": 63, "E": 64,
                          "F": 65, "F#": 66, "Gb": 66,
                          "G": 67, "G#": 68, "Ab": 68]
    
    let MIDIOctSelect = [-2, -1, 0, 1]
    
    /* Designated 'init' function. */
    public override init(waveform: AKTable, carrierMultiplier: Double = 1, modulatingMultiplier: Double = 1, modulationIndex: Double = 1, attackDuration: Double = 0.1, decayDuration: Double = 0.1, sustainLevel: Double = 1, releaseDuration: Double = 0.1, pitchBend: Double = 0, vibratoDepth: Double = 0, vibratoRate: Double = 0) {
        super.init(waveform: waveform, carrierMultiplier: carrierMultiplier, modulatingMultiplier: modulatingMultiplier, modulationIndex: modulationIndex, attackDuration: attackDuration, decayDuration: decayDuration, sustainLevel: sustainLevel, releaseDuration: releaseDuration, pitchBend: pitchBend, vibratoDepth: vibratoDepth, vibratoRate: vibratoRate)
        
        // Set ASDR properties for FM synth.
        self.attackDuration  = 0.05
        self.decayDuration   = 0.30
        self.sustainLevel    = 0.00
        self.releaseDuration = 0.05
        self.rampDuration    = 0.00
        
        // Initalise AudioKit effect parameters.
        delay   = AKDelay()
        reverb  = AKReverb()
        tremolo = AKTremolo()
        
        // Setup MIDI array for the chosen synth scale.
        MIDINoteArray = [Int]()
        
        // Set synth defaults.
        self.setScale(scale: ["A", "C", "D", "E", "G"])
        self.waveform = AKTable(.sine)
        
        // Link audio outputs
        self.setOutput(to: delay)
        delay.setOutput(to: reverb)
        reverb.setOutput(to: tremolo)
    }
    
    func setScale(scale: [String]) {
        
        // Reset MIDI note array.
        MIDINoteArray.removeAll()
        
        // Cycle through each note in given scale, ...
        for note in scale {
            // ... check if it is valid within the MIDI note dictionary, ...
            if MIDINoteValues[note] != nil {
                // ... add the respective note to MIDI note array.
                MIDINoteArray.append(MIDINoteValues[note]!)
            }
            else {
                // If note given is not found within dictionary, print the error.
                print("[OrbSynth.swift] ERROR: Note selection '\(String(describing: note))' in scale not avalible.")
            }
        }
    }
    
    func playRandom(MIDIVelocity: UInt8) {
        
        // Check is MIDI note array is not empty.
        if MIDINoteArray.count != 0 {
            
            // Randomise the note within the specified scale and the octave.
            let note   = Int.random(in: 0 ..< MIDINoteArray.count)
            let octave = Int.random(in: 0 ..< MIDIOctSelect.count)
            
            // Combine the note and octave as a MIDI note with type UInt8 for the synth.
            let MIDINote = MIDINoteNumber(MIDINoteArray[note] + (MIDIOctSelect[octave] * 12))
            
            // If note selection is already playing, stop the synth.
            self.stop(noteNumber: MIDINote)
            
            // Play the note selection with the secified velocity.
            self.play(noteNumber: MIDINote, velocity: MIDIVelocity)
            
            // Print note data to console.
            print("[OrbSynth.swift] Playing note: \(MIDINote) of velocity \(MIDIVelocity)")
        }
    }
    
    public func connectOrbSynthOutput(to node: AKInput) {
        tremolo.setOutput(to: node)
    }
    
    public func disconnectOrbSynthOutput() {
        tremolo.disconnectOutput()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

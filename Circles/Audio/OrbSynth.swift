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
    
    /* CLASS VARIABLES */
    
    // Define class variables.
    private var MIDINoteArray: [Int]!
    private var octaveRange: Int!
    
    // Define AudioKit effects.
    var reverb:  AKReverb!
    var delay:   AKDelay!
    var tremolo: AKTremolo!
    
    
    /* CLASS CONSTANTS */
    
    // MIDI note value dictionary from C0 to B0.
    let MIDINoteValues = ["C": 12, "Db": 13, "D": 14, "Eb": 15, "E": 16, "F": 17, "Gb": 18, "G": 19, "Ab": 20, "A": 21, "Bb": 22, "B": 23]
    
    let scales = ["Cmaj":  ["A",  "C",  "D",  "E",  "G" ], "Amin":  ["A",  "C",  "D",  "E",  "G" ],
                  "Dbmaj": ["Bb", "Db", "Eb", "F",  "Ab"], "Bbmin": ["Bb", "Db", "Eb", "F",  "Ab"],
                  "Dmaj":  ["B",  "D",  "E",  "Gb", "A" ], "Bmin":  ["B",  "D",  "E",  "Gb", "A" ],
                  "Ebmaj": ["C",  "Eb", "F",  "G",  "Bb"], "Cmin":  ["C",  "Eb", "F",  "G",  "Bb"],
                  "Emaj":  ["Db", "E",  "Gb", "Ab", "B" ], "Dbmin": ["Db", "E",  "Gb", "Ab", "B" ],
                  "Fmaj":  ["D",  "F",  "G",  "A",  "C" ], "Dmin":  ["D",  "F",  "G",  "A",  "C" ],
                  "Gbmaj": ["Eb", "Gb", "Ab", "Bb", "Db"], "Ebmin": ["Eb", "Gb", "Ab", "Bb", "Db"],
                  "Gmaj":  ["E",  "G",  "A",  "B",  "D" ], "Emin":  ["E",  "G",  "A",  "B",  "D" ],
                  "Abmaj": ["F",  "Ab", "Bb", "C",  "Eb"], "Fmin":  ["F",  "Ab", "Bb", "C",  "Eb"],
                  "Amaj":  ["Gb", "A",  "B",  "Db", "E" ], "Gbmin": ["Gb", "A",  "B",  "Db", "E" ],
                  "Bbmaj": ["G",  "Bb", "C",  "D",  "F" ], "Gmin":  ["G",  "Bb", "C",  "D",  "F" ],
                  "Bmaj":  ["Ab", "B",  "Db", "Eb", "Gb"], "Abmin": ["Ab", "B",  "Db", "Eb", "Gb"]]
    
    /* DESIGNATED INIT() FUNCTION. */
    
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
        self.setScale(scale: "Cmaj")
        self.waveform = AKTable(.sine)
        
        // Link audio outputs
        self.setOutput(to: delay)
        delay.setOutput(to: reverb)
        reverb.setOutput(to: tremolo)
    }
    
    func setScale(scale: String) {
        
        print("[OrbSynth.swift] Scale set to \(scale)")
        
        let notes = scales[scale]!
        
        // Reset MIDI note array.
        MIDINoteArray.removeAll()
        
        // Cycle through each note in given scale, ...
        for note in notes {
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
            let note = Int.random(in: 0 ..< MIDINoteArray.count)
            
            // Combine the note and octave as a MIDI note with type UInt8 for the synth.
            let MIDINote = MIDINoteNumber(MIDINoteArray[note] + (octaveRange * 12))
            
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
    
    public func setOctaveRange(octave: Int) {
        octaveRange = octave
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  OrbSynth.swift
//  Circles
//
//  Created by Y3857872 on 23/10/2019.
//  Copyright © 2019 Y3857872. All rights reserved.
//

// Import Core Libraries
import Foundation
import AudioKit

class OrbSynth: AKFMOscillatorBank {
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS VARIABLES * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Define orb synth variables:
    private var MIDINoteArray:  [Int]!                  // Array containing the MIDI note values to play, defined by the chosen key.
    private var octaveRange:    Int!                    // The octave range multiplier defined by the respective size of the orb.
    
    // Define AudioKit effects:
    public var reverb:                 AKReverb!               // Reverb effect processing module from AudioKit.
    public var delay:                  AKDelay!                // Delay effect processing module from AudioKit.
    public var flanger:                AKFlanger!              // Flanger effect processing module from AudioKit.
    public var distortion:             AKDecimator!            // Distortion effect processing module from AudioKit.
    public var tremolo:                AKTremolo!              // Tremolo effect processing module from AudioKit.
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * CLASS CONSTANTS * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // MIDI note value dictionary from C0 to B0.
    let MIDINoteValues = ["C": 12, "Db": 13, "D": 14, "Eb": 15, "E": 16, "F": 17, "Gb": 18, "G": 19, "Ab": 20, "A": 21, "Bb": 22, "B": 23]
    
    // Dictionary containing the required notes for each respective scale.
    let scales = ["Cmaj":  ["A" , "C" , "D" , "E" , "G" ], "Amin":  ["A" , "C" , "D" , "E" , "G" ],
                  "Dbmaj": ["Bb", "Db", "Eb", "F" , "Ab"], "Bbmin": ["Bb", "Db", "Eb", "F" , "Ab"],
                  "Dmaj":  ["B" , "D" , "E" , "Gb", "A" ], "Bmin":  ["B" , "D" , "E" , "Gb", "A" ],
                  "Ebmaj": ["C" , "Eb", "F" , "G" , "Bb"], "Cmin":  ["C" , "Eb", "F" , "G" , "Bb"],
                  "Emaj":  ["Db", "E" , "Gb", "Ab", "B" ], "Dbmin": ["Db", "E" , "Gb", "Ab", "B" ],
                  "Fmaj":  ["D" , "F" , "G" , "A" , "C" ], "Dmin":  ["D" , "F" , "G" , "A" , "C" ],
                  "Gbmaj": ["Eb", "Gb", "Ab", "Bb", "Db"], "Ebmin": ["Eb", "Gb", "Ab", "Bb", "Db"],
                  "Gmaj":  ["E" , "G" , "A" , "B" , "D" ], "Emin":  ["E" , "G" , "A" , "B" , "D" ],
                  "Abmaj": ["F" , "Ab", "Bb", "C" , "Eb"], "Fmin":  ["F" , "Ab", "Bb", "C" , "Eb"],
                  "Amaj":  ["Gb", "A" , "B" , "Db", "E" ], "Gbmin": ["Gb", "A" , "B" , "Db", "E" ],
                  "Bbmaj": ["G" , "Bb", "C" , "D" , "F" ], "Gmin":  ["G" , "Bb", "C" , "D" , "F" ],
                  "Bmaj":  ["Ab", "B" , "Db", "Eb", "Gb"], "Abmin": ["Ab", "B" , "Db", "Eb", "Gb"]]
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * INIT() * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Designated init() function:
    public override init(waveform: AKTable, carrierMultiplier: Double = 1, modulatingMultiplier: Double = 1, modulationIndex: Double = 1, attackDuration: Double = 0.1, decayDuration: Double = 0.1, sustainLevel: Double = 1, releaseDuration: Double = 0.1, pitchBend: Double = 0, vibratoDepth: Double = 0, vibratoRate: Double = 0) {
        super.init(waveform: waveform, carrierMultiplier: carrierMultiplier, modulatingMultiplier: modulatingMultiplier, modulationIndex: modulationIndex, attackDuration: attackDuration, decayDuration: decayDuration, sustainLevel: sustainLevel, releaseDuration: releaseDuration, pitchBend: pitchBend, vibratoDepth: vibratoDepth, vibratoRate: vibratoRate)
        
        // Set ASDR properties for FM synth.
        self.attackDuration  = 0.05
        self.decayDuration   = 0.30
        self.sustainLevel    = 0.00
        self.releaseDuration = 0.05
        self.rampDuration    = 0.00
        
        // Initalise AudioKit effect parameters.
        delay = AKDelay()
        delay.dryWetMix = 0.0
        delay.feedback = 0.7
        delay.time = 0.6
        
        reverb = AKReverb()
        reverb.dryWetMix = 0.0
        reverb.loadFactoryPreset(.largeHall)
        
        flanger = AKFlanger()
        flanger.dryWetMix = 0.0
        flanger.depth = 1.0
        flanger.frequency = 0.3
        flanger.feedback = 0.6

        distortion = AKDecimator()
        distortion.mix = 0.0
        distortion.decimation = 0.08
        
        tremolo = AKTremolo()
        tremolo.depth = 0.0
        tremolo.frequency = 3.0
        
        // Setup MIDI array for the chosen synth scale.
        MIDINoteArray = [Int]()
        
        // Set synth defaults.
        self.setScale(scale: "Cmaj")
        self.waveform = AKTable(.sine)
        
        // Link audio outputs.
        self.setOutput(to: delay)
        delay.setOutput(to: reverb)
        reverb.setOutput(to: flanger)
        flanger.setOutput(to: distortion)
        distortion.setOutput(to: tremolo)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * PUBLIC CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Connect the synth's output to the given AKInput node:
    public func connectOrbSynthOutput(to node: AKInput) {
        tremolo.setOutput(to: node)
    }
    
    // Disconnect the synth's output:
    public func disconnectOrbSynthOutput() {
        tremolo.disconnectOutput()
    }
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * INTERNAL CLASS FUNCTIONS * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Set the selection of notes to play defined within the scales dictionary:
    func setScale(scale: String) {
        
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
    
    // Play random note within set scale at defined velocity:
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
    
    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * SETTERS / GETTERS * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
    
    // Set the octave range for the orb to play in, defined by the size of the orb:
    public func setOctaveRange(octave: Int) {
        octaveRange = octave
    }
}

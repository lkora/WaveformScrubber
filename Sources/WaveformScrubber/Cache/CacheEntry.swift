//
//  CacheEntry.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

/// An entry in the waveform cache.
final class CacheEntry {
    /// The original, full-resolution samples extracted from the audio file.
    let fullSamples: [Float]

    init(fullSamples: [Float]) {
        self.fullSamples = fullSamples
    }
}

//
//  WaveformDrawing.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

public protocol WaveformDrawing: Sendable {
    /// Draws the waveform path based on the provided samples.
    /// - Parameters:
    ///   - samples: The normalized audio samples (typically from 0.0 to 1.0).
    ///   - rect: The `CGRect` in which to draw the path.
    /// - Returns: A `Path` representing the waveform.
    func draw(samples: [Float], in rect: CGRect) -> Path

    /// Calculates the required number of samples to properly render the waveform within a given size.
    ///
    /// This allows different drawing strategies to request the appropriate level of detail.
    /// For example, a bar drawer will request a different number of samples than a line drawer.
    /// - Parameter size: The size of the view that will be rendering the waveform.
    /// - Returns: The optimal number of samples for the drawing strategy.
    func sampleCount(for size: CGSize) -> Int
}

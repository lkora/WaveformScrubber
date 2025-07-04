//
//  WaveformScrubberStyle.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

/// A type that specifies the appearance and interaction of a waveform scrubber.
public protocol WaveformScrubberStyle: Sendable {
    /// A view that represents the body of a waveform scrubber.
    associatedtype Body: View

    /// Creates a view that represents the body of a waveform scrubber.
    ///
    /// The system calls this method for each `WaveformScrubber` instance in a view
    /// hierarchy where this style is the current waveform scrubber style.
    /// - Parameter configuration: The properties of the waveform scrubber.
    @ViewBuilder func makeBody(configuration: Self.Configuration) -> Self.Body

    /// The properties of a waveform scrubber.
    typealias Configuration = WaveformScrubberStyleConfiguration
}

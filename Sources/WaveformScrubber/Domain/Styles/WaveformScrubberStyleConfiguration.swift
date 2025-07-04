//
//  WaveformScrubberStyleConfiguration.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

/// The properties of a waveform scrubber, used to create a custom style.
public struct WaveformScrubberStyleConfiguration {
    /// A shape representing the entire waveform.
    /// You can apply styling like `.fill()` or `.stroke()` to this shape.
    public let waveform: AnyShape

    /// A view representing the masked "active" portion of the waveform, determined by the scrubber's progress.
    /// This view is already clipped. You can apply styling directly to it.
    public let activeWaveform: AnyView

    /// A view representing the "inactive" portion of the waveform.
    /// This view is also pre-masked. Apply styling directly.
    public let inactiveWaveform: AnyView
}

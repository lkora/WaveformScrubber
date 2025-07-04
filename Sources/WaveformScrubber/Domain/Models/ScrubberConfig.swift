//
//  ScrubberConfig.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/3/25.
//

import SwiftUI

/// Configuration for the appearance of the WaveformScrubber.
public struct ScrubberConfig<ActiveStyle: ShapeStyle, InactiveStyle: ShapeStyle>: Sendable {
    public let activeTint: ActiveStyle
    public let inactiveTint: InactiveStyle

    /// Creates a new configuration for the waveform's appearance.
    /// - Parameters:
    ///   - activeStyle: The style for the played (active) part of the waveform.
    ///   - inactiveStyle: The style for the unplayed (inactive) part of the waveform.
    public init(activeTint: ActiveStyle, inactiveTint: InactiveStyle) {
        self.activeTint = activeTint
        self.inactiveTint = inactiveTint
    }
}

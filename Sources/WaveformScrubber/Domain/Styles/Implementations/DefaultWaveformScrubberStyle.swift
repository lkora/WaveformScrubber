//
//  DefaultWaveformScrubberStyle.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

/// The default style for a `WaveformScrubber`.
/// This style fills the active and inactive parts of the waveform with the specified styles.
public struct DefaultWaveformScrubberStyle<Active: ShapeStyle, Inactive: ShapeStyle>: WaveformScrubberStyle {
    private let activeStyle: Active
    private let inactiveStyle: Inactive

    public init(active: Active, inactive: Inactive) {
        self.activeStyle = active
        self.inactiveStyle = inactive
    }

    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // The configuration provides a pre-masked inactive part.
            configuration.inactiveWaveform
                .foregroundStyle(inactiveStyle)
            
            // The configuration provides a pre-masked active part.
            configuration.activeWaveform
                .foregroundStyle(activeStyle)
        }
    }
}

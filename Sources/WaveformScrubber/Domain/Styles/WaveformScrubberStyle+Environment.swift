//
//  WaveformScrubberStyle+Environment.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

private struct WaveformScrubberStyleKey: EnvironmentKey {
    // The default style is a fill with primary/secondary colors
    static let defaultValue: any WaveformScrubberStyle = DefaultWaveformScrubberStyle(
        active: Color.accentColor,
        inactive: Color.secondary.opacity(0.5)
    )
}

extension EnvironmentValues {
    var waveformScrubberStyle: any WaveformScrubberStyle {
        get { self[WaveformScrubberStyleKey.self] }
        set { self[WaveformScrubberStyleKey.self] = newValue }
    }
}

extension View {
    /// Sets the style for waveform scrubbers within this view.
    public func waveformScrubberStyle<S: WaveformScrubberStyle>(_ style: S) -> some View {
        environment(\.waveformScrubberStyle, style)
    }
}


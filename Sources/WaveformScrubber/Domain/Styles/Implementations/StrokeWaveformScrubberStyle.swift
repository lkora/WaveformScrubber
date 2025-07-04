//
//  StrokeWaveformScrubberStyle.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

/// A style that strokes the waveform outline.
public struct StrokeWaveformScrubberStyle<Active: ShapeStyle, Inactive: ShapeStyle>: WaveformScrubberStyle {
    private let activeStyle: Active
    private let inactiveStyle: Inactive
    private let lineWidth: CGFloat
    
    public init(active: Active, inactive: Inactive, lineWidth: CGFloat = 1) {
        self.activeStyle = active
        self.inactiveStyle = inactive
        self.lineWidth = lineWidth
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        ZStack {
            configuration.waveform
                .stroke(inactiveStyle, lineWidth: lineWidth)

            configuration.activeWaveform
                .foregroundStyle(activeStyle)
        }
    }
}

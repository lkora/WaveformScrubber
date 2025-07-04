//
//  BarDrawer+Config.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

extension BarDrawer {
    public struct Config: Sendable {
        public let barWidth: CGFloat
        public let spacing: CGFloat

        /// Creates a new configuration for the `BarDrawer`'s appearance.
        /// - Parameters:
        ///   - spacing: The distance between each waveform bar. Defaults to `2`.
        ///   - barWidth: The width of each waveform bar. Defaults to `2`.
        public init(barWidth: CGFloat = 2, spacing: CGFloat = 2) {
            self.barWidth = barWidth
            self.spacing = spacing
        }
    }
}

//
//  BarDrawer+Config.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

extension BarDrawer {
    public struct Config: Sendable {
        /// Width of each bar.
        public var barWidth: CGFloat
        /// Spacing between bars.
        public var spacing: CGFloat
        /// Minimum height for each bar (to ensure visibility).
        public var minBarHeight: CGFloat
        /// Corner radius for rounding bar edges.
        public var cornerRadius: CGFloat

        /// Creates a new configuration for the `BarDrawer`'s appearance.
        /// - Parameters:
        ///   - spacing: The distance between each waveform bar. Defaults to `2`.
        ///   - barWidth: The width of each waveform bar. Defaults to `2`.
        ///   - minBarHeight: Minimum height for each bar (to ensure visibility). Defaults to `1`.
        ///   - cornerRadius: Corner radius for rounding bar edges. Defaults to `0`.
        public init(
            barWidth: CGFloat = 2,
            spacing: CGFloat = 2,
            minBarHeight: CGFloat = 1,
            cornerRadius: CGFloat = 0
        ) {
            self.barWidth = barWidth
            self.spacing = spacing
            self.minBarHeight = minBarHeight
            self.cornerRadius = cornerRadius
        }
    }
}

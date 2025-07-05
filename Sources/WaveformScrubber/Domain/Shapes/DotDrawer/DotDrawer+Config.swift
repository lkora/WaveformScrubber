//
//  DotDrawer.Config.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

extension DotDrawer {
    public struct Config: Sendable {
        public let dotRadius: CGFloat
        public let spacing: CGFloat
        public let upsampleStrategy: UpsampleStrategy

        /// Creates a new configuration for the `BarDrawer`'s appearance.
        /// - Parameters:
        ///   - dotRadius: The width of each waveform bar. Defaults to `2`.
        ///   - spacing: The distance between each waveform bar. Defaults to `2`.
        ///   - upsampleStrategy: The interpolation strategy to use when upsampling. Defaults to `.cosine`.
        public init(
            dotRadius: CGFloat = 2,
            spacing: CGFloat = 2,
            upsampleStrategy: UpsampleStrategy = .cosine
        ) {
            self.dotRadius = dotRadius
            self.spacing = spacing
            self.upsampleStrategy = upsampleStrategy
        }
    }
}

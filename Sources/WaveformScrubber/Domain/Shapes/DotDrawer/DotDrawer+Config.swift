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
        
        /// Creates a new configuration for the `BarDrawer`'s appearance.
        /// - Parameters:
        ///   - dotRadius: The width of each waveform bar. Defaults to `2`.
        ///   - spacing: The distance between each waveform bar. Defaults to `2`.
        public init(dotRadius: CGFloat = 2, spacing: CGFloat = 2) {
            self.dotRadius = dotRadius
            self.spacing = spacing
        }
    }
}

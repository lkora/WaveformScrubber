//
//  LineDrawer+Config.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

extension LineDrawer {
    public struct Config: Sendable {
        let inverted: Bool

        /// Creates a new configuration for the `LineDrawer`'s appearance.
        /// - Parameters:
        ///   - inverted: Defines if the inner wave should be inverted, making the outside shape represent the wave. Defaults to `false`.
        public init(inverted: Bool = false) {
            self.inverted = inverted
        }
    }
}

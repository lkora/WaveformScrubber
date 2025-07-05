//
//  BezierCurveDrawer+Config.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

extension BezierCurveDrawer {
    /// Configuration for the `BezierCurveDrawer`.
    public struct Config: Sendable {
        public var upsampleStrategy: UpsampleStrategy
        
        /// A value controlling how curvy the line is.
        /// A value of 1.0 is a good starting point. 0.0 will be linear.
        public let curviness: CGFloat

        /// Determines the density of the samples. A lower number means more detail but more computation.
        public let pixelsPerSample: CGFloat

        public init(
            curviness: CGFloat = 1.0,
            pixelsPerSample: CGFloat = 3.0,
            upsampleStrategy: UpsampleStrategy = .none
        ) {
            self.curviness = curviness
            self.pixelsPerSample = pixelsPerSample
            self.upsampleStrategy = upsampleStrategy
        }
    }
}

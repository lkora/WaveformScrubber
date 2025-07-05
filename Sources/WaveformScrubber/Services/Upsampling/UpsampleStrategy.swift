//
//  UpsampleStrategy.swift
//  WaveformScrubber
//
//  Created by Luka Korica on 7/5/25.
//

import Foundation

/// Defines the strategy for upsampling (stretching) a small number of audio samples to a larger number of points for rendering.
public enum UpsampleStrategy: Sendable {
    /// Smoothstep function for a highly smoothed, eased transition.
    /// This is often visually the most pleasing for curves.
    case smooth

    /// Uses a cosine curve for interpolation, resulting in a smoother, more "eased" transition between points.
    case cosine

    /// Stretches the samples using simple linear interpolation, creating straight lines between points.
    case linear

    /// Repeats the previous sample's value until the next, creating a "stepped" or "blocky" look.
    case hold

    /// Skips the upsampling process, resuting in the `AudioProcessor` returning the original sample without interpolation.
    /// NOTE: This will cause issues with Drawers that don't draw lines between points, as you will be left with a gap at the end of the
    /// representation (eg. BarDrawer). Since not enoght samples will be provided to completely fill the width of the view.
    /// If that is the case, you should consider choosing another `UpsampleStrategy`.
    case none
}

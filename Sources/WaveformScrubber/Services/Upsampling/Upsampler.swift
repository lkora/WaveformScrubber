//
//  Upsampler.swift
//  WaveformScrubber
//
//  Created by Luka Korica on 7/5/25.
//

import Foundation
import Accelerate
import simd

/// A namespace for hardware-accelerated upsampling (interpolation) functions.
struct Upsampler {
    
    /// "Stretches" a small array of samples to a larger size using a specified interpolation strategy.
    /// This utilizes `vDSP.linearInterpolate` for high performance. It is used to create a visually
    /// appealing waveform when the original number of samples is smaller than the number of points to render.
    ///
    /// - Parameters:
    ///   - samples: The small array of source samples.
    ///   - to: The target count, which must be larger than `samples.count`.
    ///   - strategy: The `UpsampleStrategy` used for interpolation.
    /// - Returns: A new array of size `count` with interpolated values.
    static func upsample(
        samples: [Float],
        to count: Int,
        strategy: UpsampleStrategy
    ) -> [Float] {
        guard !samples.isEmpty, count > samples.count else {
            return samples
        }

        // Generate the control vector based on the chosen strategy.
        let control = generateControlVector(from: samples.count, to: count, strategy: strategy)

        // Perform the hardware-accelerated interpolation.
        let result = vDSP.linearInterpolate(elementsOf: samples,
                                            using: control)

        return result
    }

    /// Generates the control vector needed for vDSP's interpolation function based on the chosen strategy.
    ///
    /// - Parameters:
    ///   - from: Original sample count.
    ///   - to: Targeted sample count.
    ///   - strategy: The `UpsampleStrategy` used for interpolation.
    /// - Returns: A control vector used for controling the linear interpolation.
    /// NOTE: `UpsampleStrategy.none` returns an empty control vector.
    private static func generateControlVector(
        from sourceCount: Int,
        to resultCount: Int,
        strategy: UpsampleStrategy
    ) -> [Float] {
        // Linear ramp from 0 to the last index of the source samples.
        let linearRamp = vDSP.ramp(in: 0...Float(sourceCount - 1),
                                count: resultCount)

        switch strategy {
        case .linear:
            return linearRamp

        case .hold:
            // Clamp the intermediate values until we reach n+1.
            return linearRamp.map { floor($0) }

        case .cosine:
            // Apply cosine easing to the fractional part of the ramp.
            return linearRamp.map {
                let integerPart = floor($0)
                let fractionalPart = $0 - integerPart
                let cosineFraction = (1 - cos(fractionalPart * .pi)) / 2
                return integerPart + Float(cosineFraction)
            }

        case .smooth:
            // To apply smoothstep easing, as shown in Apple's documentation.
            // This provides a C² continuous (very smooth) transition.
            // https://developer.apple.com/documentation/accelerate/using-linear-interpolation-to-construct-new-data-points#overview
            return linearRamp.map {
                let integerPart = floor($0)
                let fractionalPart = $0 - integerPart
                let smoothedFraction = simd_smoothstep(0, 1, fractionalPart)
                return integerPart + smoothedFraction
            }

        case .none:
            // We should not even have this case here
            return []
        }
    }
    
}

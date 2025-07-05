//
//  Downsampler.swift
//  WaveformScrubber
//
//  Created by Luka Korica on 7/6/25.
//

import Foundation
import Accelerate

struct Downsampler {
        
    /// Downsamples a large array of audio samples to a smaller number of points for visualization.
    /// For each bucket of samples, it computes the maximum absolute value.
    /// - Parameters:
    ///   - samples: The raw audio samples.
    ///   - to: The target number of samples.
    ///   - strategy: The `UpsampleStrategy` used for interpolating a `samples` smaller than the provided `count`. Defaults to `smooth`.
    /// - Returns: An array of downsampled floats.
    /// - Complexity:`O(n)` on average where `n` is the `samples.count`, execution is paralelized to run on multiple threads
    static func downsample(samples: [Float], to count: Int, upsampleStrategy: UpsampleStrategy = .smooth) async -> [Float] {
        guard count > 0, !samples.isEmpty else {
            return []
        }

        if samples.count <= count {
            return samples.map { abs($0) }
        }

        let n = samples.count
        let step = n / count
        var downsampled = [Float](repeating: 0.0, count: count)

        await withTaskGroup(of: (Int, Float).self) { group in
            for i in 0..<count {
                let start = i * step
                let end = (i == count - 1) ? n : (start + step)
                let sampleSlice = samples[start..<end]

                group.addTask {
                    var maxAbsValue: Float = 0.0
                    sampleSlice.withUnsafeBufferPointer { buffer in
                        guard let ptr = buffer.baseAddress else { return }
                        vDSP_maxmgv(ptr, 1, &maxAbsValue, vDSP_Length(buffer.count))
                    }
                    return (i, maxAbsValue)
                }
            }

            for await (index, maxVal) in group {
                downsampled[index] = maxVal
            }
        }
        return downsampled
    }

}

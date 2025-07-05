//
//  AudioProcessor.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/3/25.
//

import AVFoundation
import Accelerate

/// A namespace for audio processing functions.
struct AudioProcessor {

    /// Extracts audio information like duration from an `AVAudioFile`.
    static func extractInfo(from file: AVAudioFile) -> AudioInfo {
        let sampleRate = file.processingFormat.sampleRate
        let duration = Double(file.length) / sampleRate
        return AudioInfo(duration: duration)
    }

    /// Extracts the raw audio samples from an `AVAudioFile` into an array of Floats.
    static func extractSamples(from file: AVAudioFile) throws -> [Float] {
        let format = file.processingFormat
        let frameCount = UInt32(file.length)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw AudioProcessingError.bufferCreationFailed
        }

        try file.read(into: buffer)

        guard let floatChannelData = buffer.floatChannelData else {
            throw AudioProcessingError.channelDataMissing
        }

        let channelSamples = UnsafeBufferPointer(start: floatChannelData[0], count: Int(frameCount))
        return Array(channelSamples)
    }

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

        // Upscale if needed
        if samples.count < count {
            let absSamples = samples.map { abs($0) }
            
            switch upsampleStrategy {
            case .none:
                return absSamples
            default:
                return interpolate(samples: absSamples, to: count, strategy: upsampleStrategy)
            }
        }

        if samples.count == count {
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

    /// "Stretches" a small array of samples to a larger size using hardware-accelerated interpolation.
    /// This utilizes contorl vectors generated for the chosen strategy and `vDSP.linearInterpolate`
    /// It is used to create a visually appealing waveform when the original number of samples
    /// is much smaller than the desired number of points to render.
    ///
    /// - Parameters:
    ///   - samples: The small array of source samples.
    ///   - to: The target count, which must be larger than `samples.count`.
    ///   - strategy: The `UpsampleStrategy` used for interpolating a `samples` smaller than the provided `count`.
    /// - Returns: A new array of size `count` with interpolated values.
    private static func interpolate(
        samples: [Float],
        to count: Int,
        strategy: UpsampleStrategy
    ) -> [Float] {
        guard !samples.isEmpty, count > samples.count else {
            return samples
        }

        let control = generateControlVector(from: samples.count, to: count, strategy: strategy)

        let result = vDSP.linearInterpolate(elementsOf: samples,
                                            using: control)

        return result
    }

    /// Generates the control vector needed for vDSP's interpolation function based on the chosen strategy.
    private static func generateControlVector(
        from sourceCount: Int,
        to resultCount: Int,
        strategy: UpsampleStrategy
    ) -> [Float] {
        let linearRamp = vDSP.ramp(in: 0...Float(sourceCount - 1),
                                count: resultCount)

        switch strategy {
        case .linear:
            return linearRamp

        case .hold:
            // Claming the intermediare values until we reach n+1
            return linearRamp.map { floor($0) }

        case .cosine:
            // To apply cosine easing, we operate on the fractional part of the ramp.
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

    enum AudioProcessingError: Error {
        case bufferCreationFailed
        case channelDataMissing
    }
}

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

    /// Prepares audio samples for rendering by either downsampling or upsampling as needed.
    static func prepareSamples(
        samples: [Float],
        to count: Int,
        upsampleStrategy: UpsampleStrategy = .smooth
    ) async -> [Float] {
        guard count > 0, !samples.isEmpty else {
            return []
        }

        let absSamples = samples.map { abs($0) }

        if absSamples.count < count {
            // Strategy is to UPSAMPLE (few -> many)
            guard upsampleStrategy != .none else { return absSamples }

            // Delegate to the specialized Upsampler service.
            return Upsampler.upsample(samples: absSamples, to: count, strategy: upsampleStrategy)
        } else {
            // Strategy is to DOWNSAMPLE (many -> few)
            return await downsample(samples: absSamples, to: count)
        }
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


    enum AudioProcessingError: Error {
        case bufferCreationFailed
        case channelDataMissing
    }
}

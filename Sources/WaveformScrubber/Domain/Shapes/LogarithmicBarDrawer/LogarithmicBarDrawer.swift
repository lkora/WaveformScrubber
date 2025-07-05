//
//  LogarithmicBarDrawer.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

public struct LogarithmicBarDrawer: WaveformDrawing {
    let linearDrawer: BarDrawer
    let floor: Float
    public var upsampleStrategy: UpsampleStrategy

    public init(
        config: BarDrawer.Config = .init(),
        floor: Float = 0.1,
        upsampleStrategy: UpsampleStrategy = .smooth
    ) {
        self.linearDrawer = BarDrawer(config: config)
        self.floor = floor
        self.upsampleStrategy = upsampleStrategy
    }
    
    public func draw(samples: [Float], in rect: CGRect) -> Path {
        let logSamples = Self.transform(samples: samples, floor: floor)
        return linearDrawer.draw(samples: logSamples, in: rect)
    }
    
    public func sampleCount(for size: CGSize) -> Int {
        return linearDrawer.sampleCount(for: size)
    }

    /// Transforms linear samples to a logarithmic scale..
    static func transform(samples: [Float], floor: Float) -> [Float] {
        let logFloor = log10(floor)
        return samples.map { sample -> Float in
            let logValue = log10(max(sample, floor))
            // Normalize the log value back to a 0-1 range
            return (logValue - logFloor) / (0 - logFloor)
        }
    }
}

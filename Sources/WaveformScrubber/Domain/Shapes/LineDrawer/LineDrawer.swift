//
//  LineDrawer.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

/// A waveform drawer that renders the waveform as a continuous line,
/// mirroring the amplitude above and below a center line.
public struct LineDrawer: WaveformDrawing {
    public let config: Config
    public var upsampleStrategy: UpsampleStrategy

    public init(config: Config = .init(), upsampleStrategy: UpsampleStrategy = .smooth) {
        self.config = config
        self.upsampleStrategy = upsampleStrategy
    }

    public func draw(samples: [Float], in rect: CGRect) -> Path {
        Path { path in
            guard !samples.isEmpty else { return }

            let midY = rect.height / 2
            let stepX = rect.width / CGFloat(samples.count - 1)

            var topPoints: [CGPoint] = []
            var bottomPoints: [CGPoint] = []

            for (index, sample) in samples.enumerated() {
                let x = CGFloat(index) * stepX

                let isEdgePoint = (index == 0 || index == samples.count - 1)
                let middleAmplitude = max(1, CGFloat(sample) * midY)
                var halfHeight: CGFloat

                if config.inverted {
                    halfHeight = isEdgePoint ? midY : middleAmplitude
                } else {
                    halfHeight = isEdgePoint ? 0 : middleAmplitude
                }

                topPoints.append(CGPoint(x: x, y: midY - halfHeight))
                bottomPoints.append(CGPoint(x: x, y: midY + halfHeight))
            }

            path.addLines(topPoints)
            path.addLines(bottomPoints.reversed())
            path.closeSubpath()
        }
    }

    public func sampleCount(for size: CGSize) -> Int {
        Int(size.width)
    }
}

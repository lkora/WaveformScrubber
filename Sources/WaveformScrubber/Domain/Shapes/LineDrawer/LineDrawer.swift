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

    public init(config: Config = .init()) {
        self.config = config
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
                let height = max(1, CGFloat(sample) * rect.height)

                topPoints.append(CGPoint(x: x, y: midY - height))
                bottomPoints.append(CGPoint(x: x, y: midY + height))
            }

            path.addLines(topPoints)
            // Reverse the bottom points to create a single, continuous, closed shape
            path.addLines(bottomPoints)
            path.closeSubpath()
        }
    }

    public func sampleCount(for size: CGSize) -> Int {
        Int(size.width)
    }
}

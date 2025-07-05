//
//  DotDrawer.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

/// This style renders the waveform as a series of circles, where the radius or vertical position of each circle represents the amplitude.
public struct DotDrawer: WaveformDrawing {
    public let config: Config
    public let upsampleStrategy: UpsampleStrategy

    public init(config: Config = .init(), upsampleStrategy: UpsampleStrategy = .linear) {
        self.config = config
        self.upsampleStrategy = upsampleStrategy
    }

    public func draw(samples: [Float], in rect: CGRect) -> Path {
        Path { path in
            let midY = rect.height / 2
            let spacing = rect.width / CGFloat(samples.count)

            for (index, sample) in samples.enumerated() {
                let x = CGFloat(index) * spacing
                let halfHeight = CGFloat(sample) * rect.height / 2

                let radius = config.dotRadius
                path.addEllipse(in: CGRect(x: x - radius, y: midY - halfHeight - radius, width: radius * 2, height: radius * 2))
                path.addEllipse(in: CGRect(x: x - radius, y: midY + halfHeight - radius, width: radius * 2, height: radius * 2))
            }
        }
    }

    public func sampleCount(for size: CGSize) -> Int {
        return Int(size.width / (config.dotRadius * 2 + config.spacing))
    }
}

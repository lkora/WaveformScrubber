//
//  BarDrawer.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/3/25.
//

import SwiftUI

/// A waveform drawer that renders the waveform as a series of vertical bars.
public struct BarDrawer: WaveformDrawing {
    public let config: Config
    public var upsampleStrategy: UpsampleStrategy

    public init(
        config: Config = .init(),
        upsampleStrategy: UpsampleStrategy = .smooth
    ) {
        self.config = config
        self.upsampleStrategy = upsampleStrategy
    }

    public func draw(samples: [Float], in rect: CGRect) -> Path {
        Path { path in
            let totalBarWidth = config.barWidth + config.spacing
            guard totalBarWidth > 0 else { return }

            let midY = rect.height / 2

            for (index, sample) in samples.enumerated() {
                let x = CGFloat(index) * totalBarWidth
                let rawHeight = CGFloat(sample) * rect.height
                // Ensure height is at least minBarHeight to be visible
                let height = max(config.minBarHeight, rawHeight)

                let barRect = CGRect(
                    x: x,
                    y: midY - height / 2,
                    width: config.barWidth,
                    height: height
                )
                path.addRoundedRect(
                    in: barRect,
                    cornerSize: CGSize(width: config.cornerRadius, height: config.cornerRadius)
                )
            }
        }
    }

    public func sampleCount(for size: CGSize) -> Int {
        let totalBarWidth = config.barWidth + config.spacing

        guard totalBarWidth > 0 else { return 0 }

        // Calculate how many bars can fit in the given width
        return Int(size.width / totalBarWidth)
    }
}

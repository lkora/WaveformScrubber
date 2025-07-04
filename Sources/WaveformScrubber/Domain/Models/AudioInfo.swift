//
//  AudioInfo.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/3/25.
//

import Foundation

/// Information extracted from the audio file.
public struct AudioInfo: Sendable, Equatable {
    public let duration: TimeInterval

    public init(duration: TimeInterval) {
        self.duration = duration
    }
}

//
//  AnyShape.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import Foundation
import SwiftUI

public struct AnyShape: Shape {
    private let _path: @Sendable (CGRect) -> Path

    public init<S: Shape>(_ shape: S) {
        _path = { (rect: CGRect) in shape.path(in: rect) }
    }

    public func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

//
//  DrawingShape.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

struct DrawingShape<Drawer: WaveformDrawing>: Shape {
    let samples: [Float]
    let drawer: Drawer

    func path(in rect: CGRect) -> Path {
        drawer.draw(samples: samples, in: rect)
    }
}

//
//  BezierCurveDrawer.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI

/// A waveform drawer that renders the waveform as a smooth, continuous Bézier curve.
/// This style is excellent for a modern, fluid appearance.
public struct BezierCurveDrawer: WaveformDrawing {
    public let config: Config
    
    public init(config: Config = .init()) {
        self.config = config
    }
    
    // This drawer creates a closed, fillable shape.
    public func draw(samples: [Float], in rect: CGRect) -> Path {
        Path { path in
            guard samples.count > 1 else {
                // Not enough points to draw a curve.
                // You could draw a flat line or nothing.
                path.move(to: CGPoint(x: 0, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
                return
            }

            let midY = rect.midY
            let stepX = rect.width / CGFloat(samples.count - 1)

            var topPoints: [CGPoint] = []
            for (index, sample) in samples.enumerated() {
                let x = CGFloat(index) * stepX
                let halfHeight = CGFloat(sample) * rect.height / 2
                topPoints.append(CGPoint(x: x, y: midY - halfHeight))
            }
            
            // Mirror the points for the bottom half to create a symmetrical shape
            let bottomPoints = topPoints.map { CGPoint(x: $0.x, y: midY + ($0.y - midY) * -1) }

            // Move to the starting point
            path.move(to: topPoints[0])
            
            // Draw the top curve
            for i in 0 ..< topPoints.count - 1 {
                let p1 = topPoints[i]
                let p2 = topPoints[i+1]
                
                // Calculate control points for a smooth curve between p1 and p2
                let (cp1, cp2) = controlPoints(p0: i > 0 ? topPoints[i-1] : p1,
                                               p1: p1,
                                               p2: p2,
                                               p3: i < topPoints.count - 2 ? topPoints[i+2] : p2,
                                               tension: config.curviness)
                
                path.addCurve(to: p2, control1: cp1, control2: cp2)
            }

            // Draw the bottom curve by reversing the points
            // Start from the last point on the bottom
            path.addLine(to: bottomPoints.last!) // Connect top and bottom smoothly
            
            for i in (0 ..< bottomPoints.count - 1).reversed() {
                let p1 = bottomPoints[i+1]
                let p2 = bottomPoints[i]

                let (cp1, cp2) = controlPoints(p0: i < bottomPoints.count - 2 ? bottomPoints[i+2] : p1,
                                               p1: p1,
                                               p2: p2,
                                               p3: i > 0 ? bottomPoints[i-1] : p2,
                                               tension: config.curviness)
                
                path.addCurve(to: p2, control1: cp1, control2: cp2)
            }
            
            // Close the path to make it a single, fillable shape
            path.closeSubpath()
        }
    }

    /// Calculates the control points for a cubic Bézier curve segment using a simplified
    /// Catmull-Rom spline logic to ensure smoothness.
    /// - Parameters:
    ///   - p0: The point before the current segment begins.
    ///   - p1: The starting point of the current segment.
    ///   - p2: The ending point of the current segment.
    ///   - p3: The point after the current segment ends.
    ///   - tension: A value that controls the "curviness" of the line. 0 is linear, 1 is a good default.
    /// - Returns: A tuple containing the two control points for the curve from p1 to p2.
    private func controlPoints(p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint, tension: CGFloat) -> (CGPoint, CGPoint) {
        let t = tension
        
        let cp1 = CGPoint(
            x: p1.x + (p2.x - p0.x) / 6 * t,
            y: p1.y + (p2.y - p0.y) / 6 * t
        )
        
        let cp2 = CGPoint(
            x: p2.x - (p3.x - p1.x) / 6 * t,
            y: p2.y - (p3.y - p1.y) / 6 * t
        )
        
        return (cp1, cp2)
    }
    
    public func sampleCount(for size: CGSize) -> Int {
        // For a smooth curve, we don't need a sample for every pixel.
        // One sample every few pixels is usually enough to look good.
        return Int(size.width / config.pixelsPerSample)
    }
    
}

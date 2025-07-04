//
//  DrawerLogicTests.swift
//  WaveformScrubber
//
//  Created by Luka Korica on 7/4/25.
//

import XCTest
import SwiftUI
@testable import WaveformScrubber

final class DrawerLogicTests: XCTestCase {

    func testBarDrawer_sampleCount_isCalculatedCorrectly() {
        let config = BarDrawer.Config(barWidth: 4, spacing: 1) // Each bar uses 5 points of width
        let drawer = BarDrawer(config: config)
        let size = CGSize(width: 100, height: 50)

        let count = drawer.sampleCount(for: size)

        XCTAssertEqual(count, 20) // 100 / 5 = 20
    }

    func testBezierCurveDrawer_sampleCount_isCalculatedCorrectly() {
        let config = BezierCurveDrawer.Config(pixelsPerSample: 5)
        let drawer = BezierCurveDrawer(config: config)
        let size = CGSize(width: 200, height: 100)

        let count = drawer.sampleCount(for: size)

        XCTAssertEqual(count, 40) // 200 / 5 = 40
    }

    func testDotDrawer_sampleCount_isCalculatedCorrectly() {
        let config = DotDrawer.Config(dotRadius: 2, spacing: 1) // Each dot uses 2*2 + 1 = 5 points
        let drawer = DotDrawer(config: config)
        let size = CGSize(width: 50, height: 20)

        let count = drawer.sampleCount(for: size)

        XCTAssertEqual(count, 10) // 50 / 5 = 10
    }

    func testLineDrawer_sampleCount_isCalculatedCorrectly() {
        let drawer = LineDrawer()
        let size = CGSize(width: 375, height: 100)

        let count = drawer.sampleCount(for: size)

        XCTAssertEqual(count, 375) // Should be 1 sample per point of width
    }

    func testLogarithmicDrawer_transform_appliesLogarithmicScaleCorrectly() {
        let floor: Float = 0.1
        let samples: [Float] = [0.1, 0.5, 1.0]

        let transformedSamples = LogarithmicBarDrawer.transform(samples: samples, floor: floor)

        // Expected values are calculated based on the normalization formula
        XCTAssertEqual(transformedSamples[0], 0.0, accuracy: 1e-6)
        XCTAssertEqual(transformedSamples[1], 0.69897, accuracy: 1e-5)
        XCTAssertEqual(transformedSamples[2], 1.0, accuracy: 1e-6)
    }
}

//
//  DownsamplerTests.swift
//  WaveformScrubber
//
//  Created by Luka Korica on 7/6/25.
//

import XCTest
@testable import WaveformScrubber

final class DownsamplerTests: XCTestCase {

    func testDownsample_withValidInput_returnsCorrectCount() async {
        let rawSamples = [Float](repeating: 0.5, count: 1000)
        let targetCount = 100

        let downsampled = await Downsampler.downsample(samples: rawSamples, to: targetCount)

        XCTAssertEqual(downsampled.count, targetCount)
    }

    func testDownsample_withTargetCountLargerThanSampleCount_returnsSameSamplesButAbs() async {
        let smallSamples: [Float] = [0.0, -0.5, 1.0]

        let targetSamples = 5
        let downsampled = await Downsampler.downsample(samples: smallSamples, to: targetSamples)

        XCTAssertEqual(downsampled, [0.0, 0.5, 1.0])
        XCTAssertEqual(downsampled.count, smallSamples.count)
    }

    func testDownsample_withEmptySamples_returnsEmptyArray() async {
        let downsampled = await Downsampler.downsample(samples: [], to: 100)

        XCTAssertTrue(downsampled.isEmpty)
    }

    func testDownsample_withZeroTargetCount_returnsEmptyArray() async {
        let downsampled = await Downsampler.downsample(samples: [0.1, 0.2, 0.3], to: 0)

        XCTAssertTrue(downsampled.isEmpty)
    }

    func testDownsample_withNegativeTargetCount_returnsEmptyArray() async {
        let downsampled = await Downsampler.downsample(samples: [0.1, 0.2, 0.3], to: -10)

        XCTAssertTrue(downsampled.isEmpty)
    }

}

//
//  UpsamplerTests.swift
//  WaveformScrubber
//
//  Created by Luka Korica on 7/5/25.
//

import XCTest
@testable import WaveformScrubber

final class UpsamplerTests: XCTestCase {

    // A simple, predictable input for testing interpolation.
    // Represents a ramp from 0% to 100% amplitude.
    let inputSamples: [Float] = [0.0, 1.0]

    // MARK: - Strategy Tests

    func testUpsample_withLinearStrategy_returnsCorrectlyInterpolatedValues() {
        // Given
        let strategy = UpsampleStrategy.linear
        let targetCount = 5

        // Expected output is a straight line from 0.0 to 1.0 over 5 points.
        let expectedOutput: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]

        // When
        let result = Upsampler.upsample(samples: inputSamples, to: targetCount, strategy: strategy)

        // Then
        XCTAssertEqual(result.count, targetCount)
        XCTAssertEqual(result, expectedOutput, "Linear interpolation should produce an even ramp.")
    }

    func testUpsample_withHoldStrategy_returnsSteppedValues() {
        // Given
        let strategy = UpsampleStrategy.hold
        let targetCount = 5

        // Expected output holds the value of the 'floor' index until the next.
        // Control vector's floor: [0, 0, 0, 0, 1]
        let expectedOutput: [Float] = [0.0, 0.0, 0.0, 0.0, 1.0]

        // When
        let result = Upsampler.upsample(samples: inputSamples, to: targetCount, strategy: strategy)

        // Then
        XCTAssertEqual(result.count, targetCount)
        XCTAssertEqual(result, expectedOutput, "Hold interpolation should repeat the previous sample's value.")
    }

    func testUpsample_withCosineStrategy_returnsEasedValues() {
        // Given
        let strategy = UpsampleStrategy.cosine
        let targetCount = 5

        // Pre-calculated values based on the cosine easing formula.
        let expectedOutput: [Float] = [
            0.0,                      // 0%
            0.1464466,                // at 25% point
            0.5,                      // at 50% point
            0.8535534,                // at 75% point
            1.0                       // 100%
        ]

        // When
        let result = Upsampler.upsample(samples: inputSamples, to: targetCount, strategy: strategy)

        // Then
        XCTAssertEqual(result.count, targetCount)
        for (res, exp) in zip(result, expectedOutput) {
            XCTAssertEqual(res, exp, accuracy: 1e-6, "Cosine interpolation result is incorrect.")
        }
    }

    func testUpsample_withSmoothStrategy_returnsSmoothedValues() {
        // Given
        let strategy = UpsampleStrategy.smooth
        let targetCount = 5

        // Pre-calculated values based on the simd_smoothstep formula.
        let expectedOutput: [Float] = [
            0.0,                      // 0%
            0.15625,                  // at 25% point (x*x*(3-2*x))
            0.5,                      // at 50% point
            0.84375,                  // at 75% point
            1.0                       // 100%
        ]

        // When
        let result = Upsampler.upsample(samples: inputSamples, to: targetCount, strategy: strategy)

        // Then
        XCTAssertEqual(result.count, targetCount)
        for (res, exp) in zip(result, expectedOutput) {
            XCTAssertEqual(res, exp, accuracy: 1e-6, "Smooth interpolation result is incorrect.")
        }
    }

    // MARK: - Edge Case Tests

    func testUpsample_whenTargetCountIsSmaller_returnsOriginalSamples() {
        // Given
        let samples: [Float] = [0.1, 0.2, 0.3, 0.4, 0.5]
        let targetCount = 3 // Smaller than sample count

        // When
        let result = Upsampler.upsample(samples: samples, to: targetCount, strategy: .linear)

        // Then
        // The guard condition should fire, returning the original samples.
        XCTAssertEqual(result, samples, "Upsampling to a smaller count should return the original array.")
    }

    func testUpsample_whenTargetCountIsEqual_returnsOriginalSamples() {
        // Given
        let samples: [Float] = [0.1, 0.2, 0.3, 0.4, 0.5]
        let targetCount = 5 // Equal to sample count

        // When
        let result = Upsampler.upsample(samples: samples, to: targetCount, strategy: .linear)

        // Then
        XCTAssertEqual(result, samples, "Upsampling to an equal count should return the original array.")
    }

    func testUpsample_withEmptySamples_returnsEmptyArray() {
        // Given
        let samples: [Float] = []
        let targetCount = 100

        // When
        let result = Upsampler.upsample(samples: samples, to: targetCount, strategy: .linear)

        // Then
        XCTAssertTrue(result.isEmpty, "Upsampling an empty array should result in an empty array.")
    }
}

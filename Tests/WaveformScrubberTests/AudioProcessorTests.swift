//
//  AudioProcessorTests.swift
//  WaveformScrubber
//
//  Created by Luka Korica on 7/4/25.
//

import XCTest
import AVFAudio
@testable import WaveformScrubber

final class AudioProcessorTests: XCTestCase {

    // MARK: - Sample Extraction Tests

    func testExtractSamples_fromValidFile_returnsNonEmptyArray() throws {
        let url = try getTestAudioURL()
        let audioFile = try AVAudioFile(forReading: url)

        let samples = try AudioProcessor.extractSamples(from: audioFile)

        XCTAssertFalse(samples.isEmpty)
    }

    func testExtractSamples_fromValidFile_returnsCorrectSampleCount() throws {
        let url = try getTestAudioURL()
        let audioFile = try AVAudioFile(forReading: url)

        let samples = try AudioProcessor.extractSamples(from: audioFile)

        XCTAssertEqual(samples.count, Int(audioFile.length))
    }

    func testExtractInfo_fromValidFile_returnsCorrectDuration() throws {
        let url = try getTestAudioURL()
        let audioFile = try AVAudioFile(forReading: url)

        let info = AudioProcessor.extractInfo(from: audioFile)

        let expectedDuration = Double(audioFile.length) / audioFile.processingFormat.sampleRate
        XCTAssertEqual(info.duration, expectedDuration, accuracy: 0.01)
    }

    // MARK: - Downsampling Tests

    func testDownsample_withValidInput_returnsCorrectCount() async {
        let rawSamples = [Float](repeating: 0.5, count: 1000)
        let targetCount = 100

        let downsampled = await AudioProcessor.downsample(samples: rawSamples, to: targetCount)

        XCTAssertEqual(downsampled.count, targetCount)
    }

    func testDownsample_withTargetCountLargerThanSampleCount_returnsOriginalAbsoluteSamples() async {
        let smallSamples: [Float] = [0.1, -0.2, 0.3]

        let downsampled = await AudioProcessor.downsample(samples: smallSamples, to: 100)

        XCTAssertEqual(downsampled, [0.1, 0.2, 0.3])
    }

    func testDownsample_withEmptySamples_returnsEmptyArray() async {
        let downsampled = await AudioProcessor.downsample(samples: [], to: 100)

        XCTAssertTrue(downsampled.isEmpty)
    }

    func testDownsample_withZeroTargetCount_returnsEmptyArray() async {
        let downsampled = await AudioProcessor.downsample(samples: [0.1, 0.2, 0.3], to: 0)

        XCTAssertTrue(downsampled.isEmpty)
    }

    func testDownsample_withNegativeTargetCount_returnsEmptyArray() async {
        let downsampled = await AudioProcessor.downsample(samples: [0.1, 0.2, 0.3], to: -10)

        XCTAssertTrue(downsampled.isEmpty)
    }
}

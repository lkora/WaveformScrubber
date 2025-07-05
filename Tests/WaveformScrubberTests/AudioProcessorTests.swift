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

}

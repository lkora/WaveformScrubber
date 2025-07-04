//
//  File.swift
//  WaveformScrubber
//
//  Created by Luka Korica on 7/5/25.
//
import XCTest

extension XCTestCase {

    /// Helper to load the test audio file URL from the test bundle.
    /// This will fail the current test if the audio file isn't found.
    func getTestAudioURL(
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> URL {
        let testBundle = Bundle.module

        guard let url = testBundle.url(forResource: "test_audio", withExtension: "wav") else {
            XCTFail("Test audio file 'test_audio.wav' not found in test bundle.", file: file, line: line)
            throw TestError.fileNotFound
        }
        return url
    }

    enum TestError: Error {
        case fileNotFound
    }
}

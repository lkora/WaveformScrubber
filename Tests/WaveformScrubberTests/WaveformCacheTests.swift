//
//  WaveformCacheTests.swift
//  WaveformScrubber
//
//  Created by Luka Korica on 7/4/25.
//

import XCTest
@testable import WaveformScrubber

final class WaveformCacheTests: XCTestCase {

    func testSamples_forSameURL_returnsCachedDataOnSecondFetch() async throws {
        // Given: A cache instance and an audio URL
        let cache = WaveformCache.shared
        let url = try getTestAudioURL()

        // When: We fetch samples twice
        let firstFetch = try await cache.samples(for: url)
        let secondFetch = try await cache.samples(for: url)

        // Then: Both fetches should return the identical, non-empty sample data
        XCTAssertFalse(firstFetch.isEmpty)
        XCTAssertEqual(firstFetch, secondFetch, "Cache should return identical data for subsequent fetches of the same URL.")
    }

    func testSamples_withConcurrentRequests_sharesSingleLoadingTask() async throws {
        // Given: A cache instance and an audio URL
        let cache = WaveformCache.shared
        let url = try getTestAudioURL()

        // When: We launch multiple concurrent tasks to fetch the same URL
        async let task1 = cache.samples(for: url)
        async let task2 = cache.samples(for: url)
        async let task3 = cache.samples(for: url)
        let results = try await [task1, task2, task3]

        // Then: All tasks should complete successfully with identical results
        XCTAssertEqual(results.count, 3)
        XCTAssertFalse(results[0].isEmpty)
        XCTAssertEqual(results[0], results[1])
        XCTAssertEqual(results[1], results[2])
    }
}

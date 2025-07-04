//
//  WaveformCache.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/4/25.
//

import Foundation
import AVFAudio

/// A thread-safe, shared cache for storing processed audio samples to prevent redundant work.
/// This actor manages the loading and storing of downsampled waveform data.
public actor WaveformCache {

    /// The singleton instance of the cache.
    public static let shared = WaveformCache()

    /// The underlying cache storing data keyed by URL.
    private var cache = NSCache<NSURL, CacheEntry>()
    
    /// A dictionary to track in-flight loading tasks to prevent duplicate processing for the same URL.
    private var loadingTasks: [URL: Task<[Float], Error>] = [:]

    private init() {
        cache.countLimit = 50
    }

    /// Retrieves the full-resolution audio samples for a given URL.
    /// It will first check the cache. If not found, it will process the audio file.
    /// This method ensures that the processing for a single URL only happens once, even with concurrent requests.
    public func samples(for url: URL) async throws -> [Float] {
        if let entry = cache.object(forKey: url as NSURL) {
            return entry.fullSamples
        }
        
        if let task = loadingTasks[url] {
            return try await task.value
        }
        
        // No cache hit so we create a new loading task
        let task = Task {
            // Remove the task from the dictionary once it's complete.
            defer { loadingTasks[url] = nil }

            let audioFile = try AVAudioFile(forReading: url)
            let rawSamples = try AudioProcessor.extractSamples(from: audioFile)
            
            // Store the full-resolution samples in a new cache entry.
            let entry = CacheEntry(fullSamples: rawSamples)
            cache.setObject(entry, forKey: url as NSURL)
            
            return rawSamples
        }
        
        loadingTasks[url] = task
        return try await task.value
    }
}

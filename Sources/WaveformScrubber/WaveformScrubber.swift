//
//  WaveformScrubber.swift
//  VoiceMessageWaveform
//
//  Created by Luka Korica on 7/2/25.
//

import SwiftUI
import AVFoundation

/// A SwiftUI view that displays an audio waveform and allows seeking through playback.
///
/// This view is generic over a `Drawer` type, which must conform to the `WaveformDrawing`
/// protocol. This allows for customizable waveform rendering (e.g., bars, lines).
public struct WaveformScrubber<Drawer: WaveformDrawing,
                                ActiveStyle: ShapeStyle,
                               InactiveStyle: ShapeStyle>: View {

    @Environment(\.waveformScrubberStyle) private var style
    private let waveformCacheService = WaveformCache.shared

    let config: ScrubberConfig<ActiveStyle, InactiveStyle>
    let drawer: Drawer
    let url: URL

    @Binding var progress: CGFloat

    let onInfoLoaded: (AudioInfo) -> Void
    let onGestureActive: (Bool) -> Void

    @State private var samples: [Float] = []
    @State private var localProgress: CGFloat
    @State private var viewSize: CGSize = .zero
    @GestureState private var isDragging: Bool = false

    private struct LoadTaskID: Equatable {
        let url: URL
        let size: CGSize
    }

    /// Creates a new WaveformScrubber view.
    /// - Parameters:
    ///   - config: Configuration for the scrubbers's appearance.
    ///   - drawer: Type of a drawer used for the scrubber's instance
    ///   - url: The URL of the audio file to display.
    ///   - progress: A binding to the playback progress, from 0.0 to 1.0.
    ///   - onInfoLoaded: A closure called when the audio file's metadata (like duration) is loaded.
    ///   - onGestureActive: A closure called when the user starts or stops a drag gesture.
    public init(
        config: ScrubberConfig<ActiveStyle, InactiveStyle>,
        drawer: Drawer,
        url: URL,
        progress: Binding<CGFloat>,
        onInfoLoaded: @escaping (AudioInfo) -> Void = { _ in },
        onGestureActive: @escaping (Bool) -> Void = { _ in }
    ) {
        self.config = config
        self.drawer = drawer
        self.url = url
        self._progress = progress
        self._localProgress = State(initialValue: progress.wrappedValue)
        self.onInfoLoaded = onInfoLoaded
        self.onGestureActive = onGestureActive
    }

    public var body: some View {
        resolveStyleAndApplyModifiers()
            .task(id: LoadTaskID(url: url, size: viewSize)) {
                // TODO: Remove this debouncer
                do {
                    try await Task.sleep(nanoseconds: 50_000_000)
                } catch {
                    return
                }

                guard viewSize.width > 0 else { return }

                await loadAudioData()
            }
    }

    @ViewBuilder
    private func resolveStyleAndApplyModifiers() -> some View {
        let shape = AnyShape(DrawingShape(samples: samples, drawer: drawer))
        let active = AnyView(
            shape.mask(alignment: .leading) {
                Rectangle().frame(width: viewSize.width * progress)
            }
        )
        let inactive = AnyView(
            shape.mask(alignment: .leading) {
                Rectangle().padding(.leading, viewSize.width * progress)
            }
        )
        let configuration = WaveformScrubberStyle.Configuration(
            waveform: shape,
            activeWaveform: active,
            inactiveWaveform: inactive
        )

        AnyView(style.makeBody(configuration: configuration))
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .background(geometryReader)
            .onChange(of: isDragging, perform: onGestureActive)
            .onChange(of: progress) { newProgress in
                // Update local state only when not dragging to sync with external changes.
                if !isDragging {
                    localProgress = newProgress
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { value in
                guard viewSize.width > 0 else { return }
                let newProgress = (value.translation.width / viewSize.width) + localProgress
                progress = max(0, min(1, newProgress))
            }
            .onEnded { value in
                // Persist the progress after the drag ends.
                localProgress = progress
            }
    }

    private var geometryReader: some View {
        GeometryReader { geometry in
            Color.clear
                .onAppear {
                    if viewSize == .zero {
                        viewSize = geometry.size
                    }
                }
                .onChange(of: geometry.size) { newSize in
                    viewSize = newSize
                }
        }
    }

    private func loadAudioData() async {
        guard viewSize.width > 0 else { return }

        // Clear old samples to provide immediate visual feedback.
        await MainActor.run {
            self.samples = []
        }

        do {
            // 1. Get the full-resolution samples from the shared cache.
            // This will be instantaneous if another scrubber has already processed this URL.
            // If not, it will perform the processing and cache the result for next time.
            let rawSamples = try await waveformCacheService.samples(for: url)

            // 2. The downsampling step is still necessary for each instance, as it depends on `viewSize`.
            // However, this is MUCH faster than reading and processing the entire audio file.
            let targetSampleCount = drawer.sampleCount(for: viewSize)

            if Task.isCancelled { return }

            // This vDSP operation is very fast.
            let downsampled = await AudioProcessor.downsample(samples: rawSamples,
                                                              to: targetSampleCount,
                                                              upsampleStrategy: drawer.upsampleStrategy)

            if Task.isCancelled { return }

            // 3. Update the UI.
            await MainActor.run {
                self.samples = downsampled
            }

            // We can also fetch the audio info here without re-reading the file.
            // This part is fast and can be done alongside.
            let audioFile = try AVAudioFile(forReading: url)
            onInfoLoaded(AudioProcessor.extractInfo(from: audioFile))

        } catch {
            if !(error is CancellationError) {
                print("WaveformScrubber failed to process audio: \(error.localizedDescription)")
            }
        }
    }

}

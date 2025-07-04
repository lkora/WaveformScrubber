//
//  ContentView.swift
//  WaveformScrubberExample
//
//  Created by Luka Korica on 7/4/25.
//

import SwiftUI
import WaveformScrubber

struct ContentView: View {
    @State private var progress: CGFloat = 0.0

    let scrubberConfig: ScrubberConfig = .init(
        activeTint: .linearGradient(
            colors: [.blue, .purple],
            startPoint: .top,
            endPoint: .bottom
        ),
        inactiveTint: Color.gray
    )
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if let audioURL {
                        Section("Audio") {
                            WaveformScrubber(
                                config: scrubberConfig,
                                drawer: BarDrawer(config: .init(barWidth: 2, spacing: 2)),
                                url: audioURL,
                                progress: $progress
                            ) { info in
                                print(info.duration)
                            } onGestureActive: { status in

                            }
                            .frame(height: 100)

                            WaveformScrubber(
                                config: scrubberConfig,
                                drawer: LogarithmicBarDrawer(config: .init(barWidth: 2, spacing: 2), floor: 0.05),
                                url: audioURL,
                                progress: $progress
                            ) { info in
                                print(info.duration)
                            } onGestureActive: { status in

                            }
                            .frame(height: 100)

                            WaveformScrubber(
                                config: scrubberConfig,
                                drawer: LineDrawer(config: .init()),
                                url: audioURL,
                                progress: $progress
                            ) { info in
                                print(info.duration)
                            } onGestureActive: { status in

                            }
                            .frame(height: 100)

                            WaveformScrubber(
                                config: scrubberConfig,
                                drawer: BarDrawer(config: .init(barWidth: 2, spacing: 2)),
                                url: audioURL,
                                progress: $progress
                            ) { info in
                                print(info.duration)
                            } onGestureActive: { status in

                            }
                            .waveformScrubberStyle(
                                StrokeWaveformScrubberStyle(active: Color.accentColor, inactive: Color.gray, lineWidth: 1)
                            )
                            .frame(height: 100)

                            WaveformScrubber(
                                config: scrubberConfig,
                                drawer: DotDrawer(config: .init(dotRadius: 2, spacing: 2)),
                                url: audioURL,
                                progress: $progress
                            ) { info in
                                print(info.duration)
                            } onGestureActive: { status in

                            }
                            .frame(height: 100)

                            WaveformScrubber(
                                config: scrubberConfig,
                                drawer: BezierCurveDrawer(config: .init(curviness: 0, pixelsPerSample: 5)),
                                url: audioURL,
                                progress: $progress
                            ) { info in
                                print(info.duration)
                            } onGestureActive: { status in

                            }
                            .waveformScrubberStyle(
                                StrokeWaveformScrubberStyle(active: Color.accentColor, inactive: Color.gray, lineWidth: 1)
                            )
                            .frame(height: 100)


                        }
                    } else {
                        Text("Failed to load audio URL!")
                    }
                }
                .navigationTitle("Audio Scrubber")
            }

            Slider(value: $progress)
                .padding()

        }
    }

    var audioURL: URL? {
        Bundle.main.url(forResource: "design_aesthetics", withExtension: "mp3")

    }
}

#Preview {
    ContentView()
}

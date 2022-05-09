//
//  TimerView.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 09/05/22.
//

import SwiftUI
import Combine

private let tick = 0.1 // 1ms

struct TimerView: View {
    let minTotal = 0.0
    let maxTotal = 30.0

    @State var elapsed = 0.0
    @State var total = 5.0
    @State var timer = Timer.publish(every: tick, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            ProgressView("Elapsed Time:", value: elapsed, total: total)
            Text("\(String(format: "%.1f", elapsed))s / \(String(format: "%.1f", total))s")
            Slider(value: $total, in: minTotal...maxTotal) {
                EmptyView()
            } minimumValueLabel: {
                Text("\(String(format: "%.1f", minTotal))s")
            } maximumValueLabel: {
                Text("\(String(format: "%.1f", maxTotal))s")
            }.onChange(of: total) {
                if $0 < elapsed {
                    elapsed = $0
                } else {
                    startTimer()
                }
            }
            Button("Reset") {
                elapsed = 0
                startTimer()
            }
        }
        .frame(width: 300)
        .onReceive(timer) { _ in
            let new = elapsed + tick
            if new <= total {
                elapsed = new
            } else {
                stopTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }

    private func startTimer() {
        timer = Timer.publish(every: tick, on: .main, in: .common).autoconnect()
    }

    private func stopTimer() {
        timer.upstream.connect().cancel()
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}

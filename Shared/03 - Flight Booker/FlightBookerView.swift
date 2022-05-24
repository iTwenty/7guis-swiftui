//
//  FlightBookerView.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 08/05/22.
//

import SwiftUI

enum FlightType: String {
    case single = "One Way"
    case retrun = "Return"
}

struct FlightBookerView: View {
    @State var flightType: FlightType = .single
    @State var showConfirmation = false

    @State var onwardDate: Date?
    @State var onwardString: String
    @State var returnDate: Date?
    @State var returnString: String

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"
        return df
    }()

    init() {
        let now = Date.now
        self._onwardDate = State(initialValue: now)
        self._onwardString = State(initialValue: dateFormatter.string(from: now))
        self._returnDate = State(initialValue: now)
        self._returnString = State(initialValue: dateFormatter.string(from: now))
    }

    var body: some View {
        VStack {
            Picker("Flight Type", selection: $flightType) {
                Text(FlightType.single.rawValue).tag(FlightType.single)
                Text(FlightType.retrun.rawValue).tag(FlightType.retrun)
            }
            TextField("Onward", text: $onwardString)
                .background(Color.red.opacity(onwardDate == nil ? 1 : 0))
                .onChange(of: onwardString) {
                    onwardDate = dateFormatter.date(from: $0)
                }
            TextField("Return", text: $returnString)
                .background(Color.red.opacity(returnTextFieldBackgroundOpacity))
                .disabled(flightType == .single)
                .onChange(of: returnString) {
                    returnDate = dateFormatter.date(from: $0)
                }
            Button("Book") {
                showConfirmation = true
            }
            .disabled(bookButtonDisabled)
            .popover(isPresented: $showConfirmation) {
                Text(confirmationMesssage).padding()
            }
            Text("Date format is dd.mm.yyyy. eg - 02.09.1990").font(.caption2)
        }
        .frame(width: 300)
        .padding()
        .border(Color.secondary)
    }

    private var returnTextFieldBackgroundOpacity: CGFloat {
        switch flightType {
        case .single: return 0
        case .retrun: return returnDate == nil ? 1 : 0
        }
    }

    private var bookButtonDisabled: Bool {
        switch flightType {
        case .single: return (onwardDate == nil)
        case .retrun:
            guard let od = onwardDate, let rd = returnDate else {
                return true
            }
            return rd <= od
        }
    }

    private var confirmationMesssage: String {
        switch flightType {
        case .single: return "Booked \(flightType.rawValue) flight on \(onwardString)"
        case .retrun: return "Booked \(flightType.rawValue) flight from \(onwardString) to \(returnString)"
        }
    }
}

struct FlightBookerView_Previews: PreviewProvider {
    static var previews: some View {
        FlightBookerView()
    }
}

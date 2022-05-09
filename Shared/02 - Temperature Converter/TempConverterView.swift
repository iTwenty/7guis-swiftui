//
//  TempConverterView.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 08/05/22.
//

import SwiftUI

// What caused the celsius/faren text to change?
// user means change is in response to direct edit by user
// We should update the other text field in this case
// AND set it's source to indirect to ensure we don't end up
// in an onChange loop
// indirect means change is in response to other field being
// changed by user. ONLY set the source back to user in this case
// and don't do any conversions.
enum ChangeSource {
    case user, indirect
}

struct TempConverterView: View {
    @State var celsiusString = ""
    @State var celsiusChangeSource = ChangeSource.user
    @State var farenString = ""
    @State var farenChangeSource = ChangeSource.user

    var body: some View {
        VStack {
            HStack {
                TextField("", text: $celsiusString)
                    .onChange(of: celsiusString) { newValue in
                        if case .user = celsiusChangeSource {
                            if let c = Double(newValue) {
                                farenChangeSource = .indirect
                                farenString = String(format: "%.1f", c2f(c))
                            }
                        }
                        celsiusChangeSource = .user
                    }
                Text("Celsius")
            }
            Text("=")
            HStack {
                TextField("", text: $farenString)
                    .onChange(of: farenString) { newValue in
                        if case .user = farenChangeSource {
                            if let f = Double(newValue) {
                                celsiusChangeSource = .indirect
                                celsiusString = String(format: "%.1f", f2c(f))
                            }
                        }
                        farenChangeSource = .user
                    }
                Text("Farenheit")
            }
        }.frame(width: 300)
    }
    private func c2f(_ c: Double) -> Double { c * 9 / 5 + 32 }
    private func f2c(_ f: Double) -> Double { (f - 32) * 5 / 9 }
}

struct TempConverterView_Previews: PreviewProvider {
    static var previews: some View {
        TempConverterView()
    }
}

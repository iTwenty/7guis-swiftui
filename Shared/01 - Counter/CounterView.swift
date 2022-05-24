//
//  CounterView.swift
//  seven-guis
//
//  Created by Jaydeep Joshi on 08/05/22.
//

import SwiftUI

struct CounterView: View {
    @State var counter = 0

    var body: some View {
        VStack {
            Text("\(counter)")
            Button("Count") {
                counter += 1
            }
        }
        .padding()
        .border(Color.secondary)
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView()
    }
}

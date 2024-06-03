//
//  ContentView.swift
//  AudioBook
//
//  Created by Oleh Titov on 28.05.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(uiImage: AppIconProvider.appIcon())
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            ProgressView("Loading...")
        }
    }
}

#Preview {
    ContentView()
}

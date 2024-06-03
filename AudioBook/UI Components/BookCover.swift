//
//  BookCover.swift
//  AudioBook
//
//  Created by Oleh Titov on 28.05.2024.
//

import SwiftUI

struct BookCover: View {
    let url: URL
    var width: Double
    var height: Double
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.secondary)
                    .frame(width: width, height: height)
                    .overlay{
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 5)
                            Rectangle()
                                .fill(Color.black.opacity(0.2))
                                .frame(width: 4)
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 8)
                            Spacer()
                        }
                        .frame(height: height)
                        .blur(radius: 1.0)
                    }
                    .overlay {
                        ProgressView()
                    }
                    
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .overlay{
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 5)
                            Rectangle()
                                .fill(Color.black.opacity(0.2))
                                .frame(width: 4)
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 8)
                            Spacer()
                        }
                        .frame(height: height)
                        .blur(radius: 1.0)
                    }
            case .failure:
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: height)
            @unknown default:
                EmptyView()
            }
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding()
        .padding(.top)
    }
}

#Preview {
    BookCover(url: Bundle.main.url(forResource: "around_world_in_80_days", withExtension: "jpg")!, width: 200, height: 300)
}

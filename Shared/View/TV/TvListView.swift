//
//  TvListView.swift
//  Story
//
//  Created by Alexandre Madeira on 08/02/22.
//

import SwiftUI

struct TvListView: View {
    let style: String
    let title: String
    let series: [TvShow]?
    var body: some View {
        VStack {
            if !series.isEmpty {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding([.top, .horizontal])
                    Spacer()
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(series!) { content in
                            NavigationLink(destination: TvDetailsView(tvId: content.id, tvTitle: content.title)) {
                                switch style {
                                case "poster":
                                    PosterView(title: content.title, url: content.posterImage)
                                        .padding([.leading, .trailing], 4)
                                case "card":
                                    CardView(title: content.title, url: content.backdropImage)
                                        .padding([.leading, .trailing], 4)
                                default:
                                    EmptyView()
                                }
                            }
                            .padding(.leading, content.id == self.series!.first!.id ? 16 : 0)
                            .padding(.trailing, content.id == self.series!.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                }
            }
        }
    }
}

//struct HorizontalSerieListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TvListView()
//    }
//}

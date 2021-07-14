//
//  SpotifyView.swift
//  CentralApp
//
//  Created by Tom on 7/12/21.
//

import SwiftUI


struct SpotifyView: View {
    
    @EnvironmentObject var btcentral:BTCentralManager
    var isAppClip:Bool = false

    var body: some View {
        VStack(alignment:.center) {
            
            Spacer()
            Text(isAppClip ? "Spotify MetaData App Clip" : "Spotify MetaData")
                .font(.title)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text("Now Playing")
                .font(.title)
            Spacer()
            Text( btcentral.trackInfo.title )
                .font(.largeTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(btcentral.trackInfo.album)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(btcentral.trackInfo.artist )
                .font(.title)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
//            btcentral.trackAlbumArt.image != nil ? btcentral.trackAlbumArt.image! : Image(systemName: "photo")
            /*
             if let imageData = btcentral.trackAlbumArt.imageData {
             imageData.count > 0 ? btcentral.trackAlbumArt.image! : Image(systemName: "photo")
             } else {
             Image(systemName: "photo")
             }
             */
            
            /*
             HStack(alignment:.top) {
             Text("\(Double(btcentral.trackInfo.position).minuteSecond)")
             .font(.footnote)
             Spacer()
             Text( "\(Double(btcentral.trackInfo.duration).minuteSecond)" )
             .font(.footnote)
             }
             .padding(.bottom, 0)
             
             ProgressView(
             "",
             value: Double(btcentral.trackInfo.position),
             total:  Double(btcentral.trackInfo.duration)
             )
             .padding(.top, -10)
             */
            Spacer()
            Spacer()
            
            // Text("track.uri \(spotify.playerState!.track.uri)")
            // Text("track.isSaved \(spotify.playerState!.track.isSaved ? "true" : "false" )")
            // Text("playbackSpeed \(spotify.playerState!.playbackSpeed)")
            // Text("playbackOptions.isShuffling \(spotify.playerState!.playbackOptions.isShuffling ? "true" : "false")")
            // Text("playbackOptions.repeatMode \(spotify.playerState!.playbackOptions.repeatMode.hashValue)")
            // Text("playbackPosition \(spotify.playerState!.playbackPosition)")
        }
        .padding()
        
    }
}

//struct SpotifyView_Previews: PreviewProvider {
//    static var previews: some View {
//        SpotifyView()
//    }
//}

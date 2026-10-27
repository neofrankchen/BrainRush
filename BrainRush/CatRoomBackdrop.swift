import SwiftUI

/// The shared illustrated room, composed separately for tall and wide screens.
struct CatRoomBackdrop: View {
    var body: some View {
        GeometryReader { geometry in
            Image(geometry.size.width > geometry.size.height * 1.15
                  ? "CozyHomeRoomLandscape" : "CozyHomeRoomPortrait")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

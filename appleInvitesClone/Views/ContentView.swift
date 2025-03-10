//
//  ContentView.swift
//  appleInvitesClone
//
//  Created by Justin Hold on 3/10/25.
//

import SwiftUI

struct ContentView: View {
	
	// MARK: - Properties
	@State private var activeCard: Card? = cards.first
	
	
	// MARK: - View Body
    var body: some View {
        
		ZStack {
			/// Ambient background
			AmbientBackground()
			
			VStack(spacing: 40) {
				
				ScrollView(.horizontal) {
					
					HStack(spacing: 10) {
						ForEach(cards) { card in
							CarouselCardView(card)
						}
					}
				}
				.scrollIndicators(.hidden)
				.containerRelativeFrame(.vertical) { value, _ in
					value * 0.45
				}
			}
			.safeAreaPadding(15)
		}
    }
	
	/// Ambient background View
	@ViewBuilder
	private func AmbientBackground() -> some View {
		GeometryReader {
			let size = $0.size
			ZStack {
				ForEach(cards) { card in
					Image(card.image)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.ignoresSafeArea()
						.frame(width: size.width, height: size.height)
						/// Only showing active card
						.opacity(activeCard?.id == card.id ? 1 : 0)
				}
				
				Rectangle()
					.fill(.black.opacity(0.45))
					.ignoresSafeArea()
			}
			.compositingGroup()
			.blur(radius: 90, opaque: true)
			.ignoresSafeArea()
		}
	}
	
	/// Carousel Card View
	@ViewBuilder
	private func CarouselCardView(_ card: Card) -> some View {
		GeometryReader { _ in
			// 
		}
		.frame(width: 220)
	}
	
}

#Preview {
    ContentView()
}

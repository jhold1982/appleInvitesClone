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
	@State private var scrollPosition: ScrollPosition = .init()
	@State private var currentScrollOffset: CGFloat = 0
	@State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
	
	// MARK: - View Body
    var body: some View {
        
		ZStack {
			/// Ambient background
			AmbientBackground()
			
			VStack(spacing: 40) {
				
				InfiniteScrollView  {
					ForEach(cards) { card in
						CarouselCardView(card)
					}
				}
				.scrollIndicators(.hidden)
				.scrollPosition($scrollPosition)
				.containerRelativeFrame(.vertical) { value, _ in
					value * 0.45
				}
			}
			.safeAreaPadding(15)
		}
		.onReceive(timer) { _ in
			currentScrollOffset += 0.35
			scrollPosition.scrollTo(x: currentScrollOffset)
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
		GeometryReader {
			
			let size = $0.size
			
			Image(card.image)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: size.width, height: size.height)
				.clipShape(.rect(cornerRadius: 20))
				.shadow(color: .black.opacity(0.4), radius: 10, x: 1, y: 0)
			
			
		}
		.frame(width: 220)
		.scrollTransition(.interactive.threshold(.centered), axis: .horizontal) { content, phase in
			content
				.offset(y: phase == .identity ? -10 : 0)
				.rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
		}
	}
	
}

#Preview {
    ContentView()
}

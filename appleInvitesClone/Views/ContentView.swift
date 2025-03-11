//
//  ContentView.swift
//  appleInvitesClone
//
//  Created by Justin Hold on 3/10/25.
//

import SwiftUI

/**
 * ContentView - The main view component that creates an immersive, animated card carousel interface
 * with ambient background effects and animated text transitions.
 */
struct ContentView: View {
	
	// MARK: - Properties
	
	/// Currently displayed card in the carousel, initialized with the first card
	@State private var activeCard: Card? = cards.first
	
	/// Tracks the current position in the scroll view for programmatic scrolling
	@State private var scrollPosition: ScrollPosition = .init()
	
	/// Maintains the current horizontal scroll offset for continuous scrolling animation
	@State private var currentScrollOffset: CGFloat = 0
	
	/// Timer that drives the automatic scrolling animation (updates every 0.01 seconds)
	@State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
	
	/// Controls the initial reveal animation of UI elements
	@State private var initialAnimation: Bool = false
	
	/// Controls the progress of the title text animation (0.0 to 1.0)
	@State private var titleProgress: CGFloat = 0
	
	// MARK: - View Body
	var body: some View {
		
		ZStack {
			/// Ambient background that shows a blurred version of the active card
			AmbientBackground()
			
			VStack(spacing: 40) {
				
				/// Infinite scrolling carousel of card images
				InfiniteScrollView {
					ForEach(cards) { card in
						CarouselCardView(card)
					}
				}
				.scrollIndicators(.hidden)  // Hide scroll indicators for a cleaner UI
				.scrollPosition($scrollPosition)  // Bind to track and control scroll position
				.containerRelativeFrame(.vertical) { value, _ in
					// Set carousel height to 45% of the container height
					value * 0.45
				}
				.onScrollGeometryChange(for: CGFloat.self) {
					// Calculate absolute scroll position including content insets
					$0.contentOffset.x + $0.contentInsets.leading
				} action: { oldValue, newValue in
					// Update tracked scroll position when user scrolls
					currentScrollOffset = newValue
				}
				.visualEffect { [initialAnimation] content, proxy in
					content
						// Initially position carousel off-screen until animation starts
						.offset(y: !initialAnimation ? -(proxy.size.height + 200) : 0)
				}
				
				/// Text content section with animated appearance
				VStack(spacing: 4) {
					Text("Welcome to")
						.fontWeight(.semibold)
						.foregroundStyle(.white.secondary)
						.blurOpacityEffect(initialAnimation)  // Fade in with blur effect
					
					Text("TOOL")
						.font(.largeTitle.bold())
						.foregroundStyle(.white)
						.padding(.bottom, 12)
						.textRenderer(TitleTextRenderer(progress: titleProgress))  // Custom animated text effect
					
					Text("PASTE LYRICS HERE")
						.font(.callout)
						.multilineTextAlignment(.center)
						.foregroundStyle(.white.secondary)
						.blurOpacityEffect(initialAnimation)  // Fade in with blur effect
				}
				
				/// Call-to-action button
				Button {
					/// Cancel timer before executing button action to stop auto-scrolling
					timer.upstream.connect().cancel()
					/// Button Action would be implemented here
					
				} label: {
					Text("Spiral Out")
						.fontWeight(.semibold)
						.foregroundStyle(.black)
						.padding(.horizontal, 15)
						.padding(.vertical, 12)
						.background(.white, in: .capsule)  // White capsule-shaped button
				}
			}
			.safeAreaPadding(15)  // Add padding that respects safe areas
		}
		.onReceive(timer) { _ in
			// Auto-scroll the carousel by incrementing offset on each timer tick
			currentScrollOffset += 0.35
			scrollPosition.scrollTo(x: currentScrollOffset)
		}
		.task {
			// Short delay before starting animations
			try? await Task.sleep(for: .seconds(0.35))
			
			// Animate the UI elements into view
			withAnimation(.smooth(duration: 0.75)) {
				initialAnimation = true
			}
			
			// Animate the title text with custom renderer effect
			withAnimation(.smooth(duration: 2.5).delay(0.3)) {
				titleProgress = 1
			}
		}
	}
	
	/**
	 * Creates a blurred ambient background effect based on the currently active card.
	 * This view takes the current card's image, blurs it significantly, and displays it
	 * as a full-screen background to create an immersive, contextual environment.
	 *
	 * @return A view that displays a heavily blurred version of the active card's image
	 */
	@ViewBuilder
	private func AmbientBackground() -> some View {
		GeometryReader { proxy in
			let size = proxy.size
			
			ZStack {
				// Dynamically show the active card's image as background
				ForEach(cards) { card in
					Image(card.image)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.ignoresSafeArea()
						.frame(width: size.width, height: size.height)
						// Only show the image for the currently active card
						.opacity(activeCard?.id == card.id ? 1 : 0)
				}
				
				// Overlay a semi-transparent black layer to reduce contrast and improve readability
				Rectangle()
					.fill(.black.opacity(0.45))
					.ignoresSafeArea()
			}
			// Group the layers together before applying effects
			.compositingGroup()
			// Apply a strong blur effect to create the ambient background
			.blur(radius: 90, opaque: true)
			.ignoresSafeArea()
		}
	}
	
	/**
	 * Renders an individual card in the carousel with custom styling and animation.
	 * Each card displays an image with shadow effects and custom transition animations
	 * when scrolling through the carousel.
	 *
	 * @param card The Card model containing the image and other data to display
	 * @return A styled view representing a single card in the carousel
	 */
	@ViewBuilder
	private func CarouselCardView(_ card: Card) -> some View {
		GeometryReader { proxy in
			let size = proxy.size
			
			Image(card.image)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: size.width, height: size.height)
				.clipShape(.rect(cornerRadius: 20))
				// Add shadow for depth effect
				.shadow(color: .black.opacity(0.4), radius: 10, x: 1, y: 0)
		}
		// Set a fixed width for all cards in the carousel
		.frame(width: 220)
		// Apply animated transitions when scrolling through the carousel
		.scrollTransition(.interactive.threshold(.centered), axis: .horizontal) { content, phase in
			content
				// Lift the active card slightly upward
				.offset(y: phase == .identity ? -10 : 0)
				// Apply a slight rotation effect based on scroll position
				.rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
		}
	}
}

/**
 * Extension that adds a reusable animation effect combining blur, opacity, and scale.
 * This creates a smooth appearance/disappearance transition that can be toggled.
 *
 * @param show Boolean flag to control whether the effect is active or not
 * @return A view with the combined transition effects applied
 */
extension View {
	func blurOpacityEffect(_ show: Bool) -> some View {
		self
			// Blur effect (clear when shown, blurred when hidden)
			.blur(radius: show ? 0 : 2)
			// Opacity effect (visible when shown, invisible when hidden)
			.opacity(show ? 1 : 0)
			// Scale effect (full size when shown, slightly smaller when hidden)
			.scaleEffect(show ? 1 : 0.9)
	}
}
#Preview {
    ContentView()
}

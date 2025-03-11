//
//  ContentView.swift
//  appleInvitesClone
//
//  Created by Justin Hold on 3/10/25.
//

import SwiftUI

/**
 * ContentView - A sophisticated view component that implements an immersive, animated card carousel interface
 * with dynamic ambient background effects and fluid text transitions.
 *
 * This component serves as the main UI container, combining several specialized subviews to create
 * a cohesive, responsive user experience with continuous animations and interactive elements.
 */
struct ContentView: View {
	
	// MARK: - State Properties
	
	/// Currently active card displayed prominently in the carousel
	/// Initialized with the first card in the collection
	@State private var activeCard: Card? = cards.first
	
	/// Tracks and manages the current position within the scroll view
	/// Enables programmatic control of scrolling behavior
	@State private var scrollPosition: ScrollPosition = .init()
	
	/// Maintains the absolute horizontal scroll offset in points
	/// Used to calculate current position and drive continuous scrolling animations
	@State private var currentScrollOffset: CGFloat = 0
	
	/// Timer that powers the automatic scrolling animation
	/// Updates at 100Hz (every 0.01 seconds) for smooth motion
	@State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
	
	/// Controls the initial reveal animation sequence of UI elements
	/// When false, elements are positioned off-screen or have reduced opacity
	@State private var initialAnimation: Bool = false
	
	/// Controls the progress of the title text animation
	/// Ranges from 0.0 (not started) to 1.0 (fully complete)
	@State private var titleProgress: CGFloat = 0
	
	/// Tracks the current scrolling behavior phase
	/// Used to differentiate between user-initiated and programmatic scrolling
	@State private var scrollPhase: ScrollPhase = .idle
	
	// MARK: - View Construction
	var body: some View {
		
		ZStack {
			/// Dynamic ambient background that displays a heavily blurred version of the active card
			/// Creates an immersive environment that shifts with carousel content
			AmbientBackground()
				.animation(.easeInOut(duration: 1), value: activeCard)
			
			VStack(spacing: 40) {
				
				/// Implements an infinite scrolling carousel of card images
				/// Automatically advances while also supporting user interaction
				InfiniteScrollView {
					ForEach(cards) { card in
						CarouselCardView(card)
					}
				}
				.scrollIndicators(.hidden)  // Suppress scroll indicators for a cleaner visual presentation
				.scrollPosition($scrollPosition)  // Bind to state for position tracking and programmatic control
				.scrollClipDisabled()
				.containerRelativeFrame(.vertical) { value, _ in
					// Dynamically size carousel to 45% of the available container height
					value * 0.45
				}
				.onScrollPhaseChange { oldPhase, newPhase in
					// Track transitions between scrolling states (idle, dragging, decelerating)
					scrollPhase = newPhase
				}
				.onScrollGeometryChange(for: CGFloat.self) {
					// Calculate absolute scroll position including content insets for consistent positioning
					$0.contentOffset.x + $0.contentInsets.leading
				} action: { oldValue, newValue in
					// Update tracked scroll position when position changes (user or programmatic)
					currentScrollOffset = newValue
					
					// Only update the active card when not in an animation transition
					if scrollPhase != .decelerating || scrollPhase != .animating {
						let activeIndex = Int((currentScrollOffset / 220).rounded()) % cards.count
						activeCard = cards[activeIndex]
					}
				}
				.visualEffect { [initialAnimation] content, proxy in
					content
						// Initially position carousel off-screen until entrance animation activates
						.offset(y: !initialAnimation ? -(proxy.size.height + 200) : 0)
				}
				
				/// Text content section with multi-stage animated appearance
				/// Includes title, subtitle, and descriptive text with varying animation treatments
				VStack(spacing: 4) {
					Text("Welcome to")
						.fontWeight(.semibold)
						.foregroundStyle(.white.secondary)
						.blurOpacityEffect(initialAnimation)  // Fade in with combined blur/opacity/scale effect
					
					Text("TOOL")
						.font(.largeTitle.bold())
						.foregroundStyle(.white)
						.padding(.bottom, 12)
						.textRenderer(TitleTextRenderer(progress: titleProgress))  // Apply custom animated text renderer
					
					Text("PASTE LYRICS HERE")
						.font(.callout)
						.multilineTextAlignment(.center)
						.foregroundStyle(.white.secondary)
						.blurOpacityEffect(initialAnimation)  // Synchronized fade-in with subtitle
				}
				
				/// Interactive call-to-action button
				/// Stops automatic scrolling when pressed before executing primary action
				Button {
					/// Cancel ongoing timer to halt automatic scrolling prior to action execution
					timer.upstream.connect().cancel()
					/// Primary button action implementation would be placed here
					
				} label: {
					Text("Spiral Out")
						.fontWeight(.semibold)
						.foregroundStyle(.black)
						.padding(.horizontal, 15)
						.padding(.vertical, 12)
						.background(.white, in: .capsule)  // High-contrast white button against dark background
				}
			}
			.safeAreaPadding(15)  // Apply consistent padding that respects device-specific safe areas
		}
		.onReceive(timer) { _ in
			// Implement automatic scrolling by incrementing offset on each timer tick
			// Increment of 0.35 points creates smooth continuous motion at 100Hz update rate
			currentScrollOffset += 0.35
			scrollPosition.scrollTo(x: currentScrollOffset)
		}
		.task {
			// Brief initial delay before commencing animation sequence
			try? await Task.sleep(for: .seconds(0.35))
			
			// Trigger main UI element entrance animation with smooth easing
			withAnimation(.smooth(duration: 0.75)) {
				initialAnimation = true
			}
			
			// Trigger specialized title text animation with slight delay for sequential effect
			withAnimation(.smooth(duration: 2.5).delay(0.3)) {
				titleProgress = 1
			}
		}
	}
	
	/**
	 * AmbientBackground - Creates a dynamic, responsive background environment
	 *
	 * This view generates an immersive backdrop by taking the current card's image,
	 * applying significant blur and tinting effects, and displaying it as a full-screen
	 * background. The result is a contextual, soft-focus environment that shifts in
	 * response to the active carousel item.
	 *
	 * The implementation uses multiple layers:
	 * 1. The active card's image scaled to fill the screen
	 * 2. A semi-transparent black overlay for contrast reduction
	 * 3. Heavy blur effects for a soft ambient glow
	 *
	 * @return A responsive view that displays a heavily processed version of the active card's image
	 */
	@ViewBuilder
	private func AmbientBackground() -> some View {
		GeometryReader { proxy in
			let size = proxy.size
			
			ZStack {
				// Dynamically display the active card's image as background
				// Only the current card's image is visible, others have zero opacity
				ForEach(cards) { card in
					Image(card.image)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.ignoresSafeArea()
						.frame(width: size.width, height: size.height)
						// Show only the image corresponding to the active card
						.opacity(activeCard?.id == card.id ? 1 : 0)
				}
				
				// Apply a semi-transparent black overlay to reduce visual contrast
				// This improves text readability against the varying background images
				Rectangle()
					.fill(.black.opacity(0.45))
					.ignoresSafeArea()
			}
			// Group the layers for efficient application of shared effects
			.compositingGroup()
			// Apply intensive blur for the soft ambient effect
			// The 'opaque' parameter ensures consistent rendering performance
			.blur(radius: 90, opaque: true)
			.ignoresSafeArea()
		}
	}
	
	/**
	 * CarouselCardView - Renders an individual card within the carousel
	 *
	 * This component is responsible for displaying each card in the carousel with
	 * appropriate styling, shadows, and interactive transition effects. The cards
	 * respond to scrolling with subtle rotation and elevation changes to create
	 * a dynamic, engaging interface.
	 *
	 * Each card features:
	 * - Consistent sizing with rounded corners
	 * - Depth-enhancing shadow effects
	 * - Interactive scroll transitions including rotation and elevation changes
	 *
	 * @param card The Card model containing image data and metadata to display
	 * @return A fully styled and interactive view representing a single carousel item
	 */
	@ViewBuilder
	private func CarouselCardView(_ card: Card) -> some View {
		GeometryReader { proxy in
			let size = proxy.size
			
			Image(card.image)
				.resizable()
				.aspectRatio(contentMode: .fill)
				.frame(width: size.width, height: size.height)
				.clipShape(.rect(cornerRadius: 20))  // Apply rounded corners for a modern aesthetic
				// Add directional shadow for subtle depth and elevation effect
				.shadow(color: .black.opacity(0.4), radius: 10, x: 1, y: 0)
		}
		// Establish consistent width across all carousel cards
		.frame(width: 220)
		// Apply interactive transitions when scrolling through the carousel
		// These effects are triggered based on the card's position relative to the viewport center
		.scrollTransition(.interactive.threshold(.centered), axis: .horizontal) { content, phase in
			content
				// Elevate the centered card with a slight upward offset
				.offset(y: phase == .identity ? -10 : 0)
				// Apply proportional rotation based on the card's position relative to center
				.rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
		}
	}
}

/**
 * View Extension: blurOpacityEffect
 *
 * This extension provides a reusable composite animation effect that combines
 * blur, opacity, and scale transformations. It creates a smooth, multi-dimensional
 * transition for UI elements appearing or disappearing.
 *
 * The effect combines:
 * - Blur radius transition (from blurred to sharp or vice versa)
 * - Opacity transition (from transparent to opaque or vice versa)
 * - Scale transition (from slightly reduced to full size or vice versa)
 *
 * @param show Boolean flag determining whether the element should be fully visible (true) or hidden (false)
 * @return A modified view with the combined transition effects applied
 */
extension View {
	func blurOpacityEffect(_ show: Bool) -> some View {
		self
			// Transition from blurred (radius 2) to sharp (radius 0) when showing
			.blur(radius: show ? 0 : 2)
			// Transition from invisible (opacity 0) to visible (opacity 1) when showing
			.opacity(show ? 1 : 0)
			// Transition from slightly reduced (scale 0.9) to full size (scale 1) when showing
			.scaleEffect(show ? 1 : 0.9)
	}
}
#Preview {
    ContentView()
}

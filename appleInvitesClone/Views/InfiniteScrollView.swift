//
//  InfiniteScrollView.swift
//  appleInvitesClone
//
//  Created by Justin Hold on 3/10/25.
//

import SwiftUI

/**
 * InfiniteScrollView creates a horizontally scrolling view that loops infinitely.
 * It duplicates content to give the illusion of infinite scrolling by cleverly
 * repositioning the content when scrolled beyond boundaries.
 *
 * The implementation combines SwiftUI's declarative approach with UIKit's UIScrollView
 * to achieve smooth infinite scrolling behavior not natively available in SwiftUI.
 */
struct InfiniteScrollView<Content: View>: View {
	
	// MARK: - Properties
	
	/// Spacing between items in the horizontal stack
	var spacing: CGFloat = 10
	
	/// Content to be displayed and repeated in the infinite scroll view
	@ViewBuilder var content: Content
	
	/// Tracks the size of the content to calculate repetition
	@State private var contentSize: CGSize = .zero
	
	// MARK: - View Body
	var body: some View {
		
		GeometryReader { proxy in
			let size = proxy.size
			
			ScrollView(.horizontal) {
				
				HStack(spacing: spacing) {
					// Use Group to process subviews of content
					Group(subviews: content) { collection in
						
						// First display of the original content collection
						HStack(spacing: spacing) {
							ForEach(collection) { view in
								view
							}
						}
						// Measure the content size to calculate repetition needs
						.onGeometryChange(for: CGSize.self) {
							$0.size
						} action: { newValue in
							contentSize = .init(
								width: newValue.width + spacing,
								height: newValue.height
							)
						}
						
						// Calculate how many repetitions are needed to fill the screen
						// based on the average width of items
						let averageWidth = contentSize.width / CGFloat(collection.count)
						let repeatingCount = contentSize.width > 0 ? Int((size.width / averageWidth).rounded()) + 1 : 1
						
						// Create repeated copies to allow infinite scrolling appearance
						HStack(spacing: spacing) {
							ForEach(0..<repeatingCount, id: \.self) { index in
								// Use modulo to cycle through the collection
								let view = Array(collection)[index % collection.count]
								view
							}
						}
					}
				}
				// Add the helper that implements the infinite scrolling behavior
				// by manipulating the underlying UIScrollView
				.background(
					InfiniteScrollViewHelper(
						decelerationRate: .constant(.fast),
						contentSize: $contentSize
					)
				)
			}
		}
	}
}

/**
 * A UIViewRepresentable struct that helps manage infinite scrolling behavior in SwiftUI.
 * This helper integrates with UIKit's UIScrollView to extend scrolling capabilities
 * beyond what's natively available in SwiftUI.
 */
fileprivate struct InfiniteScrollViewHelper: UIViewRepresentable {
	
	/// The deceleration rate to apply to the scroll view after the user lifts their finger
	@Binding var decelerationRate: UIScrollView.DecelerationRate
	
	/// The size of the content being displayed, used to determine scroll boundaries
	@Binding var contentSize: CGSize
	
	/**
	 * Creates and returns a coordinator to manage the UIScrollView's delegate methods.
	 * The coordinator will handle scroll events and apply custom behaviors.
	 *
	 * @return The coordinator instance that will manage the scrolling behavior
	 */
	func makeCoordinator() -> Coordinator {
		Coordinator(declarationRate: decelerationRate, contentSize: contentSize)
	}
	
	/**
	 * Creates and returns a UIView that will be used to find and configure the parent UIScrollView.
	 * This view is inserted into the view hierarchy to gain access to the UIScrollView.
	 *
	 * @param context The context containing environment information
	 * @return An empty UIView that will be used to locate the parent ScrollView
	 */
	func makeUIView(context: Context) -> UIView {
		
		// Create an empty, transparent view
		let view = UIView(frame: .zero)
		view.backgroundColor = .clear
		
		// Defer ScrollView configuration to ensure the view hierarchy is fully established
		DispatchQueue.main.async {
			if let scrollView = view.scrollView {
				// Store the original delegate and set up our custom deceleration rate
				context.coordinator.defaultDelegate = scrollView.delegate
				scrollView.decelerationRate = decelerationRate
			}
		}
		
		return view
	}
	
	/**
	 * Updates the UIView when SwiftUI state changes.
	 * Updates the deceleration rate and content size in the coordinator.
	 *
	 * @param uiView The UIView instance to update
	 * @param context The context containing the coordinator and environment information
	 */
	func updateUIView(_ uiView: UIView, context: Context) {
		context.coordinator.decelarationRate = decelerationRate
		context.coordinator.contentSize = contentSize
	}
	
	/**
	 * Coordinator class that acts as the UIScrollViewDelegate.
	 * Manages scroll events and implements the infinite scrolling behavior
	 * by repositioning content when boundaries are reached.
	 */
	class Coordinator: NSObject, UIScrollViewDelegate {
		
		/// The deceleration rate to apply to the scroll view
		var decelarationRate: UIScrollView.DecelerationRate
		
		/// The size of the content being displayed, used to determine scroll boundaries
		var contentSize: CGSize
		
		/**
		 * Initializes a new Coordinator with the specified deceleration rate and content size.
		 *
		 * @param declarationRate The deceleration rate to use for scroll view momentum
		 * @param contentSize The size of the content for boundary calculations
		 */
		init(declarationRate: UIScrollView.DecelerationRate, contentSize: CGSize) {
			self.decelarationRate = declarationRate
			self.contentSize = contentSize
		}
		
		/// Stores the original scroll view delegate to forward events to
		weak var defaultDelegate: UIScrollViewDelegate?
		
		/**
		 * Delegate method called when the scroll view's content moves.
		 * Implements the infinite scrolling behavior by repositioning content
		 * when the user scrolls beyond the content boundaries.
		 *
		 * @param scrollView The scroll view that's being scrolled
		 */
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			
			// Apply the current deceleration rate
			scrollView.decelerationRate = decelarationRate
			
			let minX = scrollView.contentOffset.x
			
			// If scrolled past the right edge, loop back to the left
			if minX > contentSize.width {
				scrollView.contentOffset.x -= contentSize.width
			}
			
			// If scrolled past the left edge, loop back to the right
			if minX < 0 {
				scrollView.contentOffset.x += contentSize.width
			}
			
			// Forward the scrolling event to the original delegate
			defaultDelegate?.scrollViewDidScroll?(scrollView)
		}
		
		/**
		 * Called when the user lifts their finger from the screen.
		 * Forwards the event to the original delegate.
		 */
		func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
			defaultDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
		}
		
		/**
		 * Called when the scroll view is about to start decelerating.
		 * Forwards the event to the original delegate.
		 */
		func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
			defaultDelegate?.scrollViewWillBeginDecelerating?(scrollView)
		}
		
		/**
		 * Called when the user begins dragging the scroll view.
		 * Forwards the event to the original delegate.
		 */
		func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
			defaultDelegate?.scrollViewWillBeginDragging?(scrollView)
		}
		
		/**
		 * Called when the user is about to end dragging the scroll view.
		 * Forwards the event to the original delegate, preserving all parameters.
		 */
		func scrollViewWillEndDragging(
			_ scrollView: UIScrollView,
			withVelocity velocity: CGPoint,
			targetContentOffset: UnsafeMutablePointer<CGPoint>
		) {
			defaultDelegate?.scrollViewWillEndDragging?(
				scrollView,
				withVelocity: velocity,
				targetContentOffset: targetContentOffset
			)
		}
	}
}

/**
 * Extension to UIView that provides a convenient way to find the nearest parent UIScrollView.
 * Recursively traverses the view hierarchy to locate a UIScrollView ancestor.
 */
extension UIView {
	/**
	 * Recursively searches up the view hierarchy to find a parent UIScrollView.
	 * This property allows the InfiniteScrollViewHelper to access the underlying
	 * UIScrollView within the SwiftUI view hierarchy.
	 *
	 * @return The nearest parent UIScrollView, or nil if none exists
	 */
	var scrollView: UIScrollView? {
		if let superview, superview is UIScrollView {
			return superview as? UIScrollView
		}
		
		return superview?.scrollView
	}
}

#Preview {
    ContentView()
}

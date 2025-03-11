//
//  InfiniteScrollView.swift
//  appleInvitesClone
//
//  Created by Justin Hold on 3/10/25.
//

import SwiftUI

struct InfiniteScrollView<Content: View>: View {
	
	// MARK: - Properties
	var spacing: CGFloat = 10
	
	@ViewBuilder var content: Content
	@State private var contentSize: CGSize = .zero
	
	// MARK: - View Body
    var body: some View {
        
		GeometryReader {
			let size = $0.size
			
			ScrollView(.horizontal) {
				
				HStack(spacing: spacing) {
					Group(subviews: content) { collection in
						
						HStack(spacing: spacing) {
							ForEach(collection) { view in
								view
							}
						}
						.onGeometryChange(for: CGSize.self) {
							$0.size
						} action: { newValue in
							contentSize = .init(
								width: newValue.width + spacing,
								height: newValue.height
							)
						}
						
						let averageWidth = contentSize.width / CGFloat(collection.count)
						let repeatingCount = contentSize.width > 0 ? Int((size.width / averageWidth).rounded()) + 1 : 1
						
						HStack(spacing: spacing) {
							ForEach(0..<repeatingCount, id: \.self) { index in
								
								let view = Array(collection)[index % collection.count]
								
								view
							}
						}
					}
				}
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
				context.coordinator.defaultDelegate = scrollView.delegate
				scrollView.decelerationRate = decelerationRate
			}
		}
		
		return view
	}
	
	/**
	 * Updates the UIView when SwiftUI state changes.
	 * Currently only updates the deceleration rate in the coordinator.
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
	 * Manages scroll events and behavior customization.
	 */
	class Coordinator: NSObject, UIScrollViewDelegate {
		
		/// The deceleration rate to apply to the scroll view
		var decelarationRate: UIScrollView.DecelerationRate
		
		var contentSize: CGSize
		/**
		 * Initializes a new Coordinator with the specified deceleration rate.
		 *
		 * @param declarationRate The deceleration rate to use for scroll view momentum
		 */
		init(declarationRate: UIScrollView.DecelerationRate, contentSize: CGSize) {
			self.decelarationRate = declarationRate
			self.contentSize = contentSize
		}
		
		weak var defaultDelegate: UIScrollViewDelegate?
		
		/**
		 * Delegate method called when the scroll view's content moves.
		 * Currently empty, but would be the place to implement custom scroll behaviors.
		 *
		 * @param scrollView The scroll view that's being scrolled
		 */
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			
			scrollView.decelerationRate = decelarationRate
			
			let minX = scrollView.contentOffset.x
			
			if minX > contentSize.width {
				scrollView.contentOffset.x -= contentSize.width
			}
			
			if minX < 0 {
				scrollView.contentOffset.x += contentSize.width
			}
			
			defaultDelegate?.scrollViewDidScroll?(scrollView)
		}
		
		func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
			defaultDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
		}
		
		func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
			defaultDelegate?.scrollViewWillBeginDecelerating?(scrollView)
		}
		
		func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
			defaultDelegate?.scrollViewWillBeginDragging?(scrollView)
		}
		
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

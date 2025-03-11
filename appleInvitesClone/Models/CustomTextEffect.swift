//
//  CustomTextEffect.swift
//  appleInvitesClone
//
//  Created by Justin Hold on 3/11/25.
//

import Foundation
import SwiftUI

/**
 * A specialized text renderer that creates an animated text appearance effect.
 * This renderer implements both TextRenderer and Animatable protocols to enable
 * smooth animations when rendering text in SwiftUI.
 */
struct TitleTextRenderer: TextRenderer, Animatable {
	
	/// The current animation progress value (0.0 to 1.0)
	/// - 0.0 represents the start of the animation (text invisible)
	/// - 1.0 represents the end of the animation (text fully visible)
	var progress: CGFloat
	
	/**
	 * Required property for the Animatable protocol that enables SwiftUI
	 * to animate changes to the progress value.
	 *
	 * This computed property acts as a bridge between the animation system
	 * and our progress value.
	 */
	var animatableData: CGFloat {
		get { progress }
		set { progress = newValue }
	}
	
	/**
	 * Draws the text with a custom fade-in and blur animation effect.
	 * Each text slice (typically a glyph) is individually animated based on its index
	 * and the current overall animation progress.
	 *
	 * @param layout The text layout information provided by SwiftUI
	 * @param ctx The graphics context used for drawing
	 */
	func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
		// Flatten the hierarchical layout data structure into a linear array of slices
		// (Layout → Lines → Runs → Slices, where slices typically represent glyphs)
		let slices = layout.flatMap({ $0 }).flatMap({ $0 })
		
		// Draw each slice with progressive animation based on its index
		for (index, slice) in slices.enumerated() {
			// Calculate how much of the animation applies to this particular slice
			// Earlier slices (lower index) will animate before later ones
			let sliceProgressIndex = CGFloat(slices.count) * progress
			let sliceProgress = max(min(sliceProgressIndex / CGFloat(index + 1), 1), 0)
			
			// Apply decreasing blur effect as animation progresses (5px → 0px)
			ctx.addFilter(.blur(radius: 5 - (5 * sliceProgress)))
			
			// Increase opacity from 0 to 1 as animation progresses
			ctx.opacity = sliceProgress
			
			// Move text upward as animation progresses (5px → 0px)
			ctx.translateBy(x: 0, y: 5 - (5 * sliceProgress))
			
			// Draw the text slice with pixel-perfect rendering
			ctx.draw(slice, options: .disablesSubpixelQuantization)
		}
	}
}


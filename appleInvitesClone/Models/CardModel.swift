//
//  CardModel.swift
//  appleInvitesClone
//
//  Created by Justin Hold on 3/10/25.
//

import Foundation
import SwiftUI

// Card represents a single card in the application
// It conforms to Identifiable protocol for unique identification in collections
// and Hashable for use in Sets or as Dictionary keys
struct Card: Identifiable, Hashable {
	// Unique identifier for each card instance
	// Automatically generated using UUID to ensure uniqueness
	var id: String = UUID().uuidString
	
	// The name of the image asset to be displayed for this card
	// This string should match an image name in the asset catalog
	var image: String
}

// Pre-defined collection of Card instances for use in the application
// Each card is initialized with a specific image name from the asset catalog
let cards: [Card] = [
	// Creates a card with the "collectiveVision" image
	.init(image: "collectiveVision"),
	// Creates a card with the "death" image
	.init(image: "death"),
	// Creates a card with the "heptagram" image
	.init(image: "heptagram"),
	// Creates a card with the "lateralus" image
	.init(image: "lateralus"),
	// Creates a card with the "theGreatTurn" image
	.init(image: "theGreatTurn")
]


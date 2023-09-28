//
//  ClassifierStage.m
//  Gesture Control
//
//  Created by Bryan Herman on 2/14/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import "ClassifierStage.h"

@implementation ClassifierStage

@synthesize threshold;

// Constructor
- (id) init {
	self = [super init];
	haarFeatures = [[NSMutableArray alloc] init];
	threshold = 0;
	
	return self;
}


// Unarchiver
- (id) initWithCoder: (NSCoder*)decoder {
	self = [super init];
	haarFeatures = [[decoder decodeObjectForKey:@"haarFeatures"] mutableCopy];
	threshold = [decoder decodeDoubleForKey:@"stageThreshold"];
	
	return self;
}


// Archiver
- (void) encodeWithCoder: (NSCoder*)encoder {
	[encoder encodeObject:haarFeatures forKey:@"haarFeatures"];
	[encoder encodeDouble:threshold forKey:@"stageThreshold"];
}


// Add the specified Haar feature to this classifier.
- (void) addFeature: (HaarFeature*)feature {
	// cloning allows the threshold to be different for the same feature across
	// multiple instances of it both witihin the same classifier and between
	// different classifiers
	[haarFeatures addObject: [feature clone]];
	threshold += feature.weight / 2;
}


// Remove the most recently added feature.
- (void) removeLastFeature {
	[haarFeatures removeLastObject];
}


// Classify the subwindow starting at the specified origin.
- (BOOL) classify: (NSMutableArray*)integralImageSums
			   at: (NSPoint)origin {
	double total = 0;
	for (HaarFeature* feature in haarFeatures)
		if ([feature classify:integralImageSums
						   at:origin])
			total += feature.weight;
	return total >= threshold;
}

@end

//
//  Classifier.m
//  Gesture Control
//
//  Created by Bryan Herman on 2/3/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#ifndef CLASSIFIER
#define CLASSIFIER

#import "CascadeClassifier.h"

@implementation CascadeClassifier

// Constructor
- (id) init {
	self = [super init];
	stages = [[NSMutableArray alloc] init];
	
	return self;
}


// Unarchiver
- (id) initWithCoder: (NSCoder*)decoder {
	self = [super init];
	stages = [[decoder decodeObjectForKey:@"classifierStages"] mutableCopy];
	
	return self;
}


// Archiver
- (void) encodeWithCoder: (NSCoder*)encoder {
	[encoder encodeObject:stages forKey:@"classifierStages"];
}


//- (void)saveToFile: (NSString*)path {
//	NSString* output = [NSString stringWithFormat:@"%d", (int)[stages count]];
//	[output writeToFile:path atomically:YES encoding:NSASCIIStringEncoding error:nil];
//}


// Add a stage to this classifier.
- (void) addStage: (ClassifierStage*)stage {
	[stages addObject: stage];
}


- (void)removeLastStage {
	[stages removeLastObject];
}


// Classify an image using the specified number of subwindows.
- (NSMutableArray*) classify: (NSMutableArray*)integralImageSums : (int)subwindows {
	const int USABLE_WIDTH = (int)[integralImageSums count] - HaarFeature.width;
	const int USABLE_HEIGHT = (int)[integralImageSums[0] count] - HaarFeature.height;
	
	// columns / rows = width / height
	// columns * rows ≤ subwindows
	// subwindowsPerRow = columns = √(s * w / h)
	const int subwindowsPerRow = sqrt(subwindows * USABLE_WIDTH / USABLE_HEIGHT);
	const int widthBetweenSubwindows = USABLE_WIDTH / subwindowsPerRow;
	
	// columns / rows = width / height
	// columns * rows ≤ subwindows
	// subwindowsPerColumn = rows = √(s * h / w)
	const int subwindowsPerColumn = sqrt(subwindows * USABLE_HEIGHT / USABLE_WIDTH);
	const int heightBetweenSubwindows = USABLE_HEIGHT / subwindowsPerColumn;
	
	NSMutableArray* subwindowIncluded = [[NSMutableArray alloc] initWithCapacity: subwindowsPerRow];
	for (int i = 0; i < subwindowsPerRow; i++)
		subwindowIncluded[i] = [[NSMutableArray alloc] initWithCapacity: subwindowsPerColumn];
	for (int i = 0; i < subwindowsPerRow; i++)
	for (int j = 0; j < subwindowsPerColumn; j++)
		subwindowIncluded[i][j] = [[NSNumber alloc] initWithBool:YES];
	
	for (int y = 0; y < subwindowsPerColumn; y++)
	for (int x = 0; x < subwindowsPerRow; x++)
		for (int stageIndex = 0; stageIndex < [stages count]; stageIndex++){
			NSPoint origin;
			origin.x = x * widthBetweenSubwindows;
			origin.y = y * heightBetweenSubwindows;
			
			// if any stage classifies the subwindow as negative, exclude it
			if (![stages[stageIndex] classify:integralImageSums
										   at:origin]){
				subwindowIncluded[x][y] = [[NSNumber alloc] initWithBool:NO];
				break;
			}
		}
	
	return subwindowIncluded;
}

@end

#endif

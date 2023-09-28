//
//  Trainer.h
//  Gesture Control
//
//  Created by Bryan Herman on 2/4/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CascadeClassifier.h"
#import "DataSet.h"

@interface Trainer : NSObject {
	int NUMBER_OF_HAAR_FEATURES;
	int NUMBER_OF_POINTS;
	double STEP_SIZE;
	
	int USABLE_WIDTH;
	int USABLE_HEIGHT;
	int subwindowsPerRow;
	int widthBetweenSubwindows;
	int subwindowsPerColumn;
	int heightBetweenSubwindows;
	
	NSMutableArray* haarFeatures;
	NSMutableArray* haarFeatureErrors;
	
	DataSet* data;
	NSMutableArray* correctlyClassified;
	NSMutableArray* integralImageSums;
	NSMutableArray* correctClassifications;
}

@property (readonly) CascadeClassifier* classifier;

- (id) init: (DataSet*)dataSet;
- (void) train: (double)maxError withSubwindows: (int)subwindows;

@end

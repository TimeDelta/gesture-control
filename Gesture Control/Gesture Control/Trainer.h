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
#import "LongDouble.h"

@interface Trainer : NSObject {
//	int NUMBER_OF_POINTS;
//	double STEP_SIZE;
	
	int USABLE_WIDTH;
	int USABLE_HEIGHT;
	int subwindows;
	int subwindowsPerRow;
	int widthBetweenSubwindows;
	int subwindowsPerColumn;
	int heightBetweenSubwindows;
	
	NSMutableArray* haarFeatures;
	
	DataSet* data;
	NSArray* files;
	NSMutableArray* correctlyClassified;
	NSMutableArray* integralImageSums;
	NSMutableArray* correctClassifications;
	long double positives;
	long double negatives;
	
	double MIN_DISTANCE_FROM_FIFTY_PERCENT;
	double MIN_TRUE_POS_RATE;
	double MAX_TRUE_POS_RATE;
	double MIN_FALSE_POS_RATE;
	double MAX_FALSE_POS_RATE;
	
	BOOL firstStage;
}

@property (readonly) CascadeClassifier* classifier;

- (id) init: (DataSet*)dataSet : (NSMutableArray*)integralImage;
- (double) train: (double)maxError
	  subwindows: (int)subwindows
  firstStageSize: (int)firstStageSize
   stageStepSize: (int)stageStepSize;
- (double)calculateClassifierTruePositiveRate;

@end

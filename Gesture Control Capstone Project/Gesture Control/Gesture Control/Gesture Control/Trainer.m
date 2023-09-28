//
//  Trainer.m
//  Gesture Control
//
//  Created by Bryan Herman on 2/4/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import "Trainer.h"

@implementation Trainer

@synthesize classifier;

- (id)init: (DataSet*)dataSet {
	self = [super init];
	
	NUMBER_OF_POINTS = 400;
	STEP_SIZE = .25;
	
	classifier = [[CascadeClassifier alloc] init];
	haarFeatureErrors = [[NSMutableArray alloc] initWithCapacity: NUMBER_OF_HAAR_FEATURES];
	
	haarFeatures = [[NSMutableArray alloc] initWithCapacity: NUMBER_OF_HAAR_FEATURES];
	
	data = dataSet;
	
	// get all files in the haar features folder that match "*.png"
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* folder = @"/Users/bryanherman/Desktop/Gesture Control/Haar Features/";
	NSArray* files = [fileManager contentsOfDirectoryAtPath:folder error:nil];
	NSPredicate* filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"];
	files = [files filteredArrayUsingPredicate:filter];
	
	// initialize the haar features
	for (int i = 0; i < [files count]; i++){
		NSURL* url = [[NSURL alloc] initFileURLWithPath:[folder stringByAppendingString:files[i]]];
		CGImageSourceRef isr = CGImageSourceCreateWithURL( (__bridge CFURLRef)url, NULL);
		
		NSDictionary *options = [NSDictionary dictionaryWithObject: (id)kCFBooleanTrue  forKey: (id) kCGImageSourceShouldCache];
		CGImageRef image = CGImageSourceCreateImageAtIndex(isr, 0, (__bridge CFDictionaryRef)options);
		
		haarFeatures[i] = [[HaarFeature alloc] init: image];
	}
	
	// calculate the integral image sums only once
	integralImageSums = [[NSMutableArray alloc] initWithCapacity:data.size];
	for (int i = 0; i < data.size; i++)
		integralImageSums[i] = [self calculateIntegralImageSum: data.input[i]];
	
	return self;
}


// Train a classifier to have error ≤ maxError with the specifgied number of
// subwindows.
- (void) train: (double)maxError
withSubwindows: (int)subwindows {
	USABLE_WIDTH = (int)[data.input[0] count] - HaarFeature.width;
	USABLE_HEIGHT = (int)[data.input[0][0] count] - HaarFeature.height;
	
	// columns / rows = width / height
	// columns * rows ≤ subwindows
	// subwindowsPerRow = columns = √(s * w / h)
	subwindowsPerRow = sqrt(subwindows * USABLE_WIDTH / USABLE_HEIGHT);
	widthBetweenSubwindows = USABLE_WIDTH / subwindowsPerRow;
	
	// columns / rows = width / height
	// columns * rows ≤ subwindows
	// subwindowsPerColumn = rows = √(s * h / w)
	subwindowsPerColumn = sqrt(subwindows * USABLE_HEIGHT / USABLE_WIDTH);
	heightBetweenSubwindows = USABLE_HEIGHT / subwindowsPerColumn;
	
	// calculate the correct classification for each subwindow and count the
	// number of positive and negative examples
	int positives = 0;
	int i = 0;
	for (; i < data.size; i++)
		correctClassifications[i] = [[NSMutableArray alloc] initWithCapacity: subwindowsPerRow];
	for (i = 0; i < data.size; i++)
	for (int x = 0; x < subwindowsPerRow; x++)
		correctClassifications[i][x] = [[NSMutableArray alloc] initWithCapacity:subwindowsPerColumn];
	for (i = 0; i < data.size; i++)
	for (int x = 0; x < subwindowsPerRow; x++)
	for (int y = 0; y < subwindowsPerColumn; y++){
		// calculate the upper-left hand corner of the subwindow
		NSPoint origin;
		origin.x = x * widthBetweenSubwindows;
		origin.y = y * heightBetweenSubwindows;
		
		BOOL classification = [self correctClassificationFor: data.ideal[i]
														  at: origin];
		correctClassifications[i][x][y] = [[NSNumber alloc] initWithBool: classification];
		
		if (classification)
			positives++;
	}
	int negatives = [data size] - positives;
	
	int iterations = 2;
	do {
		[classifier addStage:[self trainStage: positives : negatives : iterations]];
		iterations += 2;
	} while ([self error: subwindows] > maxError);
}


// What is the index of the minimum value in the specified array?
- (int) indexOfMinimum: (NSMutableArray*)errors {
	int minIndex = 0;
	NSNumber* min = errors[0];
	for (int i = 1; i < [errors count]; i++)
		if (errors[i] < min){
			min = errors[i];
			minIndex = i;
		}
	
	return minIndex;
}


// How much error is there for the classifier that is being trained?
- (double) error: (int)subwindows {
	for (int i = 0; i < data.size; i++)
		[classifier classify:integralImageSums[i] : subwindows];
}


// Train the next stage in the cascade classifier.
- (ClassifierStage*)trainStage: (int)positives : (int)negatives : (int)iterations {
	// initialize weights
	NSMutableArray* weights = [[NSMutableArray alloc] initWithCapacity: [data size]];
	int i = 0;
	for (; i < [data size]; i++)
		if ([self isPositiveExample: i])
			weights[i] = [[NSNumber alloc] initWithDouble: 1 / (2 * positives)];
		else
			weights[i] = [[NSNumber alloc] initWithDouble: 1 / (2 * negatives)];
	
	ClassifierStage* stage = [[ClassifierStage alloc] init];
	
	for (int iteration = 0; iteration < iterations; iteration++){
		// normalize weights into a probability distribution
		double total = 0;
		for (i = 0; i < [weights count]; i++)
			total += [weights[i] doubleValue];
		for (i = 0; i < [weights count]; i++)
			weights[i] = [[NSNumber alloc] initWithDouble: [weights[i] doubleValue] / total];
		
		// train a classifier for each candidate feature
		NSMutableArray* haarFeatureErrors = [[NSMutableArray alloc] initWithCapacity: [haarFeatures count]];
		for (i = 0; i < [haarFeatures count]; i++)
			haarFeatureErrors[i] = [[NSNumber alloc] initWithDouble:[self trainFeature: haarFeatures[i] : weights]];
		
		// choose classifier with the least error
		int chosenFeatureIndex = [self indexOfMinimum: haarFeatureErrors];
		HaarFeature* feature = haarFeatures[chosenFeatureIndex];
		[stage addFeature: feature];
		
		// update the weight of each example
		double error = [haarFeatureErrors[chosenFeatureIndex] doubleValue];
		feature.weight = (1 - error) / error;
		for (i = 0; i < data.size; i++)
			if (correctlyClassified[i])
				weights[i] = [[NSNumber alloc] initWithDouble: [weights[i] doubleValue] * error / (1 - error)];
	}
		
	return stage;
}


// Find the optimal parameters for the specified feature given the weight of
// each example in the data set.
- (double) trainFeature: (HaarFeature*)feature : (NSMutableArray*)weights {
	// get the best error using greater than threshold
	// need to figure out if error in terms of threshold is a linear function
	feature.useGreaterThanThreshold = YES;
	double bestGreaterThanThreshold = 0;
	double bestGreaterThanError = 1;
	for (int i = 0; i < 400; i++){
		feature.threshold += STEP_SIZE;
		double error = [self featureError: feature : weights];
		if (error < bestGreaterThanError){
			bestGreaterThanThreshold = error;
			bestGreaterThanError = error;
		}
	}
	
	// get the best error using less than threshold
	feature.useGreaterThanThreshold = NO;
	double bestLessThanThreshold = 1;
	double bestLessThanError = 1;
	for (int i = 0; i < 400; i++){
		feature.threshold += STEP_SIZE;
		double error = [self featureError: feature : weights];
		if (error < bestLessThanError){
			bestLessThanThreshold = feature.threshold;
			bestLessThanError = error;
		}
	}
	
	if (bestLessThanError < bestGreaterThanError){
		feature.threshold = bestLessThanThreshold;
		feature.useGreaterThanThreshold = NO;
		return bestLessThanError;
	}
	feature.threshold = bestGreaterThanThreshold;
	feature.useGreaterThanThreshold = YES;
	return bestGreaterThanError;
}


// How much weighted error does the specified feature have based on the data set?
- (double) featureError: (HaarFeature*)feature : (NSMutableArray*)weights {
	double wrong = 0;
	for (int i = 0; i < data.size; i++)
		for (int y = 0; y < subwindowsPerColumn; y ++)
		for (int x = 0; x < subwindowsPerRow; x++){
			NSPoint origin;
			origin.x = x * widthBetweenSubwindows;
			origin.y = y * heightBetweenSubwindows;
			
			BOOL actual = [feature classify: integralImageSums
										 at: origin];
			BOOL ideal = correctClassifications[i][x][y];
			
			if (actual != ideal)
				wrong += [weights[i][x][y] doubleValue];
		}
	double totalExamples = subwindowsPerColumn * subwindowsPerRow * data.size;
	
	return wrong / totalExamples;
}


// Calculate the sum of all grayscale pixel values to the left and above the
// pixel at (x,y) for all integers x & y such that x < width and y < height.
- (NSMutableArray*) calculateIntegralImageSum: (NSMutableArray*)input {
	NSMutableArray* integralImageSum = [[NSMutableArray alloc] initWithCapacity:[input count]];
	for (int x = 0; x < [input count]; x++)
		integralImageSum[x] = [[NSMutableArray alloc] initWithCapacity: [input[0] count]];
	
	double total = 0;
	for (int x = 0; x < [input count]; x++)
	for (int y = 0; y < [input[0] count]; y++){
		total += [input[x][y] doubleValue];
		integralImageSum[x][y] = [[NSNumber alloc] initWithDouble: total];
	}
	
	return integralImageSum;
}


// Is the correct classification of the specified subwindow that it is included
// in the object?
- (BOOL)correctClassificationFor: (NSMutableArray*)idealOutputs
							  at: (NSPoint)origin {
	int selected = 0;
	int notSelected = 0;
	
	for (int i = origin.x; i < origin.x + HaarFeature.width; i++)
	for (int j = origin.y; j < origin.y + HaarFeature.height; j++)
		if (idealOutputs[i][j] == [[NSNumber alloc] initWithBool: YES])
			selected++;
		else
			notSelected++;
	
	return selected >= notSelected;
}

@end

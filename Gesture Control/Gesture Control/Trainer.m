
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

- (id)init: (DataSet*)dataSet : (NSMutableArray*)integralImages {
	self = [super init];
	
	MIN_TRUE_POS_RATE = .33;
	MAX_TRUE_POS_RATE = .99;
	MIN_FALSE_POS_RATE = .05;
	MAX_FALSE_POS_RATE = .8;
	MIN_DISTANCE_FROM_FIFTY_PERCENT = .05;
	
	classifier = [[CascadeClassifier alloc] init];
	
	data = dataSet;
	integralImageSums = integralImages;
	
	// get all files in the haar features folder that match "*.png"
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* folder = @"/Users/bryanherman/Desktop/Gesture Control/Haar Features/";
	files = [fileManager contentsOfDirectoryAtPath:folder error:nil];
	NSPredicate* filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.png'"];
	files = [files filteredArrayUsingPredicate:filter];
	
	haarFeatures = [[NSMutableArray alloc] initWithCapacity: [files count]];
	
	// initialize the haar features
	for (int i = 0; i < [files count]; i++){
		NSURL* url = [[NSURL alloc] initFileURLWithPath:[folder stringByAppendingString:files[i]]];
		CGImageSourceRef isr = CGImageSourceCreateWithURL( (__bridge CFURLRef)url, NULL);
		
		NSDictionary *options = [NSDictionary dictionaryWithObject: (id)kCFBooleanTrue  forKey: (id) kCGImageSourceShouldCache];
		CGImageRef image = CGImageSourceCreateImageAtIndex(isr, 0, (__bridge CFDictionaryRef)options);
		
		haarFeatures[i] = [[HaarFeature alloc] init: image];
	}
	
	return self;
}


// Train a classifier to have error ≤ maxError with the specified number of
// subwindows.
- (double) train: (double)maxError
	  subwindows: (int)windows
  firstStageSize: (int)firstStageSize
   stageStepSize: (int)stageStepSize {
	subwindows = windows;
	
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
	
	// initialize the correctly classified array
	// do NOT condense the initialization: errors occur when condensed.
	int i = 0;
	correctlyClassified = [[NSMutableArray alloc] initWithCapacity:[haarFeatures count]];
	for (; i < [haarFeatures count]; i++)
		correctlyClassified[i] = [[NSMutableArray alloc] initWithCapacity:data.size];
	for (int featureIndex = 0; featureIndex < [haarFeatures count]; featureIndex++)
	for (i = 0; i < data.size; i++)
		correctlyClassified[featureIndex][i] = [[NSMutableArray alloc] initWithCapacity: subwindowsPerRow];
	for (int featureIndex = 0; featureIndex < [haarFeatures count]; featureIndex++)
	for (i = 0; i < data.size; i++)
	for (int x = 0; x < subwindowsPerRow; x++)
		correctlyClassified[featureIndex][i][x] = [[NSMutableArray alloc] initWithCapacity: subwindowsPerColumn];
	
	// calculate the correct classification for each subwindow
	correctClassifications = [[NSMutableArray alloc] initWithCapacity:data.size];
	NSMutableArray* weights = [[NSMutableArray alloc] initWithCapacity:data.size];
	for (i = 0; i < data.size; i++){
		correctClassifications[i] = [[NSMutableArray alloc] initWithCapacity: subwindowsPerRow];
		weights[i] = [[NSMutableArray alloc] initWithCapacity: subwindowsPerRow];
	}
	for (i = 0; i < data.size; i++)
	for (int x = 0; x < subwindowsPerRow; x++){
		correctClassifications[i][x] = [[NSMutableArray alloc] initWithCapacity:subwindowsPerColumn];
		weights[i][x] = [[NSMutableArray alloc] initWithCapacity: subwindowsPerColumn];
	}
	for (i = 0; i < data.size; i++)
	for (int x = 0; x < subwindowsPerRow; x++)
	for (int y = 0; y < subwindowsPerColumn; y++){
		// calculate the upper-left hand corner of the subwindow
		NSPoint origin;
		origin.x = x * widthBetweenSubwindows;
		origin.y = y * heightBetweenSubwindows;
		
		BOOL classification = [self correctClassificationFor: data.ideal[i]
														  at: origin];
		correctClassifications[i][x][y] = [NSNumber numberWithBool: classification];
		
		for (int j = 0; j < [haarFeatures count]; j++)
			correctlyClassified[j][i][x][y] = [NSNumber numberWithBool: NO];
	}
	
	// count the number of positive and negative examples
	positives = 0;
	negatives = 0;
	for (int i = 0; i < data.size; i++)
		for (int x = 0; x < subwindowsPerRow; x++)
		for (int y = 0; y < subwindowsPerColumn; y++)
			if (correctClassifications[i][x][y] == [NSNumber numberWithBool:YES])
				positives++;
			else
				negatives++;
	
	NSLog(@"Positive: %Lf", positives);
	NSLog(@"Negative: %Lf\n", negatives);
	
	// initialize weights
	for (i = 0; i < data.size; i++)
		for (int x = 0; x < subwindowsPerRow; x++)
		for (int y = 0; y < subwindowsPerColumn; y++){
			if (correctClassifications[i][x][y] == [NSNumber numberWithBool:YES])
				weights[i][x][y] = [[LongDouble alloc] init:1 / (2 * positives)];
			else
				weights[i][x][y] = [[LongDouble alloc] init:1 / (2 * negatives)];
		}
	
	// train the stages of the classifier
	firstStage = YES;
	int iterations = firstStageSize;
	int numberOfStagesWithoutChange = 0;
	long double error = 1;
	long double previousError = 1;
	i = 1;
	do {
		previousError = error;
		
		NSLog(@"\n\nTraining stage %d (using %d features)", i, iterations);
		ClassifierStage* stage = [[ClassifierStage alloc] init];
		// [0] = true positive rate
		// [1] = weights
		NSMutableArray* returnValue = [self trainStage:stage
										   withWeights:weights
										 forIterations:iterations];
		// keep adding features until the desired true positive rate is achieved
		while ([returnValue[0] doubleValue] < .95){
			returnValue = [self trainStage:stage
							   withWeights:returnValue[1]
							 forIterations:1];
		}
		[classifier addStage:stage];
		
		error = [self error];
		NSLog(@"Classifier Error: %Lf", error);
		
		if (previousError <= error || previousError - error < .001){
			// remove superfluous stage
			[classifier removeLastStage];
			
			numberOfStagesWithoutChange++;
//			iterations += stageStepSize;
		} else {
			NSMutableArray* trueNegatives = [self classifierTrueNegatives];
			
			// remove the weight of each correctly identified negative subwindow
			for (int i = 0; i < data.size; i++)
			for (int x = 0; x < subwindowsPerRow; x++)
			for (int y = 0; y < subwindowsPerColumn; y++)
				if (trueNegatives[i][x][y] == [NSNumber numberWithBool:YES])
					weights[i][x][y] = [[LongDouble alloc] init:0];
			
//			iterations += stageStepSize;
			numberOfStagesWithoutChange = 0;
			i++;
		}
		firstStage = NO;
	} while (error > maxError && numberOfStagesWithoutChange < 9);
	
	return error;
}


// Train the next stage in the cascade classifier.
- (NSMutableArray*)trainStage:(ClassifierStage*)stage
				   withWeights:(NSMutableArray*)weight
				 forIterations:(int)iterations {
	int i;
	
	// clone the weights so that the weights reset to their initial values at
	// the beginning of each stage
	NSMutableArray* weights = [[NSMutableArray alloc] initWithCapacity:data.size];
	for (i = 0; i < data.size; i++)
		weights[i] = [[NSMutableArray alloc] initWithCapacity:subwindowsPerRow];
	for (i = 0; i < data.size; i++)
	for (int x = 0; x < subwindowsPerRow; x++)
		weights[i][x] = [[NSMutableArray alloc] initWithCapacity:subwindowsPerColumn];
	for (i = 0; i < data.size; i++)
		for (int x = 0; x < subwindowsPerRow; x++)
		for (int y = 0; y < subwindowsPerColumn; y++)
			weights[i][x][y] = [weight[i][x][y] clone];
	
//	const double INITIAL_FEATURE_THRESHOLD_MAX = 35;
	for (int iteration = 0; iteration < iterations; iteration++){
		NSLog(@"Choosing feature %d ...", iteration + 1);
		
		// normalize weights
		long double total = 0;
		for (i = 0; i < data.size; i++)
			for (int x = 0; x < subwindowsPerRow; x++)
			for (int y = 0; y < subwindowsPerColumn; y++)
				total += [weights[i][x][y] longDoubleValue];
		for (i = 0; i < data.size; i++)
			for (int x = 0; x < subwindowsPerRow; x++)
			for (int y = 0; y < subwindowsPerColumn; y++)
				weights[i][x][y] = [[LongDouble alloc] init:[weights[i][x][y] longDoubleValue] / total];
		
		
		int bestIndex = -1;
		long double bestTruePositiveRate = -1;
		long double error = 999;
		long double bestRatio = -1;
		if (firstStage){
			NSMutableArray* results;
			switch (iteration){
				case 0:
					for (i = 0; i < [files count]; i++)
						if ([files[i] isEqual: @"70.png"])
							break;
					((HaarFeature*)haarFeatures[i]).threshold = 47.237430;
					((HaarFeature*)haarFeatures[i]).useGreaterThanThreshold = YES;
					results = [self featureTruePositiveRate: haarFeatures[i] : weights : i];
					bestIndex = i;
					bestTruePositiveRate = [results[0] longDoubleValue];
					bestRatio = [results[0] longDoubleValue] / [results[1] longDoubleValue];
					error = [results[1] longDoubleValue];
					break;
				case 1:
					for (i = 0; i < [files count]; i++)
						if ([files[i] isEqual: @"22.png"])
							break;
					((HaarFeature*)haarFeatures[i]).threshold = 12.488651;
					((HaarFeature*)haarFeatures[i]).useGreaterThanThreshold = YES;
					results = [self featureTruePositiveRate: haarFeatures[i] : weights : i];
					bestIndex = i;
					bestTruePositiveRate = [results[0] longDoubleValue];
					bestRatio = [results[0] longDoubleValue] / [results[1] longDoubleValue];
					error = [results[1] longDoubleValue];
					break;
				case 2:
					for (i = 0; i < [files count]; i++)
						if ([files[i] isEqual: @"19.png"])
							break;
					((HaarFeature*)haarFeatures[i]).threshold = 18.303334;
					((HaarFeature*)haarFeatures[i]).useGreaterThanThreshold = YES;
					results = [self featureTruePositiveRate: haarFeatures[i] : weights : i];
					bestIndex = i;
					bestTruePositiveRate = [results[0] longDoubleValue];
					bestRatio = [results[0] longDoubleValue] / [results[1] longDoubleValue];
					error = [results[1] longDoubleValue];
					break;
				case 3:
					for (i = 0; i < [files count]; i++)
						if ([files[i] isEqual: @"96.png"])
							break;
					((HaarFeature*)haarFeatures[i]).threshold = 7.978357;
					((HaarFeature*)haarFeatures[i]).useGreaterThanThreshold = YES;
					results = [self featureTruePositiveRate: haarFeatures[i] : weights : i];
					bestIndex = i;
					bestTruePositiveRate = [results[0] longDoubleValue];
					bestRatio = [results[0] longDoubleValue] / [results[1] longDoubleValue];
					error = [results[1] longDoubleValue];
					break;
				case 4:
					for (i = 0; i < [files count]; i++)
						if ([files[i] isEqual: @"14.png"])
							break;
					((HaarFeature*)haarFeatures[i]).threshold = 24.652892;
					((HaarFeature*)haarFeatures[i]).useGreaterThanThreshold = YES;
					results = [self featureTruePositiveRate: haarFeatures[i] : weights : i];
					bestIndex = i;
					bestTruePositiveRate = [results[0] longDoubleValue];
					bestRatio = [results[0] longDoubleValue] / [results[1] longDoubleValue];
					error = [results[1] longDoubleValue];
					break;
				case 5:
					for (i = 0; i < [files count]; i++)
						if ([files[i] isEqual: @"5.png"])
							break;
					((HaarFeature*)haarFeatures[i]).threshold = 22.497573;
					((HaarFeature*)haarFeatures[i]).useGreaterThanThreshold = YES;
					results = [self featureTruePositiveRate: haarFeatures[i] : weights : i];
					bestIndex = i;
					bestTruePositiveRate = [results[0] longDoubleValue];
					bestRatio = [results[0] longDoubleValue] / [results[1] longDoubleValue];
					error = [results[1] longDoubleValue];
					break;
			}
		} else {
			// check out each candidate feature
			for (i = 0; i < [haarFeatures count]; i++){
				((HaarFeature*)haarFeatures[i]).useGreaterThanThreshold = YES;
				((HaarFeature*)haarFeatures[i]).threshold = (double)arc4random() / RAND_MAX * 25;//(INITIAL_FEATURE_THRESHOLD_MAX + .5 * iteration * INITIAL_FEATURE_THRESHOLD_MAX);
				NSMutableArray* results1 = [self featureTruePositiveRate: haarFeatures[i] : weights : i];
				NSMutableArray* correctlyClassified1 = [[NSMutableArray alloc] initWithCapacity:data.size];
				for (int j = 0; j < data.size; j++)
					correctlyClassified1[j] = [[NSMutableArray alloc] initWithCapacity:subwindowsPerRow];
				for (int j = 0; j < data.size; j++)
					for (int x = 0; x < subwindowsPerRow; x++)
						correctlyClassified1[j][x] = [[NSMutableArray alloc] initWithCapacity:subwindowsPerColumn];
				for (int j = 0; j < data.size; j++)
					for (int x = 0; x < subwindowsPerRow; x++)
					for (int y = 0; y < subwindowsPerColumn; y++)
						correctlyClassified1[j][x][y] = [NSNumber numberWithBool:correctlyClassified[i][j][x][y] == [NSNumber numberWithBool:YES]];
				
				((HaarFeature*)haarFeatures[i]).useGreaterThanThreshold = NO;
				NSMutableArray* results2 = [self featureTruePositiveRate: haarFeatures[i] : weights : i];
				
				BOOL results1Check = [self checkResults: results1];
				BOOL results2Check = [self checkResults: results2];
				
				if (results1Check && ( !results2Check || ( results2Check && [results1[0] longDoubleValue] / [results1[1] longDoubleValue] > [results2[0] longDoubleValue] / [results2[1] longDoubleValue] ) )){
					results2 = results1;
					correctlyClassified[i] = correctlyClassified1;
					((HaarFeature*)haarFeatures[i]).useGreaterThanThreshold = YES;
				}
				results2Check = [self checkResults: results2];
				if (results2Check && [results2[0] longDoubleValue] / [results2[1] longDoubleValue] > bestRatio){
					bestIndex = i;
					bestTruePositiveRate = [results2[0] longDoubleValue];
					bestRatio = [results2[0] longDoubleValue] / [results2[1] longDoubleValue];
					error = [results2[1] longDoubleValue];
				}
				
				// report the best parameters for the current feature
//				NSString* file = [[NSString alloc] initWithFormat:@"%d [", i];
//				file = [[file stringByAppendingString: files[i]] stringByAppendingString:@"] "];
//				NSString* comparisonString;
//				if (((HaarFeature*)haarFeatures[i]).useGreaterThanThreshold)
//					comparisonString = [file stringByAppendingString: @"> "];
//				else comparisonString = [file stringByAppendingString: @"< "];
//				NSString* thresholdString = [[NSString alloc] initWithFormat:@"%f: %Lf  ,  %Lf", ((HaarFeature*)haarFeatures[i]).threshold, [results2[0] longDoubleValue], [results2[1] longDoubleValue]];
//				NSLog([comparisonString stringByAppendingString:thresholdString]);
			}
			
			if (bestIndex == -1){
				iteration--;
				continue;
			}
		}
		HaarFeature* feature = haarFeatures[bestIndex];
		feature.weight = fabsl(log((1 - error) / error));
		[stage addFeature: feature];
		
		NSString* file = @"[";
		file = [[file stringByAppendingString: files[bestIndex]] stringByAppendingString:@"] "];
		NSString* comparisonString;
		if (feature.useGreaterThanThreshold)
			comparisonString = [file stringByAppendingString: @"> "];
		else comparisonString = [file stringByAppendingString: @"< "];
		NSString* thresholdString = [[NSString alloc] initWithFormat:@"%f: %Lf, %Lf", feature.threshold, bestTruePositiveRate, error];
		NSLog([comparisonString stringByAppendingString:thresholdString]);
		
		// update the weight of each example
		for (i = 0; i < data.size; i++)
			for (int x = 0; x < subwindowsPerRow; x++)
			for (int y = 0; y < subwindowsPerColumn; y++)
				if (correctlyClassified[bestIndex][i][x][y] == [NSNumber numberWithBool:YES]){
					double factor = error / (fabsl(1 - error));
					if (factor > 1)
						factor = fabsl(1 - error)/error;
					weights[i][x][y] = [[LongDouble alloc] init:[weights[i][x][y] longDoubleValue] * factor];
				}
	}
	
	// adjust the stage's threshold to allow full positive detection
	const double THRESHOLD_DELTA = 1;
	double learningRate = 20;
	double previousThreshold = stage.threshold;
	double truePositiveRate = [self truePositiveRate: stage];
	// find a point with almost full true positive detection
	while (truePositiveRate < .95){
		previousThreshold = stage.threshold;
		
		// slope
		stage.threshold -= THRESHOLD_DELTA;
		double rate = [self truePositiveRate: stage];
		double slope = (truePositiveRate - rate) / THRESHOLD_DELTA;
		
		// reset to initial value
		stage.threshold += THRESHOLD_DELTA;
		
		if (slope == 0)
			stage.threshold /= 2;
		else
			stage.threshold += learningRate * slope;
		
		if (stage.threshold < 0)
			stage.threshold = 0;
		
		truePositiveRate = [self truePositiveRate: stage];
		
		NSLog(@"Stage True Positive Rate: ≥ %Lf = %f", stage.threshold, truePositiveRate);
	}
	
//	double previousTruePositiveRate = 1;
//	while (previousTruePositiveRate == truePositiveRate){
//		previousTruePositiveRate = truePositiveRate;
//		
//		stage.threshold += .005;
//		truePositiveRate = [self truePositiveRate: stage];
//	}
//	NSLog(@"Stage True Positive Rate: ≥ %Lf = %f", stage.threshold, truePositiveRate);
	// use binary search to find the point at which the stage starts to have
	// full true positive detection. this point will have the least false
	// positive rate
	if (previousThreshold == stage.threshold){
		// this part avoids infinite loops during the binary search
		double originalThreshold = stage.threshold;
		while (truePositiveRate > .95){
			stage.threshold *= 1.5;
			truePositiveRate = [self truePositiveRate:stage];
		}
		previousThreshold = stage.threshold;
		stage.threshold = originalThreshold;
	}
	long double low = stage.threshold;
	long double high = previousThreshold;
	if (previousThreshold < stage.threshold){
		low = previousThreshold;
		high = stage.threshold;
	}
	double previousTruePositiveRate;
	while (truePositiveRate > .97 || truePositiveRate < .9){
		double middle = (high + low) / 2;
		previousTruePositiveRate = truePositiveRate;
		previousThreshold = stage.threshold;
		stage.threshold = middle;
		truePositiveRate = [self truePositiveRate: stage];
		
		NSLog(@"Stage True Positive Rate: ≥ %Lf = %f", stage.threshold, truePositiveRate);
		
		if (previousTruePositiveRate == truePositiveRate)
			break;
		
		if (truePositiveRate == 1)
			low = middle;
		else
			high = middle;
	}
	
	NSMutableArray* returnValue = [[NSMutableArray alloc] initWithCapacity:2];
	returnValue[0] = [NSNumber numberWithDouble:truePositiveRate];
	returnValue[1] = weights;
	
	return returnValue;
}


// Find the optimal parameters for the specified feature given the weight of
// each example in the data set.
- (NSMutableArray*) trainFeature: (HaarFeature*)feature : (NSMutableArray*)weights : (int)featureIndex {
	// for some reason, 1 is the smallest threshold delta that produces a change
	const double THRESHOLD_DELTA = 1;
//	const double CORRECTION_FACTOR = .75;
	
	NSMutableArray* results;
	
//	// get the best error using greater than threshold
//	feature.useGreaterThanThreshold = YES;
//	double errors[2][(int)(1 / STEP_SIZE + 1)];
//	double thresholds[2][(int)(1 / STEP_SIZE + 1)];
	double learningRate = 25;
//	for (double i = 0; i <= 1; i += STEP_SIZE){
//		// set the starting threshold
//		feature.threshold = i * HaarFeature.height * HaarFeature.width;
//		
//		double bestThreshold = feature.threshold;
//		double bestValue = 999999;
//		learningRate = 100;
//		double previousValue = 1;
//		
//		// use hill-climbing to find local minimum
//		while (YES){
//			// preceding slope
			results = [self featureTruePositiveRate: feature : weights : featureIndex];
			long double value2 = [results[0] longDoubleValue] / [results[1] longDoubleValue];
			feature.threshold -= THRESHOLD_DELTA;
			results = [self featureTruePositiveRate: feature : weights : featureIndex];
			long double value = [results[0] longDoubleValue] / [results[1] longDoubleValue];
			long double precedingSlope = (value2 - value) / THRESHOLD_DELTA;
			
			feature.threshold += 2 * THRESHOLD_DELTA;
			
			// succeeding slope
			results = [self featureTruePositiveRate: feature : weights : featureIndex];
			value = [results[0] longDoubleValue] / [results[1] longDoubleValue];
			long double succeedingSlope = (value - value2) / THRESHOLD_DELTA;
			
			feature.threshold -= THRESHOLD_DELTA;
			
//			if ([self isLocalMaximum: precedingSlope : succeedingSlope])//{
//				bestValue = value2;
//				bestThreshold = feature.threshold;
//				break;
//			}
//			
//			// if the last correction made things worse, then overshot the maximum
//			if (previousValue > value2)
//				learningRate *= CORRECTION_FACTOR;
			
			double slope = (succeedingSlope + precedingSlope) / 2;
			feature.threshold += learningRate * slope;
			if (feature.threshold < 0)
				feature.threshold = 0;
			if (feature.threshold > HaarFeature.height * HaarFeature.width)
				feature.threshold = HaarFeature.height * HaarFeature.width;
			
//			previousValue = value2;
//			
//			NSString* thresholdString = [[NSString alloc] initWithFormat:@"> %f: ", feature.threshold];
//			NSString* errorString = [[NSString alloc] initWithFormat:@"%Lf", value2];
//			NSLog([thresholdString stringByAppendingString:errorString]);
//			NSLog(@"%Lf\t,\t%Lf", [results[0] longDoubleValue], [results[1] longDoubleValue]);
//		}
	return results;	
	
		// store the local minimum for the ith starting point
//		errors[0][(int)(i / STEP_SIZE)] = bestValue;
//		thresholds[0][(int)(i / STEP_SIZE)] = bestThreshold;
//	}
	
	// get the best error using less than threshold
//	feature.useGreaterThanThreshold = NO;
//	for (double i = 0; i <= 1; i += STEP_SIZE){
//		// set the starting threshold
//		feature.threshold = i * HaarFeature.height * HaarFeature.width;
//		
//		double bestThreshold = feature.threshold;
//		double bestError = 9999999;
//		learningRate = 100;
//		double previousError = 1;
//		
//		// use hill-climbing to find local minimum
//		while (true){
//			// preceding slope
//			long double error2 = [self featureError: feature : weights : featureIndex];
//			feature.threshold -= THRESHOLD_DELTA;
//			long double error = [self featureError: feature : weights : featureIndex];
//			double precedingSlope = (error2 - error);
//			
//			feature.threshold += THRESHOLD_DELTA;
//			
//			// succeeding slope
//			error = [self featureError: feature : weights : featureIndex];
//			feature.threshold += THRESHOLD_DELTA;
//			error2 = [self featureError: feature : weights : featureIndex];
//			double succeedingSlope = (error2 - error);
//			
//			feature.threshold -= THRESHOLD_DELTA;
//			
//			if ([self isLocalMinimum: precedingSlope : succeedingSlope]){
//				bestError = error;
//				bestThreshold = feature.threshold;
//				break;
//			}	
//			
//			// if the last correction made things worse, then overshot the minimum
//			if (previousError < error)
//				learningRate *= CORRECTION_FACTOR;
//			
//			feature.threshold -= learningRate * succeedingSlope;
//			if (feature.threshold < 0)
//				feature.threshold = 0;
//			if (feature.threshold > HaarFeature.height * HaarFeature.width)
//				feature.threshold = HaarFeature.height * HaarFeature.width;
//			
//			previousError = error;
//			
//			NSString* thresholdString = [[NSString alloc] initWithFormat:@"< %f: ", feature.threshold];
//			NSString* errorString = [[NSString alloc] initWithFormat:@"%Lf", error];
//			NSLog([thresholdString stringByAppendingString:errorString]);
//		}
//		
//		// store the local minimum for the ith starting point
//		errors[1][(int)(i / STEP_SIZE)] = bestError;
//		thresholds[1][(int)(i / STEP_SIZE)] = bestThreshold;
//	}
//	
//	double bestError = errors[0][0];
//	double bestThreshold = thresholds[0][0];
//	BOOL greaterThan = YES;
//	for (int i = 0; i < 2; i++)
//	for (int j = 0; j < sizeof(errors) / sizeof(double); j++)
//		if (errors[i][j] < bestError){
//			bestError = errors[i][j];
//			bestThreshold = thresholds[i][j];
//			if (i == 0)
//				greaterThan = YES;
//			else
//				greaterThan = NO;
//		}
//	feature.threshold = bestThreshold;
//	feature.useGreaterThanThreshold = greaterThan;
//	
//	return bestError;
}


// Do the specified slopes match the context of a local maximum within the
// acceptable tolerance level?
- (BOOL)isLocalMaximum: (double)precedingSlope : (double)succeedingSlope {
	// in order to be a maximum, the preceding slope should be positive and the
	// succeeding negative
	if (precedingSlope > 0 && succeedingSlope < 0)
		return YES;
	if (precedingSlope == 0)
		return YES;
	if (succeedingSlope == 0)
		return YES;
	return NO;
}


// Calculate the weighted error for the specified feature and its true positive
// rate.
- (NSMutableArray*)featureTruePositiveRate: (HaarFeature*)feature : (NSMutableArray*)weights : (int)featureIndex {
	NSMutableArray* results = [[NSMutableArray alloc] initWithCapacity:2];
	long double truePositives = 0;
	long double totalNegativeWeight = 0;
	long double falsePositiveWeight = 0;
//	long double error = 0;
//	long double totalWeight = 0;
	for (int i = 0; i < data.size; i++)
		for (int y = 0; y < subwindowsPerColumn; y++)
		for (int x = 0; x < subwindowsPerRow; x++){
			NSPoint origin;
			origin.x = x * widthBetweenSubwindows;
			origin.y = y * heightBetweenSubwindows;
			
			BOOL actual = [feature classify: integralImageSums[i]
										 at: origin];
			BOOL ideal = correctClassifications[i][x][y] == [NSNumber numberWithBool:YES];
			
			if (actual != ideal){
				correctlyClassified[featureIndex][i][x][y] = [NSNumber numberWithBool:NO];
//				error += [weights[i][x][y] longDoubleValue];
			} else
				correctlyClassified[featureIndex][i][x][y] = [NSNumber numberWithBool:YES];
			if (actual && ideal)
				truePositives++;
			if (actual && !ideal)
				falsePositiveWeight += [weights[i][x][y] longDoubleValue];
			if (!ideal)
				totalNegativeWeight += [weights[i][x][y] longDoubleValue];
//			totalWeight += [weights[i][x][y] longDoubleValue];
		}
	
	results[0] = [[LongDouble alloc] init:truePositives / positives];
	results[1] = [[LongDouble alloc] init:falsePositiveWeight / totalNegativeWeight];
	
	return results;
}


// What is the index of the minimum value in the specified array? This excludes
// all values that are close to .5 b/c the weight of a feature (abs(log((1-error)/error)))
// is too close to zero around .5 error. Error close to .5 also causes the weights
// not to update b/c the update is based on error/(1-error), which is close to 1
- (int) indexOfMinimum: (NSMutableArray*)errors {
	int minIndex = 0;
	long double min = [errors[0] longDoubleValue];
	for (int i = 1; i < [errors count]; i++)
		if ([errors[i] longDoubleValue] < min)
		if (fabsl([errors[i] longDoubleValue] - .5) >= MIN_DISTANCE_FROM_FIFTY_PERCENT){
			min = [errors[i] longDoubleValue];
			minIndex = i;
		}
	
	return minIndex;
}

// How much error is there for the classifier that is being trained?
- (double) error {
	double wrong = 0;
	double total = 0;
	for (int i = 0; i < data.size; i++){
		NSMutableArray* classifications = [classifier classify: integralImageSums[i] : subwindows];
		for (int x = 0; x < [classifications count]; x++)
		for (int y = 0; y < [classifications[0] count]; y++)
			if (correctClassifications[i][x][y] != classifications[x][y])
				wrong++;
		total += [classifications count] * [classifications[0] count];
	}
	
	return wrong / total;
}


// Get the true positive rate.
- (double)truePositiveRate: (ClassifierStage*)stage {
	double truePositives = 0;
	for (int i = 0; i < data.size; i++)
		for (int x = 0; x < subwindowsPerRow; x++)
		for (int y = 0; y < subwindowsPerColumn; y++){
			NSPoint origin;
			origin.x = x * widthBetweenSubwindows;
			origin.y = y * heightBetweenSubwindows;
			
			BOOL prediction = [stage classify: integralImageSums[i]
										   at: origin];
			
			if (correctClassifications[i][x][y] == [NSNumber numberWithBool:YES])
			if (prediction == YES)
				truePositives++;
		}
	
	return truePositives / positives;
}


// Get the false positive rate.
- (double)falsePositiveRate: (ClassifierStage*)stage {
	double falsePositives = 0;
	for (int i = 0; i < data.size; i++)
		for (int x = 0; x < subwindowsPerRow; x++)
		for (int y = 0; y < subwindowsPerColumn; y++){
			NSPoint origin;
			origin.x = x * widthBetweenSubwindows;
			origin.y = y * heightBetweenSubwindows;
			
			BOOL prediction = [stage classify: integralImageSums[i]
										   at: origin];
			
			if (prediction == YES)
			if (correctClassifications[i][x][y] == [NSNumber numberWithBool:NO])
				falsePositives++;
		}
	
	return falsePositives / negatives;
}


// True positive rate for the classifier
- (double)calculateClassifierTruePositiveRate {
	double truePositives = 0;
	for (int i = 0; i < data.size; i++){
		NSMutableArray* results = [classifier classify: integralImageSums[i] : subwindows];
		
		for (int x = 0; x < subwindowsPerRow; x++)
		for (int y = 0; y < subwindowsPerColumn; y++){
			BOOL prediction = results[x][y] == [NSNumber numberWithBool:YES];
			
			if (correctClassifications[i][x][y] == [NSNumber numberWithBool:YES] && prediction)
				truePositives++;
		}
	}
	
	return truePositives / positives;
}


// Is the correct classification of the specified subwindow that it is included
// in the object?
- (BOOL)correctClassificationFor: (NSMutableArray*)idealOutputs
							  at: (NSPoint)origin {
	int selected = 0;
	int notSelected = 0;
	for (int i = origin.x; i < origin.x + HaarFeature.width; i++)
	for (int j = origin.y; j < origin.y + HaarFeature.height; j++)
		if (idealOutputs[i][j] == [NSNumber numberWithBool: YES])
			selected++;
		else
			notSelected++;
	
	return selected >= notSelected;
}



- (BOOL)checkResults: (NSMutableArray*)results {
	return [results[0] longDoubleValue] >= MIN_TRUE_POS_RATE && [results[0] longDoubleValue] <= MAX_TRUE_POS_RATE && [results[1] longDoubleValue] >= MIN_FALSE_POS_RATE && fabsl([results[1] longDoubleValue] - .5) >= MIN_DISTANCE_FROM_FIFTY_PERCENT && [results[1] longDoubleValue] <= MAX_FALSE_POS_RATE;
}


// Identify the subwindows correctly classified as negative by the current
// classifier.
- (NSMutableArray*)classifierTrueNegatives {
	NSMutableArray* trueNegatives = [[NSMutableArray alloc] initWithCapacity:data.size];
	for (int i = 0; i < data.size; i++)
		trueNegatives[i] = [[NSMutableArray alloc] initWithCapacity:subwindowsPerRow];
	for (int i = 0; i < data.size; i++)
	for (int x = 0; x < subwindowsPerRow; x++)
		trueNegatives[i][x] = [[NSMutableArray alloc] initWithCapacity:subwindowsPerColumn];
	
	// locate true negatives
	for (int i = 0; i < data.size; i++){
		NSMutableArray* results = [classifier classify: integralImageSums[i] : subwindows];
		
		for (int x = 0; x < subwindowsPerRow; x++)
		for (int y = 0; y < subwindowsPerColumn; y++){
			BOOL prediction = results[x][y] == [NSNumber numberWithBool:YES];
			
			if (correctClassifications[i][x][y] == [NSNumber numberWithBool:NO] && !prediction)
				trueNegatives[i][x][y] = [NSNumber numberWithBool:YES];
			else
				trueNegatives[i][x][y] = [NSNumber numberWithBool:NO];
		}
	}
	
	return trueNegatives;
}

@end

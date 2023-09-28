//
//  FeedforwardLayer.m
//  Gesture Control
//
//  Created by Bryan Herman on 9/26/12.
//  Copyright (c) 2012 Bryan Herman. All rights reserved.
//

#ifndef FEEDFORWARD_LAYER
#define FEEDFORWARD_LAYER

#import "FeedforwardLayer.h"

@implementation FeedforwardLayer

// create getters and setters
@synthesize matrix;
@synthesize fire;
@synthesize next;
@synthesize previous;
@synthesize activationFunction;

// Construct this layer.
- (id) init : (int)neuronCount : (id<ActivationFunction>)activation{
	self = [super init];
	
	fire = [[NSMutableArray alloc] initWithCapacity: neuronCount];
	activationFunction = activation;
	
	return self;
}


// Unarchiver
- (id) initWithCoder: (NSCoder*)decoder {
	
}


// Archiver
- (void) encodeWithCoder: (NSCoder*)encoder {
	
}


// Compute the outputs for this layer, which are stored in fire.
- (NSMutableArray*) computeOutputs : (NSMutableArray*) pattern {
	int i;
	
	if (pattern != nil)
		for (i = 0; i < [self neuronCount]; i++)
			fire[i] = pattern[i];
	
	Matrix* inputMatrix = [self createInputMatrix: fire];
	
	for (i = 0; i < [next neuronCount]; i++){
		Matrix* column = [matrix column: i];
		double sum = [column dotProduct: inputMatrix];
		
		next.fire[i] = [[NSNumber alloc] initWithDouble: [activationFunction activation: sum]];
	}
	
	return fire;
}


// Turn the input array into a usable matrix, accounting for the threshold.
- (Matrix*) createInputMatrix : (NSMutableArray*) input {
	Matrix* result = [[Matrix alloc] init: 1 : [input count] + 1];
	for (int i = 0; i < [input count]; i++)
		[result set: 0 : i
				 to: [input[i] doubleValue]];
	
	// add a column of 1 first so that the threshold will just be added
	[result set: 0 : [input count]
			 to: 1];
	
	return result;
}


// How big is the matrix that is being used for this layer?
- (int) matrixSize {
	if (matrix == nil)
		return 0;
	else
		return [matrix size];
}


// How many neurons are in this layer?
- (int) neuronCount {
	return [fire count];
}


// Is this layer hidden?
- (BOOL) isHidden {
	return ((next != nil) && (previous != nil));
}


// Is this an input layer?
- (BOOL) isInput {
	return (previous == nil);
}


// Is this an output layer?
- (BOOL) isOutput {
	return (next == nil);
}


// Randomize the weight matrix and threshold values for this layer.
- (void) randomize {
	if (matrix != nil)
		[matrix randomize: -1 : 1];
}

@end

#endif

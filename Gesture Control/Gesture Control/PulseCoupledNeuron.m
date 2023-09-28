//
//  PulseCoupledNeuron.m
//  Gesture Control
//
//  Created by Bryan Herman on 1/29/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#ifndef PC_NEURON
#define PC_NEURON

#import "PulseCoupledNeuron.h"

@implementation PulseCoupledNeuron

@synthesize leakyIntegratorInput;
@synthesize leakyIntegratorPreviousInput;
@synthesize previousLeakyIntegratorOutput;
@synthesize feedingInput;
@synthesize threshold;
@synthesize decayConstant;
@synthesize linkingStrength;
@synthesize thresholdModulator;

// constructor
- (id) init: (double)decay : (double)thresholdMod {
	self = [super init];
	
	const int NEIGHBORS = 8;
	
	leakyIntegratorInput = [[NSMutableArray alloc] initWithCapacity: NEIGHBORS];
	leakyIntegratorPreviousInput = [[NSMutableArray alloc] initWithCapacity: NEIGHBORS];
	
	for (int i = 0; i < NEIGHBORS; i++)
		leakyIntegratorPreviousInput[i] = [[NSNumber alloc] initWithDouble: 0];
	
	decayConstant = decay;
	thresholdModulator = thresholdMod;
	
	return self;
}


// process the given input
- (double) process {
	// use linking leaky integrator to combine the input from neighboring neurons
	double leakyIntegratorTotal = 0;
	for (int i = 0; i < [leakyIntegratorInput count]; i++){
		double value = previousLeakyIntegratorOutput * exp(-decayConstant);
		value += [leakyIntegratorInput[i] doubleValue] * [leakyIntegratorPreviousInput[i] doubleValue];
		leakyIntegratorTotal += value;
	}
	previousLeakyIntegratorOutput = leakyIntegratorTotal;
	
	// combine feeding input with linking leaky integrator result
	double internalActivity = feedingInput * (1 + linkingStrength * leakyIntegratorTotal);
	
	// if firing threshold is surpassed, neuron is activated
	double output = 0;
	if (internalActivity > threshold)
		output = 1;
	
	// change threshold
	threshold = threshold * exp(-decayConstant) + thresholdModulator * output;
	
	return output;
}

@end

#endif

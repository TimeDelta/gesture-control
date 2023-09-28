//
//  SigmoidActivation.m
//  Gesture Control
//
//  Created by Bryan Herman on 12/17/12.
//  Copyright (c) 2012 Bryan Herman. All rights reserved.
//

#ifndef SIGMOID_ACTIVATION
#define SIGMOID_ACTIVATION

#import "SigmoidActivation.h"

@implementation SigmoidActivation

- (double) activation: (double)input {
	return 1.0 / (1 + exp(-1.0 * input));
}


- (double) derivative: (double)input {
	return input * (1.0 - input);
}


// Unarchiver
- (id) initWithCoder: (NSCoder*)decoder {
	return self;
}


// Archiver
- (void) encodeWithCoder: (NSCoder*)encoder {
}

@end

#endif

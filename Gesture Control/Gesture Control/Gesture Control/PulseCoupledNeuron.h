//
//  PulseCoupledNeuron.h
//  Gesture Control
//
//  Created by Bryan Herman on 1/29/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PulseCoupledNeuron : NSObject

@property (readwrite) NSMutableArray* leakyIntegratorInput;
@property (readonly) NSMutableArray* leakyIntegratorPreviousInput;
@property (readonly) double previousLeakyIntegratorOutput;
@property (readwrite) double feedingInput;
@property (readwrite) double threshold;
@property (readwrite) double linkingStrength;
@property (readonly) double decayConstant;
@property (readonly) double thresholdModulator;

- (id) init: (double)decay : (double)thresholdMod;
- (double) process;

@end

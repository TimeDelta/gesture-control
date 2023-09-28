//
//  FeedforwardLayer.h
//  Gesture Control
//
//  Created by Bryan Herman on 9/26/12.
//  Copyright (c) 2012 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Matrix.h"
#import "ActivationFunction.h"

@interface FeedforwardLayer : NSObject<NSCoding>

@property (readwrite) Matrix* matrix;
@property (readwrite) NSMutableArray* fire;
@property (readwrite) FeedforwardLayer* next;
@property (readwrite) FeedforwardLayer* previous;
@property (readonly)  id<ActivationFunction> activationFunction;

- (id) init : (int)neuronCount;
- (NSArray*) computeOutputs : (NSArray*)pattern;
- (Matrix*) createInputMatrix : (NSArray*)input;
- (int) matrixSize;
- (int) neuronCount;
- (BOOL) isHidden;
- (BOOL) isInput;
- (BOOL) isOutput;
- (void) prune: (int)neuron;
- (void) randomize;

@end

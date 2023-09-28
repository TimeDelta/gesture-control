////
////  BackpropagationLayer.h
////  Gesture Control
////
////  Created by Bryan Herman on 12/7/12.
////  Copyright (c) 2012 Bryan Herman. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import "Matrix.h"
//#import "Backpropagation.h"
//#import "FeedforwardLayer.h"
//
//@interface BackpropagationLayer : NSObject {
//	NSMutableArray* error;
//	NSMutableArray* errorDelta;
//	Matrix* accumulativeMatrixDelta;
//	Matrix* matrixDelta;
//	Backpropagation* backpropagation;
//	FeedforwardLayer* layer;
//}
//
//@property (readwrite) NSMutableArray* error;
//@property (readwrite) NSMutableArray* errorDelta;
//@property Matrix* accumulativeMatrixDelta;
//@property int biasRow;
//@property Matrix* matrixDelta;
//@property (weak) Backpropagation* backpropagation;
//@property FeedforwardLayer* layer;
//
//- (void) accumulateMatrixDelta: (int) i1 : (int) i2 : (double) value;
//- (void) accumulateThresholdDelta: (int) index : (double) value;
//- (void) calcError;
//- (void) calcError: (NSMutableArray*) ideal;
//- (double) calculateDelta: (int) index;
//- (void) clear;
//- (void) learn: (double) learnRate : (double) momentum;
//
//@end

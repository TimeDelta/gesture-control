////
////  BackpropagationLayer.m
////  Gesture Control
////
////  Created by Bryan Herman on 12/7/12.
////  Copyright (c) 2012 Bryan Herman. All rights reserved.
////
//
//#ifndef BACKPROPAGATION_LAYER
//#define BACKPROPAGATION_LAYER
//
//#import "BackpropagationLayer.h"
//
//@implementation BackpropagationLayer
//
//@synthesize error;
//@synthesize errorDelta;
//
//// Construct the backpropagation layer corresponding to a feedforward layer.
//- (BackpropagationLayer*) init: (Backpropagation*) backpropagation
//						   for: (FeedforwardLayer*) layer
//{
//	backpropagation = backpropagation;
//	layer = layer;
//	
//	int neuronCount = [layer neuronCount];
//	
//	error = [[NSMutableArray alloc] initWithCapacity: neuronCount];
//	errorDelta = [[NSMutableArray alloc] initWithCapacity: neuronCount];
//	
//	if ([layer getNext] != nil){
//		accMatrixDelta = [[Matrix alloc] init: [layer getNeuronCount] + 1 : [[layer getNext] getNeuronCount]];
//		matrixDelta = [[Matrix alloc] init: [layer getNeuronCount] + 1 : [[layer getNext] getNeuronCount]];
//		biasRow = [layer getNeuronCount];
//	}
//}
//
//
//// Accumulate a matrix delta.
//- (void) accumulateMatrixDelta: (int) i1 : (int) i2 : (double) value {
//	[accMatrixDelta add: i1 : i2 : value];
//}
//
//
//// Accumulate a threshold delta.
//- (void) accumulateThresholdDelta: (int) index : (double) value {
//	[accMatrixDelta add: biasRow : index : value];
//}
//
//
//// Calculate the current error.
//- (void) calcError {
//	BackpropagationLayer next = [backpropagation getBackpropagationLayer: [layer getNext]];
//	
//	for (int i = 0; i < this.layer.getNext().getNeuronCount(); i++){
//		for (int j = 0; j < this.layer.getNeuronCount(); j++){
//			[self accumulateMatrixDelta: j : i : [next getErrorDelta: i] * [layer getFire: j]];
//			[self setError: j : [self getError: j] + [[[layer getMatrix] get: j : i]] * [next getErrorDelta: i];
//		}
//		
//		[self accumulateThresholdDelta: i : [next getErrorDelta: i]];
//	}
//	
//	// calculate hidden layer deltas
//	if ([layer isHidden])
//		for (int i = 0; i < this.layer.getNeuronCount(); i++)
//			[self setErrorDelta: i : [BoundNumbers bound: [self calculateDelta: i]]];
//}
//
//
//// Calculate the error for the given ideal values.
//- (void) calcError: (NSMutableArray*) ideal {
//	// layer errors and deltas for output layer
//	for (int i = 0; i < [layer getNeuronCount]; i++){
//		[self setError: i : ideal[i] - [layer getFire: i]];
//		[self setErrorDelta: i : BoundNumbers.bound([self calculateDelta: i])];
//	}
//}
//
//
//// Calculate the delta for actual vs ideal. This is the amount that will be applied during learning.
//- (double) calculateDelta: (int) index {
//	return [self getError: index] * [layer.activationFunction derivative: layer.fire[index]];
//}
//
//
//// Clear the error values.
//- (void) clear {
//	for (int index = 0; index < [layer neuronCount]; index++){
//		error[index] = [[NSNumber alloc] initWithDouble: 0];
//	}
//}
//
//
//// Learn from the last error calculation.
//- (void) learn: (double) learnRate : (double) momentum {
//	Matrix* m1 = [accMatrixDelta multiply: learnRate];
//	Matrix* m2 = [matrixDelta multiply: momentum];
//	matrixDelta = [m1 add: m2];
//	layer.setMatrix(add(layer.matrix, matrixDelta));
//	[accMatrixDelta clear];
//}
//			 
//@end
//
//#endif
//
////
////  NeuralNetwork.m
////  Gesture Control
////
////  Created by Bryan Herman on 8/21/12.
////  Copyright (c) 2012 Bryan Herman. All rights reserved.
////
//
//#ifndef FEEDFORWARD_NEURAL_NETWORK
//#define FEEDFORWARD_NEURAL_NETWORK
//
//#import "FeedforwardNeuralNetwork.h"
//
//@implementation FeedforwardNetwork
//
//@synthesize layers;
//@synthesize inputLayer;
//@synthesize outputLayer;
//
//// Construct a random neural network.
//- (FeedforwardNetwork*) init: (int) numberOfLayers : (int) neuronsPerLayer : (int) inputs {
//	self = [super init];
//	
//	// add the input layer
//	[self addLayer: [[FeedforwardLayer alloc] init: inputs]];
//	
//	// add the hidden layers
//	for (int index = 0; index < numberOfLayers; index++)
//		[self addLayer : [[FeedforwardLayer alloc] init: neuronsPerLayer]];
//	
//	// add the output layer
//	[self addLayer : [[FeedforwardLayer alloc] init: 2]];
//	
//	// randomize this network
//	[self randomize];
//	
//	return self;
//}
//
//
//// Unarchiver
//- (id) initWithCoder: (NSCoder*)decoder {
//	
//}
//
//
//// Archiver
//- (void) encodeWithCoder: (NSCoder*)encoder {
//	
//}
//
//
//// Add a layer to the neural network. The first layer added is the input layer, the last layer added is the output layer.
//- (void) addLayer: (FeedforwardLayer*) layer {
//	// set up the next and previous pointers
//	if (outputLayer != nil){
//		layer.previous = outputLayer;
//		outputLayer.next = layer;
//	}
//	
//	// update the input and output layers
//	if ([layers count] == 0)
//		inputLayer = outputLayer = layer;
//	else
//		outputLayer = layer;
//	
//	// add the new layer
//	[layers addObject: layer];
//}
//
//
//// Calculate the error for this neural network using root-mean-square.
//- (double) calculateError: (NSMutableArray*) input : (NSMutableArray*) ideal {
//	double globalError = 0;
//	double size = 0;
//	
//	for (int i = 0; i < [ideal count]; i++){
//		[self computeOutputs: input[i]];
//		
//		for (int index = 0; index < [outputLayer.fire count]; index++){
//			double delta = [ideal[index] doubleValue] - [outputLayer.fire[index] doubleValue];
//			globalError += delta * delta;
//		}
//		size += [ideal count];
//	}
//	
//	return sqrt(globalError / size);
//}
//
//
//// Calculate the total number of neurons in the network across all layers.
//- (int) neuronCount {
//	int result = 0;
//	
//	for (int index = 0; index < sizeof(layers); index++){
//		FeedforwardLayer* layer = layers[index];
//		result += [layer neuronCount];
//	}
//	
//	return result;
//}
//
//
//// Compute the outputs for certain inputs.
//- (NSMutableArray*) computeOutputs: (NSMutableArray*) input {
//	for (FeedforwardLayer* layer in layers)
//		if ([layer isInput])
//			[layer computeOutputs: input];
//		else if ([layer isHidden])
//			[layer computeOutputs: NULL];
//	
//	return outputLayer.fire;
//}
//
//
//// How manty hidden layers are there?
//- (int) hiddenLayerCount {
//	return [layers count] - 2;
//}
//
//
//// Get the hidden layers for this network
//- (NSMutableArray*) hiddenLayers {
//	NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity: [layers count]];
//	
//	for (FeedforwardLayer* layer in layers)
//		if ([layer isHidden])
//			[result addObject: layer];
//	
//	return result;
//}
//
//
//// How big is the weight / threshold matrix?
//- (int) matrixSize {
//	int result = 0;
//	
//	for (FeedforwardLayer* layer in layers)
//		result += [layer matrixSize];
//	
//	return result;
//}
//
//
//// Randomize the weight / threshold matrix
//- (void) randomize {
//	for (FeedforwardLayer* layer in layers)
//		[layer randomize];
//}
//
//@end
//
//#endif

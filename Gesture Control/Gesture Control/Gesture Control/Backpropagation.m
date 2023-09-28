////
////  Trainer.m
////  Gesture Control
////
////  Created by Bryan Herman on 9/24/12.
////  Copyright (c) 2012 Bryan Herman. All rights reserved.
////
//
//#ifndef BACKPROPAGATION
//#define BACKPROPAGATION
//
//#import "Backpropagation.h"
//
//
//@implementation Backpropagation
//
//@synthesize error;
//@synthesize network;
//@synthesize learningRate;
//@synthesize momentum;
//@synthesize input;
//@synthesize ideal;
//
//
//// Initialize.
//- (Backpropagation*) init: (FeedforwardNetwork*) n : (DataSet*) data : (double) learn : (double) m){
//	network = n;
//	learningRate = learn;
//	momentum = m;
//	input = [data getInputs];
//	ideal = [data getOutputs];
//	
//	FeedforwardLayer[] layers = [network getLayers];
//	for (int index = 0; index < ; index++){
//		FeedforwardLayer layer = layers[index];
//		
//		BackpropagationLayer bpl = [[BackpropagationLayer alloc] init: self : layer];
//		layerMap.put(layer, bpl);
//	}
//}
//
//
//// Calculate the error for the recognition just done.
//- (void) calcError: (NSMutableArray*) input {
//	// clear out all previous error data
//	for (FeedforwardLayer layer : network.getLayers())
//		getBackpropagationLayer(layer).clearError();
//	
//	for (int i = sizeof (network.getLayers()) - 1; i >= 0; i--){
//		FeedforwardLayer* layer = network.getLayers().get(i);
//		
//		if (layer.isOutput())
//			getBackpropagationLayer(layer).calcError(ideal);
//		else
//			getBackpropagationLayer(layer).calcError();
//	}
//}
//
//
//// Get the BackpropagationLayer that corresponds to the specified layer.
//- (BackpropagationLayer*) getBackpropagationLayer: (FeedforwardLayer*) layer {
//	BackpropagationLayer* result = layerMap.get(layer);
//	
//	return result;
//}
//
//
//// Perform one iteration of training.
//- (void) iteration {
//	for (int j = 0; j < input.length; j++){
//		network.processInput(input[j]);
//		calcError(ideal[j]);
//	}
//	
//	learn();
//	
//	error = network.calculateError(input, ideal);
//}
//
//
//// Modify the weight matrix and thresholds based on the last error calculation.
//- (void) learn {
//	for (int index = 0; index < network.getLayers().size(); index++){
//		FeedforwardLayer* layer = network.getLayers().get(index);
//		getBackpropagationLayer(layer).learn(learnRate, momentum);
//	}
//}
//
//@end
//
//#endif
//
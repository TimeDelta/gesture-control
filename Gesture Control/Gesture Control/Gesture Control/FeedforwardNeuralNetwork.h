//
//  NeuralNetwork.h
//  Gesture Control
//
//  Created by Bryan Herman on 8/21/12.
//  Copyright (c) 2012 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedforwardLayer.h"

@interface FeedforwardNetwork : NSObject<NSCoding>

@property (readonly) NSMutableArray* layers;
@property (readonly) FeedforwardLayer* inputLayer;
@property (readonly) FeedforwardLayer* outputLayer;

- (void) addLayer: (FeedforwardLayer*) layer;
- (double) calculateError: (NSMutableArray*) input : (NSMutableArray*) ideal;
- (int) neuronCount;
- (NSMutableArray*) computeOutputs: (NSMutableArray*) input;
- (int) hiddenLayerCount;
- (NSMutableArray*) hiddenLayers;
- (int) matrixSize;
- (void) randomize;

@end

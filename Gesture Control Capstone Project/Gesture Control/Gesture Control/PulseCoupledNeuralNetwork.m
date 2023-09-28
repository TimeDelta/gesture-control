////
////  PulseCoupledNeuralNetwork.m
////  Gesture Control
////
////  Created by Bryan Herman on 1/29/13.
////  Copyright (c) 2013 Bryan Herman. All rights reserved.
////
//
//#ifndef PC_NEURAL_NETWORK
//#define PC_NEURAL_NETWORK
//
//#import "PulseCoupledNeuralNetwork.h"
//
//@implementation PulseCoupledNeuralNetwork
//
//@synthesize neurons;
//
//// constructor
//- (id) init: (AppController*)control {
//	self = [super init];
//	
//	controller = control;
//	
//	const int WIDTH = 640;
//	const int HEIGHT = 426;
//	
//	// set the dimensions of the network
//	neurons = [[NSMutableArray alloc] initWithCapacity: WIDTH];
//	for (int i = 0; i < WIDTH; i++)
//		neurons[i] = [[NSMutableArray alloc] initWithCapacity: HEIGHT];
//	
//	double decay = [control.decayConstantTextField doubleValue];
//	double thresholdMod = [control.thresholdModulatorTextField doubleValue];
//	
//	// set the neurons
//	for (int x = 0; x < WIDTH; x++)
//	for (int y = 0; y < HEIGHT; y++)
//		neurons[x][y] = [[PulseCoupledNeuron alloc] init: decay : thresholdMod];
//	
//	return self;
//}
//
//
//// process an image
//- (void) processImage {
//	NSImage* image = [[NSImage alloc] initByReferencingURL: [controller.imagePathControl URL]];
//	
//	const int INTENSITY_LEVELS = 256;
//	int histogram[INTENSITY_LEVELS];
//	for (int i = 0; i < INTENSITY_LEVELS; i++)
//		histogram[i] = 0;
//	
//	int numberOfStdDevsPFT = [controller.stdDevsPFTTextField intValue];
//	int numberOfStdDevsLS = [controller.stdDevsLSTextField intValue];
//	
//	NSBitmapImageRep* imageRep = [image representations][0];
//	
//	for (int x = 0; x < [image size].width; x++)
//	for (int y = 0; y < [image size].height; y++){
//		NSColor* color = [imageRep colorAtX: x y: y];
//		
//		// calculate the intensity value for the current pixel
//		int intensity = 0.2126 * [color redComponent] + 0.7152 * [color greenComponent] + 0.0722 * [color blueComponent];
//		histogram[intensity]++;
//		[neurons[x][y] setFeedingInput: intensity];
//	}
//	
//	int numberOfPixels = [image size].width * [image size].height;
//	
//	double totalWeightedSum = 0;
//	for (int i = 0; i < INTENSITY_LEVELS; i++)
//		totalWeightedSum += i * histogram[i];
//	
//	// use Otsu's Method to estimate the initial threshold
////	int backgroundWeight = 0;
////	int foregroundWeight = 0;
////	double maxVariance = 0;
////	double backgroundSum = 0;
////	int thresholdEstimate;
////	for (int t = 0; t < INTENSITY_LEVELS; t++){
////		backgroundWeight += histogram[t];
////		if (backgroundWeight == 0)
////			continue;
////		
////		foregroundWeight = numberOfPixels - backgroundWeight;
////		if (foregroundWeight == 0)
////			break;
////		
////		backgroundSum += (double)(t * histogram[t]);
////		
////		double meanBackground = backgroundSum / backgroundWeight;
////		double meanForeground = (totalWeightedSum - backgroundSum) / foregroundWeight;
////		
////		// calculate inter-class variance
////		double currentVariance = (double)backgroundWeight * (double)foregroundWeight * (meanBackground - meanForeground) * (meanBackground - meanForeground);
////		
////		if (currentVariance > maxVariance){
////			maxVariance = currentVariance;
////			thresholdEstimate = t;
////		}
////	}
//	int thresholdEstimate = totalWeightedSum / numberOfPixels;
//	
//	// use pixels with intensity > thresholdEstimate to approximate the
//	// intensity mean and standard deviation of object pixels
//	double objectIntensityMean = 0;
//	int pixels = 0;
//	for (int i = thresholdEstimate + 1; i < INTENSITY_LEVELS; i++){
//		objectIntensityMean += i * histogram[i];
//		pixels += histogram[i];
//	}
//	objectIntensityMean /= pixels;
//	
//	double objectStandardDeviation = 0;
//	for (int i = thresholdEstimate + 1; i < INTENSITY_LEVELS; i++)
//	for (int j = 0; j < histogram[i]; j++)
//		objectStandardDeviation += pow(histogram[i] - objectIntensityMean, 2);
//	objectStandardDeviation = sqrt(objectStandardDeviation / pixels);
//	
//	// calculate the primary firing threshold and linking strength
//	double primaryFiringThreshold = thresholdEstimate;//objectIntensityMean + numberOfStdDevsPFT * objectStandardDeviation;
//	double linkingStrength = (primaryFiringThreshold / (thresholdEstimate - numberOfStdDevsLS * objectStandardDeviation) - 1) / 5;
//	
//	for (int x = 0; x < [image size].width; x++)
//	for (int y = 0; y < [image size].height; y++){
//		((PulseCoupledNeuron*)neurons[x][y]).threshold = primaryFiringThreshold;
//		[neurons[x][y] setLinkingStrength: linkingStrength];
//	}
//	
//	BOOL isBackgroundPixel[(int)[image size].width][(int)[image size].height];
//	
//	// process each neuron the specified number of times
//	for (int iteration = 0; iteration < [controller.iterationsTextField intValue]; iteration++){
//		// set up the array to hold the new leaky integrator inputs for the next
//		// iteration
//		NSMutableArray* integratorInputs = [[NSMutableArray alloc] initWithCapacity: [image size].width];
//		for (int i = 0; i < [image size].width; i++){
//			integratorInputs[i] = [[NSMutableArray alloc] initWithCapacity: [image size].height];
//			for (int j = 0; j < [image size].height; j++){
//				integratorInputs[i][j] = [[NSMutableArray alloc] initWithCapacity: 8];
//				for (int k = 0; k < 8; k++)
//					[integratorInputs[i][j] addObject: [[NSNumber alloc] initWithDouble: 0]];
//			}
//		}
//		
//		for (int x = 0; x < [image size].width; x++)
//		for (int y = 0; y < [image size].height; y++){
//			double output = [neurons[x][y] process];
//			
//			if (output == 1)
//				isBackgroundPixel[x][y] = NO;
//			else isBackgroundPixel[x][y] = YES;
//			
//			if (x > 0){
//				// Top Left
//				if (y > 0)
//					integratorInputs[x][y][0] = [[NSNumber alloc] initWithDouble: output];
//				
//				// Left
//				integratorInputs[x][y][3] = [[NSNumber alloc] initWithDouble: output];
//				
//				// Bottom Left
//				if (y < [image size].height)
//					integratorInputs[x][y][4] = [[NSNumber alloc] initWithDouble: output];
//			}
//			
//			if (x < [image size].width){
//				// Top Right
//				if (y > 0)
//					integratorInputs[x][y][2] = [[NSNumber alloc] initWithDouble: output];
//				
//				// Right
//				integratorInputs[x][y][5] = [[NSNumber alloc] initWithDouble: output];
//				
//				// Bottom Right
//				if (y < [image size].height)
//					integratorInputs[x][y][7] = [[NSNumber alloc] initWithDouble: output];
//			}
//			
//			// Top
//			if (y > 0)
//				integratorInputs[x][y][1] = [[NSNumber alloc] initWithDouble: output];
//			
//			// Bottom
//			if (y < [image size].height)
//				integratorInputs[x][y][6] = [[NSNumber alloc] initWithDouble: output];
//		}
//		
//		// assign new integrator inputs
//		for (int x = 0; x < [image size].width; x++)
//		for (int y = 0; y < [image size].height; y++)
//			[neurons[x][y] setLeakyIntegratorInput: integratorInputs[x][y]];
//	}
//	
//	// update image
//	for (int x = 0; x < [image size].width; x++)
//	for (int y = 0; y < [image size].height; y++)
//		if (!isBackgroundPixel[x][y])
//			[imageRep setColor: NSColor.redColor atX:x y:y];
//	// remove all of the image representations
//	NSArray* representations = [image representations];
//	for (int i = 0; i < [representations count]; i++)
//		[image removeRepresentation: representations[i]];
//	// add the new image representation
//	[image addRepresentation: imageRep];
//	[controller.imageView setImage: image];
//}
//
//@end
//
//#endif

//
//  Controller.h
//  Gesture Control
//
//  Created by Bryan Herman on 2/2/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CorePlot/CorePlot.h>
#import "PulseCoupledNeuralNetwork.h"
#import "Trainer.h"

@interface AppController : NSViewController<CPTPlotDataSource> {
	IBOutlet NSTextField* decayConstantTextField;
	IBOutlet NSTextField* iterationsTextField;
	IBOutlet NSTextField* stdDevsLSTextField;
	IBOutlet NSTextField* stdDevsPFTTextField;
	IBOutlet NSTextField* thresholdModulatorTextField;
	IBOutlet NSPathControl* imagePathControl;
	
	IBOutlet NSImageView* imageView;
	
	IBOutlet NSTextField* featureNumberTextField;
	IBOutlet NSButton* useGreaterThanCheckBox;
	IBOutlet NSTextField* haarClassifierMaxErrorTextField;
	IBOutlet NSTextField* haarClassifierSubwindowsTextField;
	IBOutlet CPTGraphHostingView* haarClassifierGraphHostView;
	
	IBOutlet NSTextField* hiddenLayersTextField;
	IBOutlet NSTextField* neuronsPerLayerTextField;
	IBOutlet NSTextField* learningRateTextField;
	IBOutlet NSTextField* trialsTextField;
	IBOutlet NSTextFieldCell* dataSetTrainingRatioTextField;
	IBOutlet NSScrollView* resultsTable;
	
	IBOutlet NSWindow* window;
}

// PCNN
@property (weak) IBOutlet NSTextField* decayConstantTextField;
@property (weak) IBOutlet NSTextField* iterationsTextField;
@property (weak) IBOutlet NSTextField* stdDevsLSTextField;
@property (weak) IBOutlet NSTextField* stdDevsPFTTextField;
@property (weak) IBOutlet NSTextField* thresholdModulatorTextField;
@property (weak) IBOutlet NSPathControl* imagePathControl;

// Image View
@property (weak) IBOutlet NSImageView* imageView;

// Haar Classifier
@property (weak) IBOutlet NSTextField* featureNumberTextField;
@property (weak) IBOutlet NSButton* useGreaterThanCheckBox;
@property (weak) IBOutlet NSTextField* haarClassifierMaxErrorTextField;
@property (weak) IBOutlet NSTextField* haarClassifierSubwindowsTextField;
@property (weak) IBOutlet CPTGraphHostingView* haarClassifierGraphHostView;
@property DataSet* haarClassifierDataSet;
@property NSMutableArray* haarFeatureErrors;

// Neural Network
@property (weak) IBOutlet NSTextField* hiddenLayersTextField;
@property (weak) IBOutlet NSTextField* neuronsPerLayerTextField;
@property (weak) IBOutlet NSTextField* learningRateTextField;
@property (weak) IBOutlet NSTextField* trialsTextField;
@property (weak) IBOutlet NSTextFieldCell* dataSetTrainingRatioTextField;
@property (weak) IBOutlet NSScrollView* resultsTable;
@property DataSet* neuralNetworkDataSet;

// Data Set
@property (weak) IBOutlet NSTextField* indexFingerSize;
@property (weak) IBOutlet NSTextField* indexFingerX;
@property (weak) IBOutlet NSTextField* indexFingerY;
@property (weak) IBOutlet NSTextField* middleFingerSize;
@property (weak) IBOutlet NSTextField* middleFingerX;
@property (weak) IBOutlet NSTextField* middleFingerY;
@property (weak) IBOutlet NSTextField* thumbSize;
@property (weak) IBOutlet NSTextField* thumbX;
@property (weak) IBOutlet NSTextField* thumbY;

// PCNN
- (IBAction) processPCNN: (id)sender;

// Haar Classifier
- (IBAction) trainHaarClassifier: (id)sender;
- (IBAction) plotFeatureErrorFunction: (id)sender;
- (IBAction)loadHaarData: (id)sender;

// Neural Network
- (IBAction)runNeuralNetwork:(id)sender;

// Data Set
- (IBAction)addCase:(id)sender;
- (IBAction)chooseInput:(id)sender;

@end

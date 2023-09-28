//
//  Controller.h
//  Gesture Control
//
//  Created by Bryan Herman on 2/2/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CorePlot/CorePlot.h>
//#import "PulseCoupledNeuralNetwork.h"
#import "Trainer.h"

@interface AppController : NSViewController/*<CPTPlotDataSource>*/ {
	// Haar Classifier
	IBOutlet NSTextField*	haarClassifierMaxErrorTextField;
	IBOutlet NSButton*		incrementMaxErrorCheckBox;
	IBOutlet NSTextField*	incrementMaxErrorTextField;
	IBOutlet NSTextField*	haarClassifierSubwindowsTextField;
	IBOutlet NSButton*		incrementSubwindowsCheckBox;
	IBOutlet NSTextField*	incrementSubwindowsTextField;
	IBOutlet NSTextField*	firstStageSizeTextField;
	IBOutlet NSButton*		incrementFirstStageSizeCheckBox;
	IBOutlet NSTextField*	incrementFirstStageSizeTextField;
	IBOutlet NSTextField*	stageStepSizeTextField;
	IBOutlet NSButton*		incrementStageStepSizeCheckBox;
	IBOutlet NSTextField*	incrementStageStepSizeTextField;
	IBOutlet NSTextField*	haarIterationsTextField;
	IBOutlet NSTableView*	resultsTable;
	IBOutlet NSArrayController* haarResultsArrayController;
	DataSet* haarClassifierDataSet;
	NSMutableArray* classifiers;
	NSThread* thread;
	
	BOOL stop;
	
	IBOutlet NSWindow* window;
}

// Haar Classifier
- (IBAction)trainHaarClassifier: (id)sender;
- (IBAction)loadHaarData: (id)sender;
- (IBAction)stop: (id)sender;
- (IBAction)saveClassifier:(id)sender;
- (IBAction)saveResults:(id)sender;

@end

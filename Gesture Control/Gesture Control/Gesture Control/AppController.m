//
//  Controller.m
//  Gesture Control
//
//  Created by Bryan Herman on 2/2/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import "AppController.h"

@implementation AppController

@synthesize haarFeatureErrors;
@synthesize haarClassifierDataSet;
@synthesize neuralNetworkDataSet;

- (IBAction) processPCNN: (id)sender {
	PulseCoupledNeuralNetwork* network = [[PulseCoupledNeuralNetwork alloc] init: self];
	[network processImage];
}


- (IBAction) trainHaarClassifier: (id)sender {
	const int NUMBER_OF_HAAR_FEATURES = 103;
	
//	double maxError = [haarClassifierMaxErrorTextField doubleValue];
//	int subwindows = [haarClassifierSubwindowsTextField intValue];
//	
//	Trainer* trainer = [[Trainer alloc] init];
//	[trainer train: maxError withSubwindows: subwindows];
//	haarFeatureErrors = trainer.haarFeatureErrors;
}


- (IBAction)loadHaarData: (id)sender {
	// Let the user choose an output file, then start the process of writing samples
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanSelectHiddenExtension:YES];
	[openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
		if (result == NSFileHandlingPanelOKButton)
			// user did select an image...
			[self loadDataSetDidEnd:openPanel returnCode:result];
	}];
}


- (void)loadDataSetDidEnd: (NSOpenPanel*)panel
				returnCode: (int)returnCode {
	if (returnCode == NSOKButton)
		haarClassifierDataSet = [NSKeyedUnarchiver unarchiveObjectWithFile:[[panel URL] path]];
}


- (NSMutableArray*) trainFeature: (HaarFeature*)feature {
	const int NUMBER_OF_POINTS = 400;
	const double STEP_SIZE = .25;
	NSMutableArray* errors = [[NSMutableArray alloc] initWithCapacity: 2];
	errors[0] = [[NSMutableArray alloc] initWithCapacity: NUMBER_OF_POINTS];
	errors[1] = [[NSMutableArray alloc] initWithCapacity: NUMBER_OF_POINTS];
	
	// get the best error using greater than threshold
	// need to figure out if error in terms of threshold is a linear function
	feature.useGreaterThanThreshold = YES;
	for (int i = 0; i < 400; i++){
		feature.threshold += STEP_SIZE;
		errors[0][i] = [[NSNumber alloc] initWithDouble: [self featureError: feature]];
	}
	
	// get the best error using less than threshold
	feature.useGreaterThanThreshold = NO;
	for (int i = 0; i < 400; i++){
		feature.threshold += STEP_SIZE;
		errors[0][i] = [[NSNumber alloc] initWithDouble: [self featureError: feature]];
	}
	
	return errors;
}


- (double) featureError: (HaarFeature*)feature {
	int subwindows = 5000;//[haarClassifierSubwindowsTextField intValue];
	
	const int USABLE_WIDTH = (int)[haarClassifierDataSet.input[0] count] - feature.width;
	const int USABLE_HEIGHT = (int)[haarClassifierDataSet.input[0][0] count] - feature.height;
	
	// calculate how many sub windows per row
	// columns / rows = width / height
	// columns * rows ≤ subwindows
	// subwindowsPerRow = columns = √(s * w / h)
	const int subwindowsPerRow = sqrt(subwindows * USABLE_WIDTH / USABLE_HEIGHT);
	const int widthBetweenSubwindows = USABLE_WIDTH / subwindowsPerRow;
	
	// calculate how many subwindows per column
	// columns / rows = width / height
	// columns * rows ≤ subwindows
	// subwindowsPerColumn = rows = √(s * h / w)
	const int subwindowsPerColumn = sqrt(subwindows * USABLE_HEIGHT / USABLE_WIDTH);
	const int heightBetweenSubwindows = USABLE_HEIGHT / subwindowsPerColumn;
	
	int wrong = 0;
	int right = 0;
	for (int i = 0; i < haarClassifierDataSet.size; i++){
		NSMutableArray* integralImageSums = [self calculateIntegralImageSums: haarClassifierDataSet.input[i]];
		
		for (int y = 0; y < subwindowsPerColumn; y ++)
		for (int x = 0; x < subwindowsPerRow; x++){
			int xOffset = x * widthBetweenSubwindows;
			int yOffset = y * heightBetweenSubwindows;
			
			BOOL actual = [feature classify:integralImageSums
										atX:xOffset
										  y:yOffset];
			BOOL ideal = [self correctClassification: haarClassifierDataSet.ideal[i] : x : y];
			
			if (actual == ideal)
				right++;
			else
				wrong++;
		}
	}
	
	return (double)wrong / (double)(right + wrong);
}


- (NSMutableArray*) calculateIntegralImageSums: (NSMutableArray*)input {
	NSMutableArray* integralImageSums = [[NSMutableArray alloc] initWithCapacity:[input count]];
	for (int x = 0; x < [input count]; x++)
		integralImageSums[x] = [[NSMutableArray alloc] initWithCapacity: [input[0] count]];
	
	double total = 0;
	for (int x = 0; x < [input count]; x++)
	for (int y = 0; y < [input[0] count]; y++){
		total += [input[x][y] doubleValue];
		integralImageSums[x][y] = [[NSNumber alloc] initWithDouble: total];
	}
	
	return integralImageSums;
}


-(BOOL)correctClassification: (NSMutableArray*)idealOutputs : (int)x : (int)y {
	int selected = 0;
	int notSelected = 0;
	for (int i = x; i < x + 48; i++)
		for (int j = y; j < y + 48; j++)
			if (idealOutputs[i][j] == [[NSNumber alloc] initWithBool: YES])
				selected++;
			else
				notSelected++;
	
	return selected >= notSelected;
}



- (IBAction) plotFeatureErrorFunction: (id)sender {
	// prepare the graph
	CPTXYGraph* graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
	graph.frame = self.view.bounds;
	graph.paddingRight = 50.0f;
	graph.paddingLeft = 50.0f;
	graph.plotAreaFrame.masksToBorder = NO;
	graph.plotAreaFrame.cornerRadius = 0.0f;
	CPTMutableLineStyle* borderLineStyle = [CPTMutableLineStyle lineStyle];
	borderLineStyle.lineColor = [CPTColor whiteColor];
	borderLineStyle.lineWidth = 2.0f;
	graph.plotAreaFrame.borderLineStyle = borderLineStyle;
	haarClassifierGraphHostView.hostedGraph = graph;
	
	// prepare the axes
	CPTXYAxisSet* xyAxisSet = (id)graph.axisSet;
	CPTXYAxis* xAxis = xyAxisSet.xAxis;
	CPTMutableLineStyle* lineStyle = [xAxis.axisLineStyle mutableCopy];
	lineStyle.lineCap = kCGLineCapButt;
	xAxis.axisLineStyle = lineStyle;
	xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
	CPTXYAxis* yAxis = xyAxisSet.yAxis;
	yAxis.axisLineStyle = nil;
	
	// prepare the data
	CPTScatterPlot* dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame: graph.bounds];
	dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle = nil;
	dataSourceLinePlot.dataSource = self;
	dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
	[graph addPlot: dataSourceLinePlot];
}


- (CPTNumericData*) dataForPlot: (CPTPlot*)plot recordIndexRange:(NSRange)indexRange {
	const int NUMBER_OF_POINTS = 400;
	const double STEP_SIZE = .25;
	
	int featureNumber = [featureNumberTextField intValue];
	int thresholdType = [useGreaterThanCheckBox state];
	
	NSUInteger numFields = plot.numberOfFields;
	
	NSMutableData* data = [[NSMutableData alloc] initWithLength:NUMBER_OF_POINTS * numFields * sizeof(double)];
	
	double* nextValue = data.mutableBytes;
	
	for (NSUInteger i = 0; i < NUMBER_OF_POINTS; i++){
		*nextValue++ = (double)(i * STEP_SIZE);
		*nextValue++ = [haarFeatureErrors[featureNumber][thresholdType][i] doubleValue];
	}
	
	return [CPTMutableNumericData numericDataWithData:data
											 dataType:plot.doubleDataType
												shape:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:[haarFeatureErrors count]],
													   [NSNumber numberWithUnsignedInteger:numFields], nil]
											dataOrder:CPTDataOrderRowsFirst];
}


- (CPTLayer*) dataLabelForPlot: (CPTPlot*)plot recordIndex:(NSUInteger)index {
    if (index % 5)
        return (id)[NSNull null];
    else
        return nil; // Use default label style
}


- (IBAction)runNeuralNetwork:(id)sender {
	
}

- (IBAction)addCase:(id)sender {
	
}

- (IBAction)chooseInput:(id)sender {
	
}

@end

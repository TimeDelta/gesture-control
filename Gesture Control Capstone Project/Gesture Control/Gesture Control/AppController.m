//
//  Controller.m
//  Gesture Control
//
//  Created by Bryan Herman on 2/2/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import "AppController.h"

@implementation AppController

- (void)awakeFromNib {
	classifiers = [[NSMutableArray alloc] init];
}


- (IBAction) trainHaarClassifier: (id)sender {
	if (![thread isExecuting]){
		thread = [[NSThread alloc] initWithTarget:self selector:@selector(train) object:nil];
		[thread setThreadPriority:1.0];
		stop = false;
		[thread start];
	}
//	[self performSelectorInBackground:@selector(train) withObject:nil];
}


- (void) train {
	double maxError =				[haarClassifierMaxErrorTextField doubleValue];
	double maxErrorIncrement =		[incrementMaxErrorTextField doubleValue];
	int subwindows =				[haarClassifierSubwindowsTextField intValue];
	int subwindowsIncrement =		[incrementSubwindowsTextField intValue];
	int firstStageSize =			[firstStageSizeTextField intValue];
	int firstStageSizeIncrement =	[incrementFirstStageSizeTextField intValue];
	int stageStepSize =				[stageStepSizeTextField intValue];
	int stageStepSizeIncrement =	[incrementStageStepSizeTextField intValue];
	int iterations =				[haarIterationsTextField intValue];
	
	// calculate the integral image sums only once
	NSMutableArray* integralImageSums = [[NSMutableArray alloc] initWithCapacity:haarClassifierDataSet.size];
	for (int i = 0; i < haarClassifierDataSet.size; i++)
		integralImageSums[i] = [self calculateIntegralImageSum: haarClassifierDataSet.input[i]];
	
	for (int iteration = 0; iteration < iterations; iteration++){
		if (stop)
			break;
		
		Trainer* trainer = [[Trainer alloc] init: haarClassifierDataSet : integralImageSums];
		double error = [trainer train: maxError
						   subwindows: subwindows
					   firstStageSize: firstStageSize
						stageStepSize:stageStepSize];
		
		[classifiers addObject: trainer.classifier];
		
		// get the average runtime for the classifier
		NSDate* date = [NSDate date];
		for (int i = 0; i < haarClassifierDataSet.size; i++)
			[trainer.classifier classify:integralImageSums[i] : subwindows];
		// Use "-" modifier to conversion since receiver is prior than now
		double elapsedTimeInMS = [date timeIntervalSinceNow] * -1000.0;
		double averageRuntime = elapsedTimeInMS / haarClassifierDataSet.size;
		
		double truePositiveRate = [trainer calculateClassifierTruePositiveRate];
		
		// update the table
		NSArray* objects = [[NSArray alloc] initWithObjects: [NSNumber numberWithInt:subwindows], [NSNumber numberWithInt:firstStageSize], [NSNumber numberWithInt:stageStepSize], [NSNumber numberWithDouble:truePositiveRate], [NSNumber numberWithDouble:error], [NSNumber numberWithDouble:averageRuntime], nil];
		NSArray* keys = [[NSArray alloc] initWithObjects: @"subwindows", @"firstStageSize", @"stageStepSize", @"truePositiveRate", @"error", @"runtime", nil];
		NSDictionary* newValues = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
		[haarResultsArrayController addObject: newValues];
		
		// increment parameters for the next iteration
		if ([incrementMaxErrorCheckBox state] == 1)
			maxError += maxErrorIncrement;
		if ([incrementSubwindowsCheckBox state] == 1)
			subwindows += subwindowsIncrement;
		if ([incrementFirstStageSizeCheckBox state] == 1)
			firstStageSize += firstStageSizeIncrement;
		if ([incrementStageStepSizeCheckBox state] == 1)
			stageStepSize += stageStepSizeIncrement;
	}
}


- (IBAction)stop: (id)sender {
	if ([thread isExecuting])
		@synchronized (self){
			stop = true;
		}
}

- (IBAction)saveClassifier:(id)sender {
	int index = [[resultsTable selectedRowIndexes] firstIndex];
	NSSavePanel* savePanel = [NSSavePanel savePanel];
	[savePanel setCanSelectHiddenExtension:YES];
	[savePanel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
		if (result == NSFileHandlingPanelOKButton){
			CascadeClassifier* classifier = classifiers[index];
			[NSKeyedArchiver archiveRootObject:classifier toFile:[[savePanel URL] path]];
		}
	}];
}

- (IBAction)saveResults:(id)sender {
	// fill-in if needed
}


- (IBAction)loadHaarData: (id)sender {
	// Let the user choose an output file, then start the process of writing samples
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanSelectHiddenExtension:YES];
	[openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result){
		if (result == NSFileHandlingPanelOKButton)
			// user selected a file
			[self loadDataSetDidEnd:openPanel returnCode:result];
	}];
}


- (void)loadDataSetDidEnd: (NSOpenPanel*)panel
			   returnCode: (int)returnCode {
	if (returnCode == NSOKButton){
		haarClassifierDataSet = [NSKeyedUnarchiver unarchiveObjectWithFile:[[panel URL] path]];
		for (int i = 0; i < haarClassifierDataSet.size; i++){
			NSMutableArray* output = haarClassifierDataSet.ideal[i];
			for (int x = 0; x < [output count]; x++)
			for (int y = 0; y < [output[0] count] / 2; y++)
				[output[x] exchangeObjectAtIndex:y withObjectAtIndex:[output[0] count] - 2 - y];
			haarClassifierDataSet.ideal[i] = output;
		}
	}
}


// Calculate the sum of all grayscale pixel values to the left and above the
// pixel at (x,y) for all integers x & y such that x < width and y < height.
- (NSMutableArray*) calculateIntegralImageSum: (NSMutableArray*)input {
	NSMutableArray* integralImageSum = [[NSMutableArray alloc] initWithCapacity:[input count]];
	for (int x = 0; x < [input count]; x++)
		integralImageSum[x] = [[NSMutableArray alloc] initWithCapacity: [input[0] count]];
	
	for (int y = 0; y < [input[0] count]; y++)
	for (int x = 0; x < [input count]; x++){
		if (x == 0){
			integralImageSum[x][y] = [NSNumber numberWithDouble: [input[x][y] doubleValue]];
		} else if (x >= y){
			double total = [integralImageSum[x-1][y] doubleValue];
			for (int i = 0; i <= y; i++)
				total += [input[x][i] doubleValue];
			integralImageSum[x][y] = [NSNumber numberWithDouble: total];
		} else {
			double total = [integralImageSum[x][y-1] doubleValue];
			for (int i = 0; i <= x; i++)
				total += [input[i][y] doubleValue];
			integralImageSum[x][y] = [NSNumber numberWithDouble: total];
		}
	}
	
	return integralImageSum;
}


//- (IBAction) plotFeatureErrorFunction: (id)sender {
//	// prepare the graph
//	CPTXYGraph* graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
//	graph.frame = self.view.bounds;
//	graph.paddingRight = 50.0f;
//	graph.paddingLeft = 50.0f;
//	graph.plotAreaFrame.masksToBorder = NO;
//	graph.plotAreaFrame.cornerRadius = 0.0f;
//	CPTMutableLineStyle* borderLineStyle = [CPTMutableLineStyle lineStyle];
//	borderLineStyle.lineColor = [CPTColor whiteColor];
//	borderLineStyle.lineWidth = 2.0f;
//	graph.plotAreaFrame.borderLineStyle = borderLineStyle;
//	haarClassifierGraphHostView.hostedGraph = graph;
//	
//	// prepare the axes
//	CPTXYAxisSet* xyAxisSet = (id)graph.axisSet;
//	CPTXYAxis* xAxis = xyAxisSet.xAxis;
//	CPTMutableLineStyle* lineStyle = [xAxis.axisLineStyle mutableCopy];
//	lineStyle.lineCap = kCGLineCapButt;
//	xAxis.axisLineStyle = lineStyle;
//	xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
//	CPTXYAxis* yAxis = xyAxisSet.yAxis;
//	yAxis.axisLineStyle = nil;
//	
//	// prepare the data
//	CPTScatterPlot* dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame: graph.bounds];
//	dataSourceLinePlot.identifier = @"Data Source Plot";
//	dataSourceLinePlot.dataLineStyle = nil;
//	dataSourceLinePlot.dataSource = self;
//	dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
//	[graph addPlot: dataSourceLinePlot];
//}
//
//
//- (CPTNumericData*) dataForPlot: (CPTPlot*)plot recordIndexRange:(NSRange)indexRange {
//	const int NUMBER_OF_POINTS = 400;
//	const double STEP_SIZE = .25;
//	
//	int featureNumber = [featureNumberTextField intValue];
//	int thresholdType = [useGreaterThanCheckBox state];
//	
//	NSUInteger numFields = plot.numberOfFields;
//	
//	NSMutableData* data = [[NSMutableData alloc] initWithLength:NUMBER_OF_POINTS * numFields * sizeof(double)];
//	
//	double* nextValue = data.mutableBytes;
//	
//	for (NSUInteger i = 0; i < NUMBER_OF_POINTS; i++){
//		*nextValue++ = (double)(i * STEP_SIZE);
//		*nextValue++ = [haarFeatureErrors[featureNumber][thresholdType][i] doubleValue];
//	}
//	
//	return [CPTMutableNumericData numericDataWithData:data
//											 dataType:plot.doubleDataType
//												shape:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:[haarFeatureErrors count]],
//													   [NSNumber numberWithUnsignedInteger:numFields], nil]
//											dataOrder:CPTDataOrderRowsFirst];
//}
//
//
//- (CPTLayer*) dataLabelForPlot: (CPTPlot*)plot recordIndex:(NSUInteger)index {
//    if (index % 5)
//        return (id)[NSNull null];
//    else
//        return nil; // Use default label style
//}

@end

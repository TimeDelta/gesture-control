//
//  AppDelegate.m
//  Gesture Control Playground
//
//  Created by Bryan Herman on 3/7/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// unarchive classifier for "input 'A'" gesture
	inputAClassifier = [NSKeyedUnarchiver unarchiveObjectWithFile:@"/Users/bryanherman/Pictures/Pictures/Input Text A/The Input Text A Classifier"];
	
	// unarchive classifier for "input 'B'" gesture
	
	
	// start processing input
	[self performSelectorInBackground:@selector(startProcessingInput) withObject:nil];
//	[NSThread detachNewThreadSelector:@selector(startProcessingInput) toTarget:self withObject:nil];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Bryan-Herman.Gesture_Control_Playground" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"Bryan-Herman.Gesture_Control_Playground"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel)
        return _managedObjectModel;
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Gesture_Control_Playground" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator)
		return _persistentStoreCoordinator;
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom){
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties){
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError)
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        if (!ok){
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]){
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Gesture_Control_Playground.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext)
        return _managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing])
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    
    if (![[self managedObjectContext] save:&error])
        [[NSApplication sharedApplication] presentError:error];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext)
        return NSTerminateNow;
    
    if (![[self managedObjectContext] commitEditing]){
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges])
        return NSTerminateNow;
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]){
        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn)
            return NSTerminateCancel;
    }

    return NSTerminateNow;
}


// This function continually processes input from the webcam
- (void)startProcessingInput {
	// declare these outside of loop to avoid wasting time on allocation / deallocation
	Snapshot* camera = [[Snapshot alloc] init];
	NSImage* image = [camera snapshot];
	NSRect rect;
	rect.origin.x = 0;
	rect.origin.y = 0;
	rect.size = image.size;
	NSColor* color;
	NSBitmapImageRep* imageRep;
	
	const int USABLE_WIDTH = (int)[image size].width - HaarFeature.width;
	const int USABLE_HEIGHT = (int)[image size].height - HaarFeature.height;
	
	// columns / rows = width / height
	// columns * rows ≤ subwindows
	// subwindowsPerRow = columns = √(s * w / h)
	const int subwindowsPerRow = sqrt([_subwindowsSlider intValue] * USABLE_WIDTH / USABLE_HEIGHT);
	const int widthBetweenSubwindows = USABLE_WIDTH / subwindowsPerRow;
	
	// columns / rows = width / height
	// columns * rows ≤ subwindows
	// subwindowsPerColumn = rows = √(s * h / w)
	const int subwindowsPerColumn = sqrt([_subwindowsSlider intValue] * USABLE_HEIGHT / USABLE_WIDTH);
	const int heightBetweenSubwindows = USABLE_HEIGHT / subwindowsPerColumn;

	
	// set up the integral image array
	integralImage = [[NSMutableArray alloc] initWithCapacity:(int)[image size].width];
	for (int x = 0; x < (int)[image size].width; x++)
		integralImage[x] = [[NSMutableArray alloc] initWithCapacity:(int)[image size].height];
	
	// set up the reference image array
	referenceImage = [[NSMutableArray alloc] initWithCapacity:(int)[image size].width];
	for (int x = 0; x < (int)[image size].width; x++)
		referenceImage[x] = [[NSMutableArray alloc] initWithCapacity:(int)[image size].height];
	
	NSMutableArray* currentImageArray = [[NSMutableArray alloc] initWithCapacity:(int)[image size].width];
	for (int x = 0; x < (int)[image size].width; x++)
		currentImageArray[x] = [[NSMutableArray alloc] initWithCapacity:(int)[image size].height];
	
	BOOL firstIteration = YES;
//	NSImage* originalImage;
	while (YES){
		// get the image representation
		image = [camera snapshot];
		imageRep = [[NSBitmapImageRep alloc] initWithCGImage:[image CGImageForProposedRect:&rect context:[NSGraphicsContext currentContext] hints:nil]];
//		originalImage = [[NSImage alloc] initWithCGImage:[imageRep CGImage] size:image.size];
		
		// take a picture
		@synchronized(self){
			for (int x = 0; x < [image size].width; x++)
			for (int y = 0; y < [image size].height; y++){
				color = [imageRep colorAtX:x y:y];
				double grayscale = ([color redComponent] + [color greenComponent] + [color blueComponent]) / 3;
				
				// update the reference image
				if (firstIteration)
					// on the first iteration, simply set the initial reference
					// image
					referenceImage[x][y] = [[NSNumber alloc] initWithDouble: grayscale];
				else if (grayscale < [referenceImage[x][y] doubleValue])
					referenceImage[x][y] = [[NSNumber alloc] initWithDouble:[referenceImage[x][y] doubleValue] - [_updateSlider intValue]/256.0];
				else if (grayscale > [referenceImage[x][y] doubleValue])
					referenceImage[x][y] = [[NSNumber alloc] initWithDouble:[referenceImage[x][y] doubleValue] + [_updateSlider intValue]/256.0];
				
				// use frame difference to determine if the current pixel is in
				// the foreground or background
				if (fabs(grayscale - [referenceImage[x][y] doubleValue]) >= [_thresholdSlider intValue] / 256.0){
					if ([_showVideoCheckBox state] == 1 && [_showOnlyPositivesCheckBox state] == 0)
						color = [NSColor colorWithDeviceRed:grayscale green:grayscale blue:grayscale alpha:1];
					currentImageArray[x][y] = [NSNumber numberWithDouble: grayscale];
				} else {
					if ([_showVideoCheckBox state] == 1 && [_showOnlyPositivesCheckBox state] == 0)
						color = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:1];
					currentImageArray[x][y] = [NSNumber numberWithDouble: 0];
				}
				
				if ([_showVideoCheckBox state] == 1 && [_showOnlyPositivesCheckBox state] == 0)
					[imageRep setColor:color atX:x y:y];
			}
			
			// update integral image
			for (int y = 0; y < [currentImageArray[0] count]; y++)
			for (int x = 0; x < [currentImageArray count]; x++){
				if (x == 0){
					integralImage[x][y] = [NSNumber numberWithDouble: [currentImageArray[x][y] doubleValue]];
				} else if (x >= y){
					double total = [integralImage[x-1][y] doubleValue];
					for (int i = 0; i <= y; i++)
						total += [currentImageArray[x][i] doubleValue];
					integralImage[x][y] = [NSNumber numberWithDouble: total];
				} else {
					double total = [integralImage[x][y-1] doubleValue];
					for (int i = 0; i <= x; i++)
						total += [currentImageArray[i][y] doubleValue];
					integralImage[x][y] = [NSNumber numberWithDouble: total];
				}
			}
			
			// update video feed according to user's preference
			if ([_showVideoCheckBox state] == 1 && [_showOnlyPositivesCheckBox state] == 0)
				[_imageView setImage:[imageRep CGImage] imageProperties:nil];
		}
		
		// multi-thread the classifiers
		NSThread* threadA = [[NSThread alloc] initWithTarget:self selector:@selector(inputAClassify) object:nil];
//		NSThread* threadB = [[NSThread alloc] initWithTarget:self selector:@selector(inputBClassify) object:nil];
		[threadA start];
//		[threadB start];
		
		// wait for the classifiers to finish classifying
		while (![threadA isFinished])// || ![threadB isFinished])
			[NSThread sleepForTimeInterval:0.005];
		
		// figure out which classifier produced the most positive subwindows
		// although less accurate using subwindows makes up by being much faster
		int totalPositivesForA = 0;
		NSMutableArray* positives = [[NSMutableArray alloc] initWithCapacity:[image size].width];
		for (int i = 0; i < [image size].width; i++)
			positives[i] = [[NSMutableArray alloc] initWithCapacity:[image size].height];
		for (int i = 0; i < [image size].width; i++)
		for (int j = 0; j < [image size].height; j++)
			positives[i][j] = [NSNumber numberWithInt: 0];
		for (int x = 0; x < [inputAClassifications count]; x++)
		for (int y = 0; y < [inputAClassifications[0] count]; y++)
			if (inputAClassifications[x][y] == [NSNumber numberWithBool:YES]){
				totalPositivesForA++;
				
				if ([_showOnlyPositivesCheckBox state] == 1 && [_showVideoCheckBox state] == 1){
					int startI = x * widthBetweenSubwindows;
					int startJ = y * heightBetweenSubwindows;
					
					for (int i = startI; i < startI + HaarFeature.width; i++)
					for (int j = startJ; j < startJ + HaarFeature.height; j++)
						positives[i][j] = [NSNumber numberWithInt:1];
				}
			}
//		int totalPositivesForB = 0;
//		for (int x = 0; x < [inputBClassifications count]; x++)
//		for (int y = 0; y < [inputBClassifications[x] count]; y++)
//			if (inputBClassifications[x][y] == [[NSNumber alloc] initWithBool:YES])
//				totalPositivesForB++;
		
		if ([_showOnlyPositivesCheckBox state] == 1 && [_showVideoCheckBox state] == 1){
			NSBitmapImageRep* rep = [[NSBitmapImageRep alloc] initWithCGImage:[image CGImageForProposedRect:&rect context:[NSGraphicsContext currentContext] hints:nil]];
			
			NSColor* BLACK = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:1];
			for (int x = 0; x < [positives count]; x++)
			for (int y = 0; y < [positives[0] count]; y++)
				if (positives[x][y] == [NSNumber numberWithInt:0])
					[rep setColor:BLACK atX:x y:y];
			
			[_imageView setImage:[rep CGImage] imageProperties:nil];
		}
		
		// change text accordingly
		NSString* text = [_textField stringValue];
		if (totalPositivesForA > (1 - [_maxDistanceSlider doubleValue]) * [_subwindowsSlider intValue])
			text = [text stringByAppendingString:@"A"];
//		if (totalPositivesForA > totalPositivesForB)
//			text = [text stringByAppendingString:@"A"];
//		else if (totalPositivesForB > totalPositivesForA)
//			text = [text stringByAppendingString:@"B"];
		_textField.stringValue = text;
		
		firstIteration = NO;
	}
}


- (void)inputAClassify {
	[NSThread setThreadPriority:1.0];
	
	@synchronized(self){
		inputAClassifications = [inputAClassifier classify:integralImage : [_subwindowsSlider intValue]];
	}
	
	[NSThread exit];
}


- (void)inputBClassify {
	[NSThread setThreadPriority:1.0];
	
	@synchronized(self){
		inputBClassifications = [inputBClassifier classify:integralImage : [_subwindowsSlider intValue]];
	}
	
	[NSThread exit];
}

@end

//
//  AppDelegate.m
//  Background Subtracted Picture Taker
//
//  Created by Bryan Herman on 3/17/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	paused = false;
	[NSThread detachNewThreadSelector:@selector(process) toTarget:self withObject:nil];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Bryan-Herman.Background_Subtracted_Picture_Taker" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"Bryan-Herman.Background_Subtracted_Picture_Taker"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Background_Subtracted_Picture_Taker" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Background_Subtracted_Picture_Taker.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
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
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
		
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
		
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
	
    return NSTerminateNow;
}


- (IBAction)takePicture:(id)sender {
	paused = true;
	NSImage* imageToSave = image;
	NSSavePanel* savePanel = [NSSavePanel savePanel];
	[savePanel setCanSelectHiddenExtension:YES];
	[savePanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result){
		if (result == NSFileHandlingPanelOKButton)
			[Snapshot saveImage:imageToSave toPath:[[savePanel URL] path]];
	}];
	paused = false;
}


- (void)process {
	Snapshot* camera = [[Snapshot alloc] init];
	
	image = [camera snapshot];
	
	// initialize reference image array
	referenceImage = [[NSMutableArray alloc] initWithCapacity:[image size].width];
	for (int x = 0; x < [image size].width; x++)
		referenceImage[x] = [[NSMutableArray alloc] initWithCapacity:[image size].height];
	
	BOOL firstIteration = YES;
	
	// declare these outside of loop to avoid wasting time on malloc
	NSImage* tempImage;
	NSRect rect;
	rect.origin.x = 0;
	rect.origin.y = 0;
	rect.size = image.size;
	NSColor* color;
	NSBitmapImageRep* imageRep;
	
	while (YES){
		@synchronized(self){
			if (!paused){
				tempImage = [camera snapshot];
				
				// get the image representation
				imageRep = [[NSBitmapImageRep alloc] initWithCGImage:[tempImage CGImageForProposedRect:&rect context:[NSGraphicsContext currentContext] hints:nil]];
				
				for (int x = 0; x < [tempImage size].width; x++)
				for (int y = 0; y < [tempImage size].height; y++){
					color = [imageRep colorAtX:x y:y];
					double grayscale = ([color redComponent] + [color greenComponent] + [color blueComponent]) / 3;
					
					// update the reference image
					if (firstIteration)
						referenceImage[x][y] = [[NSNumber alloc] initWithDouble: grayscale];
					else if (grayscale < [referenceImage[x][y] doubleValue])
						referenceImage[x][y] = [[NSNumber alloc] initWithDouble:[referenceImage[x][y] doubleValue] - [_updateSlider intValue]/256.0];
					else if (grayscale > [referenceImage[x][y] doubleValue])
						referenceImage[x][y] = [[NSNumber alloc] initWithDouble:[referenceImage[x][y] doubleValue] + [_updateSlider intValue]/256.0];
					
					// use frame difference to determine if the current pixel is in the
					// foreground or background
					if (fabs(grayscale - [referenceImage[x][y] doubleValue]) >= [_thresholdSlider intValue] / 256.0)
						color = [NSColor colorWithDeviceRed:grayscale green:grayscale blue:grayscale alpha:1];
					else
						color = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:1];
					
					[imageRep setColor:color atX:x y:y];
				}
				
				image = [[NSImage alloc] initWithCGImage:[imageRep CGImage] size:tempImage.size];
				
				[_imageView setImage:[imageRep CGImage] imageProperties:nil];
				
				firstIteration = NO;
			}
		}
	}
}

@end

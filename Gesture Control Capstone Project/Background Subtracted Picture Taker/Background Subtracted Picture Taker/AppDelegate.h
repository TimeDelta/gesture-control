//
//  AppDelegate.h
//  Background Subtracted Picture Taker
//
//  Created by Bryan Herman on 3/17/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "Snapshot.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
	NSMutableArray* referenceImage;
	NSImage* image;
	
	BOOL paused;
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak) IBOutlet IKImageView* imageView;
@property (weak) IBOutlet NSSlider* thresholdSlider;
@property (weak) IBOutlet NSSlider* updateSlider;

- (IBAction)takePicture:(id)sender;
- (void)process;

@end

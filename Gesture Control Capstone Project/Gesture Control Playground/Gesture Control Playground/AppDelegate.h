//
//  AppDelegate.h
//  Gesture Control Playground
//
//  Created by Bryan Herman on 3/7/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <QTKit/QTKit.h>
#import "CascadeClassifier.h"
#import "Snapshot.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
	CascadeClassifier* inputAClassifier;
	CascadeClassifier* inputBClassifier;
	
	NSMutableArray* inputAClassifications;
	NSMutableArray* inputBClassifications;
	
	NSMutableArray* referenceImage;
	NSMutableArray* integralImage;
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak) IBOutlet NSTextField* textField;
@property (weak) IBOutlet IKImageView* imageView;
@property (weak) IBOutlet NSSlider* subwindowsSlider;
@property (weak) IBOutlet NSSlider* thresholdSlider;
@property (weak) IBOutlet NSSlider* updateSlider;
@property (weak) IBOutlet NSSlider* maxDistanceSlider;
@property (weak) IBOutlet NSButton* showVideoCheckBox;
@property (weak) IBOutlet NSButton* showOnlyPositivesCheckBox;

- (void)startProcessingInput;
- (void)inputAClassify;
- (void)inputBClassify;

@end

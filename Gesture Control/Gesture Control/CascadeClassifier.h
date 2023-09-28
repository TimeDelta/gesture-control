//
//  CascadeClassifier.h
//  Gesture Control
//
//  Created by Bryan Herman on 2/3/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassifierStage.h"

@interface CascadeClassifier : NSObject<NSCoding> {
	NSMutableArray* stages;
}

- (id)init;
- (void)addStage: (ClassifierStage*)stage;
- (void)removeLastStage;
- (NSMutableArray*)classify: (NSMutableArray*)integralImageSums : (int)subwindows;

@end

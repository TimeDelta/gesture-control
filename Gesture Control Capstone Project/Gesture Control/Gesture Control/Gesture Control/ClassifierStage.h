//
//  ClassifierStage.h
//  Gesture Control
//
//  Created by Bryan Herman on 2/14/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HaarFeature.h"

@interface ClassifierStage : NSObject {
	NSMutableArray* haarFeatures;
	double threshold;
}

- (id) init;
- (void) addFeature: (HaarFeature*)feature;
- (BOOL) classify: (NSMutableArray*)integralImageSums : (NSPoint)origin;

@end

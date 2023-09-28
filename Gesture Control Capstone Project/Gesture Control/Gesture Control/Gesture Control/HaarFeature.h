//
//  HaarFeature.h
//  Gesture Control
//
//  Created by Bryan Herman on 2/3/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Region.h"

@interface HaarFeature : NSObject<NSCoding> {
	NSMutableArray* blackRegions;
	NSMutableArray* whiteRegions;
}

@property (readwrite) int threshold;
@property (readwrite) BOOL useGreaterThanThreshold;
@property (readwrite) double weight;

- (id) init: (CGImageRef)image;
- (id) cloneInit: (NSMutableArray*)black : (NSMutableArray*)white;
- (id) clone;
- (BOOL) classify: (NSMutableArray*)integralImageSums
			   at: (NSPoint)origin;

+ (int) width;
+ (int) height;

@end

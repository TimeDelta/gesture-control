//
//  Region.h
//  Gesture Control
//
//  Created by Bryan Herman on 2/4/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Region : NSObject<NSCoding>

@property (readonly) NSPoint a;
@property (readonly) NSPoint b;
@property (readonly) NSPoint c;
@property (readonly) NSPoint d;

- (id) init: (NSPoint)A : (NSPoint)B : (NSPoint)C : (NSPoint)D;
- (double) value: (NSMutableArray*)integralImageSums : (int)xOffset : (int)yOffset;

@end

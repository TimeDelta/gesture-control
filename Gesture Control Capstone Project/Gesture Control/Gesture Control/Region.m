//
//  Region.m
//  Gesture Control
//
//  Created by Bryan Herman on 2/4/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#ifndef REGION
#define REGION

#import "Region.h"

@implementation Region

@synthesize a;
@synthesize b;
@synthesize c;
@synthesize d;

// By convention:
// A*****B
// *******
// C*****D
- (id) init: (NSPoint)A : (NSPoint)B : (NSPoint)C : (NSPoint)D {
	self = [super init];
	
	a = A;
	b = B;
	c = C;
	d = D;
	
	return self;
}


// Unarchiver
- (id) initWithCoder: (NSCoder*)decoder {
	self = [super init];
	
	a = [decoder decodePointForKey: @"a"];
	b = [decoder decodePointForKey: @"b"];
	c = [decoder decodePointForKey: @"c"];
	d = [decoder decodePointForKey: @"d"];
	
	return self;
}


// Archiver
- (void) encodeWithCoder: (NSCoder*)encoder {
	[encoder encodePoint:a forKey:@"a"];
	[encoder encodePoint:b forKey:@"b"];
	[encoder encodePoint:c forKey:@"c"];
	[encoder encodePoint:d forKey:@"d"];
}


// Get the sum of all pixel values within this region.
- (double) value: (NSMutableArray*)integralImageSums : (int)xOffset : (int)yOffset {
	double p1 = [integralImageSums[(int)(a.x + xOffset)][(int)(a.y + yOffset)] doubleValue];
	double p2 = [integralImageSums[(int)(b.x + xOffset)][(int)(b.y + yOffset)] doubleValue];
	double p3 = [integralImageSums[(int)(c.x + xOffset)][(int)(c.y + yOffset)] doubleValue];
	double p4 = [integralImageSums[(int)(d.x + xOffset)][(int)(d.y + yOffset)] doubleValue];
	
	// single column
	// *  *
	// *(1,1)(1,1)
	// *  *
	// *  *
	// *(1,4)(1,4)
	if (a.x == d.x){
		p1 = 0;
		if (a.x > 0){
			if (a.y > 0){
				p2 = [integralImageSums[(int)(a.x + xOffset)][(int)(a.y + yOffset - 1)] doubleValue];
				p3 = [integralImageSums[(int)(d.x + xOffset - 1)][(int)(d.y + yOffset)] doubleValue];
			} else {
				p2 = 0;
				p3 = [integralImageSums[(int)(d.x + xOffset - 1)][(int)(d.y + yOffset)] doubleValue];
			}
		} else {
			p3 = 0;
			if (a.y > 0)
				p2 = [integralImageSums[(int)(a.x + xOffset)][(int)(a.y + yOffset - 1)] doubleValue];
			else
				p2 = 0;
		}
	}
	
	// single row
	// *  *  *******  *
	// *(1,1)*******(9,1)
	// *(1,1)       (9,1)
	else if (a.y == d.y){
		p1 = 0;
		if (a.x > 0){
			if (a.y > 0){
				p2 = [integralImageSums[(int)(d.x + xOffset)][(int)(d.y + yOffset - 1)] doubleValue];
				p3 = [integralImageSums[(int)(a.x + xOffset - 1)][(int)(a.y + yOffset)] doubleValue];
			} else {
				p2 = 0;
				p3 = [integralImageSums[(int)(a.x + xOffset - 1)][(int)(a.y + yOffset)] doubleValue];
			}
		} else {
			p3 = 0;
			if (a.y > 0)
				p2 = [integralImageSums[(int)(d.x + xOffset)][(int)(d.y + yOffset - 1)] doubleValue];
			else
				p2 = 0;
		}
	}
	
	return p1 + p4 - p2 - p3;
}

@end

#endif

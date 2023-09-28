//
//  HaarFeature.m
//  Gesture Control
//
//  Created by Bryan Herman on 2/3/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#ifndef HAAR_FEATURE
#define HAAR_FEATURE

#import "HaarFeature.h"

@implementation HaarFeature

@synthesize threshold;
@synthesize useGreaterThanThreshold;
@synthesize weight;

- (id) init: (CGImageRef)image {
	self = [super init];
	
	whiteRegions = [[NSMutableArray alloc] init];
	blackRegions = [[NSMutableArray alloc] init];
	
	BOOL pixelUnused[HaarFeature.width][HaarFeature.height];
	for (int x = 0; x < HaarFeature.width; x++)
	for (int y = 0; y < HaarFeature.height; y++)
		pixelUnused[x][y] = YES;
	
	NSBitmapImageRep* imageRep = [[NSBitmapImageRep alloc] initWithCGImage: image];
	
	for (int y = 0; y < HaarFeature.height; y++)
		for (int x = 0; x < HaarFeature.width; x++){
			// skip over pixels that have already been used
			BOOL done = NO;
			while (!pixelUnused[x][y]){
				x++;
				if (x == HaarFeature.width){
					done = YES;
					break;
				}
			}
			if (done)// if there are no more unused pixels in the current row
				continue;
			
			int startingX = x;
			
			// find the highest x value that produces a contiguous row of pixels
			// with the same color as the first pixel checked
			BOOL firstPixelIsBlack = [self isBlack: imageRep : x : y];
			while (x + 1 < HaarFeature.width && pixelUnused[x][y] && firstPixelIsBlack == [self isBlack: imageRep : x + 1 : y]){
				pixelUnused[x][y] = NO;
				x++;
			}
			
			// find the highest y value that produces a rectangle of same-colored
			// pixels with width of the first contiguous row
			int tempY = y;
			for (; tempY < HaarFeature.height; tempY++){
				BOOL nextRowIsSame = YES;
				for (int tempX = startingX; tempX <= x && pixelUnused[tempX][tempY]; tempX++)
					if (firstPixelIsBlack != [self isBlack: imageRep : tempX : tempY]){
						nextRowIsSame = NO;
						break;
					}
				if (!nextRowIsSame)
					break;
				
				// mark pixels as used
				for (int tempX = startingX; tempX <= x; tempX++)
					pixelUnused[tempX][tempY] = NO;
			}
			
			// create the region and add it to the appropriate array
			NSPoint a;
			a.x = startingX;
			a.y = y;
			NSPoint b;
			b.x = x;
			b.y = y;
			NSPoint c;
			c.x = startingX;
			c.y = tempY - 1;
			NSPoint d;
			d.x = x;
			d.y = tempY - 1;
			Region* region = [[Region alloc] init: a : b : c : d];
			if (firstPixelIsBlack)
				[blackRegions addObject: region];
			else
				[whiteRegions addObject: region];
		}
	
	return self;
}


// Unarchiver
- (id) initWithCoder: (NSCoder*)decoder {
	self = [super init];
	
	threshold =					[decoder decodeDoubleForKey: @"threshold"];
	useGreaterThanThreshold =	[decoder decodeBoolForKey:@"useGreaterThanThreshold"];
	blackRegions =				[[decoder decodeObjectForKey:@"blackRegions"] mutableCopy];
	whiteRegions =				[[decoder decodeObjectForKey:@"whiteRegions"] mutableCopy];
	weight =					[decoder decodeDoubleForKey:@"weight"];
	
	return self;
}


// Archiver
- (void) encodeWithCoder: (NSCoder*)encoder {
	[encoder encodeDouble:threshold forKey:@"threshold"];
	[encoder encodeBool:useGreaterThanThreshold forKey:@"useGreaterThanThreshold"];
	[encoder encodeObject:blackRegions forKey:@"blackRegions"];
	[encoder encodeObject:whiteRegions forKey:@"whiteRegions"];
	[encoder encodeDouble:weight forKey:@"weight"];
}


// Clone Initializer
- (id) cloneInit: (NSMutableArray*)black : (NSMutableArray*)white {
	blackRegions = black;
	whiteRegions = white;
	return self;
}


// Clone this HaarFeature.
- (id) clone {
	HaarFeature* clone = [[HaarFeature alloc] cloneInit: blackRegions : whiteRegions];
	clone.threshold = threshold;
	clone.useGreaterThanThreshold = useGreaterThanThreshold;
	clone.weight = weight;
	return clone;
}


// Is the specified pixel black?
- (BOOL) isBlack: (NSBitmapImageRep*)imageRep : (int)x : (int)y {
	NSColor* color = [imageRep colorAtX:x y:y];
	return ([color redComponent] == 0 && [color blueComponent] == 0 && [color greenComponent] == 0);
}


// Classify based on the difference between the pixels in the black regions and
// the pixels in the white regions.
- (BOOL) classify: (NSMutableArray*)integralImageSums
			   at: (NSPoint)origin {
	double blackTotal = 0;
	for (Region* region in blackRegions)
		blackTotal += [region value: integralImageSums : origin.x : origin.y];
	
	double whiteTotal = 0;
	for (Region* region in whiteRegions)
		whiteTotal += [region value: integralImageSums : origin.x : origin.y];
	
	if (useGreaterThanThreshold && abs(blackTotal - whiteTotal) > threshold)
		return YES;
	if (!useGreaterThanThreshold && abs(blackTotal - whiteTotal) < threshold)
		return YES;
	return NO;
}


+ (int) width {
	return 24;
}


+ (int) height {
	return 24;
}

@end

#endif

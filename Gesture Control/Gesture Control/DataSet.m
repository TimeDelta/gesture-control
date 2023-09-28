//
//  DataSet.m
//  Gesture Control
//
//  Created by Bryan Herman on 12/6/12.
//  Copyright (c) 2012 Bryan Herman. All rights reserved.
//
//  A class that is used to hold the information about the data set.
//

#ifndef DATA_SET
#define DATA_SET

#import "DataSet.h"

@implementation DataSet

@synthesize input;
@synthesize ideal;


// Construct an empty data set. This is used for splitting up a data set.
- (id) init {
	self = [super init];
	
	input = [[NSMutableArray alloc] initWithCapacity: 0];
	ideal = [[NSMutableArray alloc] initWithCapacity: 0];
	
	return self;
}


// Unarchiver
- (id) initWithCoder: (NSCoder*)decoder {
	self = [super init];
	
	input = [decoder decodeObjectForKey:@"input"];
	ideal = [decoder decodeObjectForKey:@"ideal"];
	
	return self;
}


// Archiver
- (void) encodeWithCoder: (NSCoder*)encoder {
	[encoder encodeObject:input forKey:@"input"];
	[encoder encodeObject:ideal forKey:@"ideal"];
}


// Add a new case to the data set.
- (void) addCase: (NSMutableArray*)addInput : (NSMutableArray*)addIdeal {
	[input addObject : addInput];
	[ideal addObject : addIdeal];
}


// Input size.
- (int) inputSize {
	return [input[0] count];
}


// Get the size of this data set.
- (int) size {
	return [ideal count];
}

@end

#endif

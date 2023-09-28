//
//  LongDouble.m
//  Gesture Control
//
//  Created by Bryan Herman on 2/18/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import "LongDouble.h"

@implementation LongDouble

@synthesize value;

-(id)init: (long double)initialValue {
	self = [super init];
	value = initialValue;
	return self;
}


-(long double)longDoubleValue {
	return value;
}


-(void)setValue: (long double)newValue {
	value = newValue;
}


-(LongDouble*)clone {
	return [[LongDouble alloc] init:value];
}

@end

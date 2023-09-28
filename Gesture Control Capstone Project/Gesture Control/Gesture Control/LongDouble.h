//
//  LongDouble.h
//  Gesture Control
//
//  Created by Bryan Herman on 2/18/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LongDouble : NSObject

@property (readwrite) long double value;

-(id)init: (long double)initialValue;
-(long double)longDoubleValue;
-(void)setValue: (long double)newValue;

@end

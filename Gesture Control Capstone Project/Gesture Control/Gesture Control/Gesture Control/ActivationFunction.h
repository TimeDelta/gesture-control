//
//  ActivationFunction.h
//  Gesture Control
//
//  Created by Bryan Herman on 12/7/12.
//  Copyright (c) 2012 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ActivationFunction

@required
- (double) activation: (double)input;
- (double) derivative: (double)input;

@end

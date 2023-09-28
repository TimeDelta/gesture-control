//
//  DataSet.h
//  Gesture Control
//
//  Created by Bryan Herman on 12/6/12.
//  Copyright (c) 2012 Bryan Herman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSet : NSObject<NSCoding>

@property (readonly) NSMutableArray* input;
@property (readonly) NSMutableArray* ideal;

- (id) init;
- (void) addCase: (NSMutableArray*)addInput : (NSMutableArray*)addIdeal;
- (int) inputSize;
- (int) size;

@end

//
//  Snapshot.h
//  Background Subtracted Picture Taker
//
//  Created by Bryan Herman on 3/17/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/QuartzCore.h>

#define error(...) fprintf(stderr, __VA_ARGS__)

@interface Snapshot : NSObject {
    QTCaptureSession* session;
    QTCaptureDeviceInput* input;
    QTCaptureDecompressedVideoOutput* output;
    CVImageBufferRef imageBuffer;
}

+ (BOOL)saveImage:(NSImage*)image toPath:(NSString*)path;
+ (NSData*)dataFrom:(NSImage*)image asType:(NSString*)format;

-(id)init;
-(NSImage*)snapshot;

@end

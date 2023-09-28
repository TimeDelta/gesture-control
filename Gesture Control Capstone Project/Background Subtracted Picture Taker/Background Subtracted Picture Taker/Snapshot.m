//
//  Snapshot.m
//  Background Subtracted Picture Taker
//
//  Created by Bryan Herman on 3/17/13.
//  Copyright (c) 2013 Bryan Herman. All rights reserved.
//

#import "Snapshot.h"

@implementation Snapshot

- (id)init{
	self = [super init];
	
	// prepare capture device
	QTCaptureDevice* device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
	[device open:nil];
	
	// capture device input
	input = [[QTCaptureDeviceInput alloc] initWithDevice:device];
	
	// decompressed video output
	output = [[QTCaptureDecompressedVideoOutput alloc] init];
	[output setDelegate:self];
	[output setPixelBufferAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
															   [NSNumber numberWithDouble:320.0], (id)kCVPixelBufferWidthKey,
															   [NSNumber numberWithDouble:240.0], (id)kCVPixelBufferHeightKey,
															   [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB], (id)kCVPixelBufferPixelFormatTypeKey,
															   nil]];
	
	// capture session
	session = [[QTCaptureSession alloc] init];
	[session addInput:input error:nil];
	[session addOutput:output error:nil];
	
	imageBuffer = nil;
	return self;
}


+ (BOOL) saveImage:(NSImage *)image toPath: (NSString*)path{
	NSString *ext = [path pathExtension];
	NSData *photoData = [Snapshot dataFrom:image asType:ext];
	
	// If path is a dash, that means write to standard out
	if( path == nil || [@"-" isEqualToString:path] ){
		NSUInteger length = [photoData length];
		NSUInteger i;
		char *start = (char *)[photoData bytes];
		for( i = 0; i < length; ++i )
			putc( start[i], stdout );
		return YES;
	} else
		return [photoData writeToFile:path atomically:NO];
	
	return NO;
}


+(NSData *)dataFrom:(NSImage *)image asType:(NSString *)format{
	
	NSData *tiffData = [image TIFFRepresentation];
	
	NSBitmapImageFileType imageType = NSJPEGFileType;
	NSDictionary *imageProps = nil;
	
	
	// TIFF. Special case. Can save immediately.
	if( [@"tif"  rangeOfString:format options:NSCaseInsensitiveSearch].location != NSNotFound ||
	   [@"tiff" rangeOfString:format options:NSCaseInsensitiveSearch].location != NSNotFound )
		return tiffData;
	
	// JPEG
	else if( [@"jpg"  rangeOfString:format options:NSCaseInsensitiveSearch].location != NSNotFound || 
			[@"jpeg" rangeOfString:format options:NSCaseInsensitiveSearch].location != NSNotFound ){
		imageType = NSJPEGFileType;
		imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.9] forKey:NSImageCompressionFactor];
	}
	
	// PNG
	else if( [@"png" rangeOfString:format options:NSCaseInsensitiveSearch].location != NSNotFound )
		imageType = NSPNGFileType;
	
	// BMP
	else if( [@"bmp" rangeOfString:format options:NSCaseInsensitiveSearch].location != NSNotFound )
		imageType = NSBMPFileType;
	
	// GIF
	else if( [@"gif" rangeOfString:format options:NSCaseInsensitiveSearch].location != NSNotFound )
		imageType = NSGIFFileType;
	
	NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:tiffData];
	NSData *photoData = [imageRep representationUsingType:imageType properties:imageProps];
	
	return photoData;
}


-(NSImage *)snapshot{
	CVImageBufferRef frame = nil;
	
	// start capturing images
	[session startRunning];
	
	while( frame == nil ){
		// capture is on another thread
		@synchronized(self){
			frame = imageBuffer;
			CVBufferRetain(frame);
		}
	}
	
	// stop capturing images
	[session stopRunning];
	
	// convert frame to an NSImage
	NSCIImageRep *imageRep = [NSCIImageRep imageRepWithCIImage:[CIImage imageWithCVImageBuffer:frame options: nil]];
	NSImage *image = [[NSImage alloc] initWithSize:[imageRep size]];
	[image addRepresentation:imageRep];
	
	// clear old image
	@synchronized(self){
		CVBufferRelease(imageBuffer);
		imageBuffer = nil;
	}
	
	return image;
}


// This delegate method is called whenever the QTCaptureDecompressedVideoOutput
// receives a frame.
- (void)captureOutput:(QTCaptureOutput *)captureOutput 
  didOutputVideoFrame:(CVImageBufferRef)videoFrame 
	 withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
	   fromConnection:(QTCaptureConnection *)connection
{
	if (videoFrame == nil)
		return;
	
	// replace old frame with new one
	CVImageBufferRef imageBufferToRelease;
	CVBufferRetain(videoFrame);
	@synchronized(self){
		imageBufferToRelease = imageBuffer;
		imageBuffer = videoFrame;
	}
	CVBufferRelease(imageBufferToRelease);
}

@end

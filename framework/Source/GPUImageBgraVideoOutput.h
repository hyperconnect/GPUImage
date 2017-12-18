//
//  GPUImageBgraVideoOutput.h
//  AzarModel
//
//  Created by Garry on 2016. 11. 30..
//  Copyright © 2016년 Hyperconnect. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <GPUImage/GPUImageFramework.h>

#ifndef GPUImageBgraVideoOutput_h
#define GPUImageBgraVideoOutput_h

NS_ASSUME_NONNULL_BEGIN

@protocol GPUImageBgraVideoOutputDelegate <NSObject>
@optional
- (AVCaptureDevicePosition)getCameraPosition;
@end

/**
 A GPUImageOutput that provides frames from either camera
 */
@interface GPUImageBgraVideoOutput : GPUImageOutput { }

/// This enables the benchmarking mode, which logs out instantaneous and average frame times to the console
@property(readwrite, nonatomic) BOOL runBenchmark;

/// This determines the rotation applied to the output image, based on the source material
@property(readwrite, nonatomic) UIInterfaceOrientation outputImageOrientation;

/// These properties determine whether or not the two camera orientations should be mirrored. By default, both are NO.
@property(readwrite, nonatomic) BOOL horizontallyMirrorFrontFacingCamera;

/// These properties determine whether or not the two camera orientations should be mirrored. By default, both are NO.
@property(readwrite, nonatomic) BOOL horizontallyMirrorBackFacingCamera;

@property(weak, nonatomic) id<GPUImageBgraVideoOutputDelegate> delegate;

/// @name Benchmarking

/** When benchmarking is enabled, this will keep a running average of the time from uploading, processing, and final recording or display
 */
- (CGFloat)averageFrameDurationDuringCapture;

- (void)resetBenchmarkAverage;

- (void)pauseCameraCapture;
- (void)resumeCameraCapture;

- (void)incomingPixelBuffer:(nullable CVPixelBufferRef)imageBuffer
                   rotation:(int)rotation
                      width:(size_t)width
                     height:(size_t)height
                     yPlane:(nullable const uint8_t *)yPlane
                     uPlane:(nullable const uint8_t *)uPlane
                     vPlane:(nullable const uint8_t *)vPlane;

- (void)incomingSampleBuffer:(CMSampleBufferRef)sampleBuffer
                  targetSize:(CGSize)targetSize;
- (void)clearScreen:(BOOL)asynchronous;

- (void)updateOrientationSendToTargets;

@end

NS_ASSUME_NONNULL_END

#endif /* GPUImageBgraVideoOutput_h */

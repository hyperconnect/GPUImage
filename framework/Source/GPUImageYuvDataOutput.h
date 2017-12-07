#import <Foundation/Foundation.h>
#import <GPUImage/GPUImageFramework.h>

@interface GPUImageYuvDataOutput : NSObject <GPUImageInput> { }

// rawBytesForImage(Y|UV)Plane must be accessed between
// lockFramebufferForReading and unlockFramebufferAfterReading
@property(readonly) GLubyte *rawBytesForImageYPlane;
@property(readonly) GLubyte *rawBytesForImageUVPlane;
@property(readonly) NSUInteger bufferSize;

@property(nonatomic, copy) void(^newFrameAvailableBlock)(void);
@property(nonatomic) BOOL enabled;

// Initialization and teardown
- (id)initWithImageSize:(CGSize)newImageSize;

// Data access (only valid after accessing rawBytesForImage(Y|UV)Plane)
- (NSUInteger)bytesPerRowInYPlane;
- (NSUInteger)bytesPerRowInUVPlane;

- (void)lockFramebufferForReading;
- (void)unlockFramebufferAfterReading;

@end

//
//  GPUImageBgraVideoOutput.m
//  AzarModel
//
//  Created by Garry on 2016. 11. 30..
//  Copyright © 2016년 Hyperconnect. All rights reserved.
//

#import "GPUImageBgraVideoOutput.h"

void _check_gl_error(const char *file, int line);

///
/// Usage
/// [... some opengl calls]
/// glCheckError();
///
#define check_gl_error() _check_gl_error(__FILE__,__LINE__)

void _check_gl_error(const char *file, int line) {
    GLenum err  = glGetError();

    while(err!=GL_NO_ERROR) {
        NSString* error;

        switch(err) {
            case GL_INVALID_OPERATION:      error=@"INVALID_OPERATION";      break;
            case GL_INVALID_ENUM:           error=@"INVALID_ENUM";           break;
            case GL_INVALID_VALUE:          error=@"INVALID_VALUE";          break;
            case GL_OUT_OF_MEMORY:          error=@"OUT_OF_MEMORY";          break;
            case GL_INVALID_FRAMEBUFFER_OPERATION:  error=@"INVALID_FRAMEBUFFER_OPERATION";  break;
        }

        NSLog(@"GL_%@ - %s:%d", error, file, line);
        err= glGetError();
    }
}

// BT.601, which is the standard for SDTV.
const GLfloat kColorConversionMat601[] = {
    1.164,  1.164, 1.164,
    0.0, -0.392, 2.017,
    1.596, -0.813,   0.0,
};

// BT.709, which is the standard for HDTV.
const GLfloat kColorConversionMat709[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

// BT.601 full range (ref: http://www.equasys.de/colorconversion.html)
const GLfloat kColorConversionMat601FullRange[] = {
    1.0,    1.0,    1.0,
    0.0,    -0.343, 1.765,
    1.4,    -0.711, 0.0,
};

const GLfloat squareVertices[] = {
    -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f,  1.0f,
    1.0f,  1.0f,
};

NSString *const kGPUImageYUVFullRangeConversionForRGFragmentShaderStr = SHADER_STRING
(
 varying highp vec2 textureCoordinate;

 uniform sampler2D luminanceTexture;
 uniform sampler2D chrominanceTexture;
 uniform mediump mat3 colorConversionMatrix;

 void main()
 {
     mediump vec3 yuv;
     lowp vec3 rgb;

     yuv.x = texture2D(luminanceTexture, textureCoordinate).r;
     yuv.yz = texture2D(chrominanceTexture, textureCoordinate).rg - vec2(0.5, 0.5);
     rgb = colorConversionMatrix * yuv;

     gl_FragColor = vec4(rgb, 1);
 }
 );

NSString *const kGPUImageYUVFullRangeConversionForLAFragmentShaderStr = SHADER_STRING
(
 varying highp vec2 textureCoordinate;

 uniform sampler2D luminanceTexture;
 uniform sampler2D chrominanceTexture;
 uniform mediump mat3 colorConversionMatrix;

 void main()
 {
     mediump vec3 yuv;
     lowp vec3 rgb;

     yuv.x = texture2D(luminanceTexture, textureCoordinate).r;
     yuv.yz = texture2D(chrominanceTexture, textureCoordinate).ra - vec2(0.5, 0.5);
     rgb = colorConversionMatrix * yuv;

     gl_FragColor = vec4(rgb, 1);
 }
 );

NSString *const kGPUImageYUVFullRangeConversionForI420FragmentShaderStr = SHADER_STRING
(
 varying highp vec2 textureCoordinate;

 uniform sampler2D yTexture;
 uniform sampler2D uTexture;
 uniform sampler2D vTexture;

 uniform mediump mat3 colorConversionMatrix;

 void main()
 {
     mediump vec3 yuv;
     lowp vec3 rgb;

     yuv.x = texture2D(yTexture, textureCoordinate).r;
     yuv.y = texture2D(uTexture, textureCoordinate).r - 0.5;
     yuv.z = texture2D(vTexture, textureCoordinate).r - 0.5;
     rgb = colorConversionMatrix * yuv;

     gl_FragColor = vec4(rgb, 1);
 }
 );

NSString *const kGPUImageBgraConversionFragmentShaderStr = SHADER_STRING
(
 varying highp vec2 textureCoordinate;

 uniform sampler2D bgraTexture;

 void main()
 {
     mediump vec3 rgb;

     rgb = texture2D(bgraTexture, textureCoordinate).bgr;

     gl_FragColor = vec4(rgb, 1);
 }
 );

#pragma mark -
#pragma mark Private methods and instance variables

@interface GPUImageBgraVideoOutput ()
{
    NSUInteger numberOfFramesCaptured;
    CGFloat totalFrameTimeDuringCapture;

    BOOL capturePaused;
    GPUImageRotationMode outputRotation, internalRotation;
    dispatch_semaphore_t frameRenderingSemaphore;


    NSDate *startingCaptureTime;

    dispatch_queue_t cameraProcessingQueue;

    // for CVImageBufferRef
    GLProgram *yuvConversionProgramNV12;
    GLuint luminanceTextureNV12, chrominanceTextureNV12;
    GLint yuvConversionPositionAttributeNV12, yuvConversionTextureCoordinateAttributeNV12;
    GLint yuvConversionLuminanceTextureUniformNV12, yuvConversionChrominanceTextureUniformNV12;
    GLint yuvConversionMatrixUniformNV12;

    // for I420
    GLProgram *yuvConversionProgramI420;
    GLuint texturesI420[3];
    GLint yuvConversionPositionAttributeI420, yuvConversionTextureCoordinateAttributeI420;
    GLint yuvConversionYTextureUniformI420, yuvConversionUTextureUniformI420, yuvConversionVTextureUniformI420;
    GLint yuvConversionMatrixUniformI420;

    // for BGRA
    GLProgram *bgraConversionProgram;
    GLuint bgraConversionTexture;
    GLint bgraConversionPositionAttribute;
    GLint bgraConversionTextureCoordinateAttribute;
    GLint bgraConversionTextureUniform;

    const GLfloat *_preferredConversion;

    int imageBufferWidth, imageBufferHeight;
}

- (void)convertYUVToRGBOutput;
- (void)convertBGRAToRGBOutput;

@end

@implementation GPUImageBgraVideoOutput

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }

    cameraProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);

    frameRenderingSemaphore = dispatch_semaphore_create(1);

    _runBenchmark = NO;
    capturePaused = NO;
    outputRotation = kGPUImageNoRotation;
    internalRotation = kGPUImageNoRotation;
    _preferredConversion = kColorConversion601FullRange;

    runSynchronouslyOnVideoProcessingQueue(^{

        [GPUImageContext useImageProcessingContext];

        yuvConversionProgramI420 = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageYUVFullRangeConversionForI420FragmentShaderStr];
        if (!yuvConversionProgramI420.initialized)
        {
            [yuvConversionProgramI420 addAttribute:@"position"];
            [yuvConversionProgramI420 addAttribute:@"inputTextureCoordinate"];

            if (![yuvConversionProgramI420 link])
            {
                NSString *progLog = [yuvConversionProgramI420 programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [yuvConversionProgramI420 fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [yuvConversionProgramI420 vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                yuvConversionProgramI420 = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }

        yuvConversionPositionAttributeI420 = [yuvConversionProgramI420 attributeIndex:@"position"];
        yuvConversionTextureCoordinateAttributeI420 = [yuvConversionProgramI420 attributeIndex:@"inputTextureCoordinate"];
        yuvConversionYTextureUniformI420 = [yuvConversionProgramI420 uniformIndex:@"yTexture"];
        yuvConversionUTextureUniformI420 = [yuvConversionProgramI420 uniformIndex:@"uTexture"];
        yuvConversionVTextureUniformI420 = [yuvConversionProgramI420 uniformIndex:@"vTexture"];
        yuvConversionMatrixUniformI420 = [yuvConversionProgramI420 uniformIndex:@"colorConversionMatrix"];

        glGenTextures(3, texturesI420);
        // Set parameters for each of the textures we created.
        for (GLsizei i = 0; i < 3; i++) {
            glActiveTexture(GL_TEXTURE4 + i);
            glBindTexture(GL_TEXTURE_2D, texturesI420[i]);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            check_gl_error();
        }

        if ([GPUImageContext deviceSupportsRedTextures])
        {
            yuvConversionProgramNV12 = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageYUVFullRangeConversionForRGFragmentShaderStr];
        }
        else
        {
            yuvConversionProgramNV12 = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageYUVFullRangeConversionForLAFragmentShaderStr];
        }

        if (!yuvConversionProgramNV12.initialized)
        {
            [yuvConversionProgramNV12 addAttribute:@"position"];
            [yuvConversionProgramNV12 addAttribute:@"inputTextureCoordinate"];

            if (![yuvConversionProgramNV12 link])
            {
                NSString *progLog = [yuvConversionProgramNV12 programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [yuvConversionProgramNV12 fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [yuvConversionProgramNV12 vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                yuvConversionProgramNV12 = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }

        yuvConversionPositionAttributeNV12 = [yuvConversionProgramNV12 attributeIndex:@"position"];
        yuvConversionTextureCoordinateAttributeNV12 = [yuvConversionProgramNV12 attributeIndex:@"inputTextureCoordinate"];
        yuvConversionLuminanceTextureUniformNV12 = [yuvConversionProgramNV12 uniformIndex:@"luminanceTexture"];
        yuvConversionChrominanceTextureUniformNV12 = [yuvConversionProgramNV12 uniformIndex:@"chrominanceTexture"];
        yuvConversionMatrixUniformNV12 = [yuvConversionProgramNV12 uniformIndex:@"colorConversionMatrix"];

        bgraConversionProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:
                                 kGPUImageBgraConversionFragmentShaderStr];

        if (!bgraConversionProgram.initialized)
        {
            [bgraConversionProgram addAttribute:@"position"];
            [bgraConversionProgram addAttribute:@"inputTextureCoordinate"];
            if (![bgraConversionProgram link])
            {
                NSString *progLog = [bgraConversionProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [bgraConversionProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [bgraConversionProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                bgraConversionProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        bgraConversionPositionAttribute = [bgraConversionProgram attributeIndex:@"position"];
        bgraConversionTextureCoordinateAttribute = [bgraConversionProgram attributeIndex:@"inputTextureCoordinate"];
        bgraConversionTextureUniform = [bgraConversionProgram uniformIndex:@"bgraTexture"];

        check_gl_error();

    });

    return self;
}

- (GPUImageFramebuffer *)framebufferForOutput;
{
    return outputFramebuffer;
}

- (void)dealloc
{
    glDeleteTextures(3, texturesI420);

    // ARC forbids explicit message send of 'release'; since iOS 6 even for dispatch_release() calls: stripping it out in that case is required.
#if !OS_OBJECT_USE_OBJC
    if (frameRenderingSemaphore != NULL)
    {
        dispatch_release(frameRenderingSemaphore);
    }
#endif
}

- (void)pauseCameraCapture;
{
    capturePaused = YES;
}

- (void)resumeCameraCapture;
{
    capturePaused = NO;
}


#pragma mark -
#pragma mark Managing targets

- (void)addTarget:(id<GPUImageInput>)newTarget atTextureLocation:(NSInteger)textureLocation;
{
    [super addTarget:newTarget atTextureLocation:textureLocation];

    [newTarget setInputRotation:outputRotation atIndex:textureLocation];
}

#define INITIALFRAMESTOIGNOREFORBENCHMARK 5

- (void)updateTargetsForVideoCameraUsingCacheTextureAtWidth:(int)bufferWidth height:(int)bufferHeight time:(CMTime)currentTime;
{
    // First, update all the framebuffers in the targets
    for (id<GPUImageInput> currentTarget in targets)
    {
        if ([currentTarget enabled])
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];

            if (currentTarget != self.targetToIgnoreForUpdates)
            {
                [currentTarget setInputRotation:outputRotation atIndex:textureIndexOfTarget];
                [currentTarget setInputSize:CGSizeMake(bufferWidth, bufferHeight) atIndex:textureIndexOfTarget];

                if ([currentTarget wantsMonochromeInput])
                {
                    [currentTarget setCurrentlyReceivingMonochromeInput:YES];
                    // TODO: Replace optimization for monochrome output
                    [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
                }
                else
                {
                    [currentTarget setCurrentlyReceivingMonochromeInput:NO];
                    [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
                }
            }
            else
            {
                [currentTarget setInputRotation:outputRotation atIndex:textureIndexOfTarget];
                [currentTarget setInputFramebuffer:outputFramebuffer atIndex:textureIndexOfTarget];
            }
        }
    }

    // Then release our hold on the local framebuffer to send it back to the cache as soon as it's no longer needed
    [outputFramebuffer unlock];
    outputFramebuffer = nil;

    // Finally, trigger rendering as needed
    for (id<GPUImageInput> currentTarget in targets)
    {
        if ([currentTarget enabled])
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndexOfTarget = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];

            if (currentTarget != self.targetToIgnoreForUpdates)
            {
                [currentTarget newFrameReadyAtTime:currentTime atIndex:textureIndexOfTarget];
            }
        }
    }
}

- (void)processVideoFrame:(nullable CVPixelBufferRef)imageBuffer
                 rotation:(int)rotation
                    width:(size_t)width
                   height:(size_t)height
                   yPlane:(nullable const uint8_t *)yPlane
                   uPlane:(nullable const uint8_t *)uPlane
                   vPlane:(nullable const uint8_t *)vPlane
{
    if (capturePaused)
    {
        return;
    }

    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    CVImageBufferRef cameraFrame = imageBuffer;

    // 안드로이드에서 필터를 적용하지 않으면 화면이 거꾸로 보입니다.
    if (rotation == 180) {
        outputRotation = kGPUImageRotate180;
    } else {
        outputRotation = kGPUImageNoRotation;
    }

    [GPUImageContext useImageProcessingContext];

    if (imageBuffer) {
        int bufferWidth = (int) CVPixelBufferGetWidth(cameraFrame);
        int bufferHeight = (int) CVPixelBufferGetHeight(cameraFrame);

        [GPUImageContext setActiveShaderProgram:yuvConversionProgramNV12];

        CVOpenGLESTextureRef luminanceTextureRef = NULL;
        CVOpenGLESTextureRef chrominanceTextureRef = NULL;

        if ( (imageBufferWidth != bufferWidth) && (imageBufferHeight != bufferHeight) )
        {
            imageBufferWidth = bufferWidth;
            imageBufferHeight = bufferHeight;
        }

        CVReturn err;
        // Y-plane
        glActiveTexture(GL_TEXTURE4);
        if ([GPUImageContext deviceSupportsRedTextures])
        {
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], cameraFrame, NULL, GL_TEXTURE_2D, GL_RED_EXT, bufferWidth, bufferHeight, GL_RED_EXT, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
        }
        else
        {
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], cameraFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
        }
        if (err)
        {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }

        luminanceTextureNV12 = CVOpenGLESTextureGetName(luminanceTextureRef);
        glBindTexture(GL_TEXTURE_2D, luminanceTextureNV12);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        // UV-plane
        glActiveTexture(GL_TEXTURE5);
        if ([GPUImageContext deviceSupportsRedTextures])
        {
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], cameraFrame, NULL, GL_TEXTURE_2D, GL_RG_EXT, bufferWidth/2, bufferHeight/2, GL_RG_EXT, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
        }
        else
        {
            err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], cameraFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth/2, bufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
        }
        if (err)
        {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }

        chrominanceTextureNV12 = CVOpenGLESTextureGetName(chrominanceTextureRef);
        glBindTexture(GL_TEXTURE_2D, chrominanceTextureNV12);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        [self convertYUVToRGBOutput];

        int rotatedImageBufferWidth = bufferWidth, rotatedImageBufferHeight = bufferHeight;

        if (GPUImageRotationSwapsWidthAndHeight(internalRotation))
        {
            rotatedImageBufferWidth = bufferHeight;
            rotatedImageBufferHeight = bufferWidth;
        }

        [self updateTargetsForVideoCameraUsingCacheTextureAtWidth:rotatedImageBufferWidth height:rotatedImageBufferHeight time:kCMTimeInvalid];

        CFRelease(luminanceTextureRef);
        CFRelease(chrominanceTextureRef);
        
    } else {
        assert(width <= INT_MAX);
        assert(height <= INT_MAX);
        assert(yPlane != NULL);
        assert(uPlane != NULL);
        assert(vPlane != NULL);

        int bufferWidth = (int)width;
        int bufferHeight = (int)height;

        [GPUImageContext setActiveShaderProgram:yuvConversionProgramI420];

        if ( (imageBufferWidth != bufferWidth) && (imageBufferHeight != bufferHeight) )
        {
            imageBufferWidth = bufferWidth;
            imageBufferHeight = bufferHeight;
        }

        // Y-plane
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, texturesI420[0]);
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_RED_EXT,
                     bufferWidth,
                     bufferHeight,
                     0,
                     GL_RED_EXT,
                     GL_UNSIGNED_BYTE,
                     yPlane);

        // U-plane
        glActiveTexture(GL_TEXTURE5);
        glBindTexture(GL_TEXTURE_2D, texturesI420[1]);
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_RED_EXT,
                     (bufferWidth + 1) / 2,
                     (bufferHeight + 1) / 2,
                     0,
                     GL_RED_EXT,
                     GL_UNSIGNED_BYTE,
                     uPlane);

        // V-plane
        glActiveTexture(GL_TEXTURE6);
        glBindTexture(GL_TEXTURE_2D, texturesI420[2]);
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_RED_EXT,
                     (bufferWidth + 1) / 2,
                     (bufferHeight + 1) / 2,
                     0,
                     GL_RED_EXT,
                     GL_UNSIGNED_BYTE,
                     vPlane);

        [self convertYUVToRGBOutputI420];

        int rotatedImageBufferWidth = bufferWidth, rotatedImageBufferHeight = bufferHeight;

        if (GPUImageRotationSwapsWidthAndHeight(internalRotation))
        {
            rotatedImageBufferWidth = bufferHeight;
            rotatedImageBufferHeight = bufferWidth;
        }

        [self updateTargetsForVideoCameraUsingCacheTextureAtWidth:rotatedImageBufferWidth height:rotatedImageBufferHeight time:kCMTimeInvalid];
    }

    if (_runBenchmark)
    {
        numberOfFramesCaptured++;
        if (numberOfFramesCaptured > INITIALFRAMESTOIGNOREFORBENCHMARK)
        {
            CFAbsoluteTime currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime);
            totalFrameTimeDuringCapture += currentFrameTime;
            NSLog(@"Average frame time : %f ms", [self averageFrameDurationDuringCapture]);
            NSLog(@"Current frame time : %f ms", 1000.0 * currentFrameTime);
        }
    }
}

- (void)processBlackFrame
{
    if (capturePaused)
    {
        return;
    }

    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    [GPUImageContext useImageProcessingContext];

    const int blankFrameWidth = 16;
    const int blankFrameHeight = 16;
    int yBufferSize = blankFrameWidth * blankFrameHeight;
    int uvBufferSize = ((blankFrameWidth+1)/2) * ((blankFrameHeight+1)/2);
    uint8_t buf_y[yBufferSize];
    for (int i = 0; i < yBufferSize; i++) {
        buf_y[i] = 0;
    }
    uint8_t buf_uv[uvBufferSize];
    for (int i = 0; i < uvBufferSize; i++) {
        buf_uv[i] = 128;
    }

    [GPUImageContext setActiveShaderProgram:yuvConversionProgramI420];

    // Y-plane
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, texturesI420[0]);
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RED_EXT,
                 blankFrameWidth,
                 blankFrameHeight,
                 0,
                 GL_RED_EXT,
                 GL_UNSIGNED_BYTE,
                 buf_y);

    // U-plane
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, texturesI420[1]);
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RED_EXT,
                 (blankFrameWidth+1)/2,
                 (blankFrameHeight+1)/2,
                 0,
                 GL_RED_EXT,
                 GL_UNSIGNED_BYTE,
                 buf_uv);

    // V-plane
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, texturesI420[2]);
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RED_EXT,
                 (blankFrameWidth+1)/2,
                 (blankFrameHeight+1)/2,
                 0,
                 GL_RED_EXT,
                 GL_UNSIGNED_BYTE,
                 buf_uv);

    imageBufferWidth = blankFrameWidth;
    imageBufferHeight = blankFrameHeight;

    [self convertYUVToRGBOutputI420];

    [self updateTargetsForVideoCameraUsingCacheTextureAtWidth:blankFrameWidth height:blankFrameHeight time:kCMTimeInvalid];

    if (_runBenchmark)
    {
        numberOfFramesCaptured++;
        if (numberOfFramesCaptured > INITIALFRAMESTOIGNOREFORBENCHMARK)
        {
            CFAbsoluteTime currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime);
            totalFrameTimeDuringCapture += currentFrameTime;
            NSLog(@"Average frame time : %f ms", [self averageFrameDurationDuringCapture]);
            NSLog(@"Current frame time : %f ms", 1000.0 * currentFrameTime);
        }
    }
}

- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
                      targetSize:(CGSize)targetSize;
{
    if (capturePaused)
    {
        return;
    }

    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
    int bufferWidth = (int) CVPixelBufferGetWidth(cameraFrame);
    int bufferHeight = (int) CVPixelBufferGetHeight(cameraFrame);
    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);

    [GPUImageContext useImageProcessingContext];
    [GPUImageContext setActiveShaderProgram:bgraConversionProgram];

    CVOpenGLESTextureRef bgraTextureRef = NULL;

    CVPixelBufferLockBaseAddress(cameraFrame, 0);
    
    int targetWidth = targetSize.width;
    int targetHeight = targetSize.height;
    if ( (imageBufferWidth != targetWidth) && (imageBufferHeight != targetHeight) )
    {
        imageBufferWidth = targetWidth;
        imageBufferHeight = targetHeight;
    }

    CVReturn err;
    glActiveTexture(GL_TEXTURE4);

    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [[GPUImageContext sharedImageProcessingContext] coreVideoTextureCache], cameraFrame, NULL, GL_TEXTURE_2D, GL_RGBA, bufferWidth, bufferHeight, GL_RGBA, GL_UNSIGNED_BYTE, 0, &bgraTextureRef);
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }

    bgraConversionTexture = CVOpenGLESTextureGetName(bgraTextureRef);
    glBindTexture(GL_TEXTURE_2D, bgraConversionTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    [self convertBGRAToRGBOutput];

    int rotatedImageBufferWidth = imageBufferWidth, rotatedImageBufferHeight = imageBufferHeight;

    if (GPUImageRotationSwapsWidthAndHeight(internalRotation))
    {
        rotatedImageBufferWidth = imageBufferHeight;
        rotatedImageBufferHeight = imageBufferWidth;
    }

    [self updateTargetsForVideoCameraUsingCacheTextureAtWidth:rotatedImageBufferWidth height:rotatedImageBufferHeight time:currentTime];

    CFRelease(bgraTextureRef);
    CVPixelBufferUnlockBaseAddress(cameraFrame, 0);

    if (_runBenchmark)
    {
        numberOfFramesCaptured++;
        if (numberOfFramesCaptured > INITIALFRAMESTOIGNOREFORBENCHMARK)
        {
            CFAbsoluteTime currentFrameTime = (CFAbsoluteTimeGetCurrent() - startTime);
            totalFrameTimeDuringCapture += currentFrameTime;
            NSLog(@"Average frame time : %f ms", [self averageFrameDurationDuringCapture]);
            NSLog(@"Current frame time : %f ms", 1000.0 * currentFrameTime);
        }
    }
}


- (void)convertYUVToRGBOutput;
{

    int rotatedImageBufferWidth = imageBufferWidth, rotatedImageBufferHeight = imageBufferHeight;

    if (GPUImageRotationSwapsWidthAndHeight(internalRotation))
    {
        rotatedImageBufferWidth = imageBufferHeight;
        rotatedImageBufferHeight = imageBufferWidth;
    }

    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(rotatedImageBufferWidth, rotatedImageBufferHeight) textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, luminanceTextureNV12);
    glUniform1i(yuvConversionLuminanceTextureUniformNV12, 4);

    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, chrominanceTextureNV12);
    glUniform1i(yuvConversionChrominanceTextureUniformNV12, 5);

    glUniformMatrix3fv(yuvConversionMatrixUniformNV12, 1, GL_FALSE, _preferredConversion);

    glVertexAttribPointer(yuvConversionPositionAttributeNV12, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(yuvConversionTextureCoordinateAttributeNV12, 2, GL_FLOAT, 0, 0, [GPUImageFilter textureCoordinatesForRotation:internalRotation]);

    glEnableVertexAttribArray(yuvConversionPositionAttributeNV12);
    glEnableVertexAttribArray(yuvConversionTextureCoordinateAttributeNV12);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDisableVertexAttribArray(yuvConversionPositionAttributeNV12);
    glDisableVertexAttribArray(yuvConversionTextureCoordinateAttributeNV12);
}

- (void)convertYUVToRGBOutputI420;
{

    int rotatedImageBufferWidth = imageBufferWidth, rotatedImageBufferHeight = imageBufferHeight;

    if (GPUImageRotationSwapsWidthAndHeight(internalRotation))
    {
        rotatedImageBufferWidth = imageBufferHeight;
        rotatedImageBufferHeight = imageBufferWidth;
    }

    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(rotatedImageBufferWidth, rotatedImageBufferHeight) textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, texturesI420[0]);
    glUniform1i(yuvConversionYTextureUniformI420, 4);

    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, texturesI420[1]);
    glUniform1i(yuvConversionUTextureUniformI420, 5);

    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, texturesI420[2]);
    glUniform1i(yuvConversionVTextureUniformI420, 6);

    glUniformMatrix3fv(yuvConversionMatrixUniformI420, 1, GL_FALSE, _preferredConversion);

    glVertexAttribPointer(yuvConversionPositionAttributeI420, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(yuvConversionTextureCoordinateAttributeI420, 2, GL_FLOAT, 0, 0, [GPUImageFilter textureCoordinatesForRotation:internalRotation]);

    glEnableVertexAttribArray(yuvConversionPositionAttributeI420);
    glEnableVertexAttribArray(yuvConversionTextureCoordinateAttributeI420);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDisableVertexAttribArray(yuvConversionPositionAttributeI420);
    glDisableVertexAttribArray(yuvConversionTextureCoordinateAttributeI420);

//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)convertBGRAToRGBOutput;
{

    int rotatedImageBufferWidth = imageBufferWidth, rotatedImageBufferHeight = imageBufferHeight;

    if (GPUImageRotationSwapsWidthAndHeight(internalRotation))
    {
        rotatedImageBufferWidth = imageBufferHeight;
        rotatedImageBufferHeight = imageBufferWidth;
    }

    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:CGSizeMake(rotatedImageBufferWidth, rotatedImageBufferHeight) textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, bgraConversionTexture);
    glUniform1i(bgraConversionTextureUniform, 4);

    glVertexAttribPointer(bgraConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(bgraConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [GPUImageFilter textureCoordinatesForRotation: internalRotation]);

    glEnableVertexAttribArray(bgraConversionPositionAttribute);
    glEnableVertexAttribArray(bgraConversionTextureCoordinateAttribute);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDisableVertexAttribArray(bgraConversionPositionAttribute);
    glDisableVertexAttribArray(bgraConversionTextureCoordinateAttribute);

    check_gl_error();
}

#pragma mark -
#pragma mark Benchmarking

- (CGFloat)averageFrameDurationDuringCapture;
{
    return (totalFrameTimeDuringCapture / (CGFloat)(numberOfFramesCaptured - INITIALFRAMESTOIGNOREFORBENCHMARK)) * 1000.0;
}

- (void)resetBenchmarkAverage;
{
    numberOfFramesCaptured = 0;
    totalFrameTimeDuringCapture = 0.0;
}

- (void)incomingPixelBuffer:(nullable CVPixelBufferRef)imageBuffer
                   rotation:(int)rotation
                      width:(size_t)width
                     height:(size_t)height
                     yPlane:(nullable const uint8_t *)yPlane
                     uPlane:(nullable const uint8_t *)uPlane
                     vPlane:(nullable const uint8_t *)vPlane
{
    if (dispatch_semaphore_wait(frameRenderingSemaphore, DISPATCH_TIME_NOW) != 0)
    {
        return;
    }
    if (imageBuffer) {
        CFRetain(imageBuffer);
    }
    runAsynchronouslyOnVideoProcessingQueue(^{

        [self processVideoFrame:imageBuffer
                       rotation:rotation
                          width:width
                         height:height
                         yPlane:yPlane
                         uPlane:uPlane
                         vPlane:vPlane];

        if (imageBuffer) {
            CFRelease(imageBuffer);
        }
        dispatch_semaphore_signal(frameRenderingSemaphore);
    });
}

- (void)incomingSampleBuffer:(CMSampleBufferRef)sampleBuffer
                  targetSize:(CGSize)targetSize;
{
    if (dispatch_semaphore_wait(frameRenderingSemaphore, DISPATCH_TIME_NOW) != 0)
    {
        return;
    }

    CFRetain(sampleBuffer);
    runAsynchronouslyOnVideoProcessingQueue(^{
        [self processVideoSampleBuffer:sampleBuffer targetSize:targetSize];

        CFRelease(sampleBuffer);
        dispatch_semaphore_signal(frameRenderingSemaphore);
    });
}


- (void)clearScreen:(BOOL)asynchronous
{
    if (asynchronous) {
        runAsynchronouslyOnVideoProcessingQueue(^{
            [self processBlackFrame];
        });
    } else {
        runSynchronouslyOnVideoProcessingQueue(^{
            [self processBlackFrame];
        });
    }
}

#pragma mark -
#pragma mark Accessors

- (void)updateOrientationSendToTargets
{
    runSynchronouslyOnVideoProcessingQueue(^{

        //    From the iOS 5.0 release notes:
        //    In previous iOS versions, the front-facing camera would always deliver buffers in AVCaptureVideoOrientationLandscapeLeft and the back-facing camera would always deliver buffers in AVCaptureVideoOrientationLandscapeRight.

        outputRotation = kGPUImageNoRotation;

        if(_delegate.getCameraPosition == AVCaptureDevicePositionBack) {
            if (_horizontallyMirrorBackFacingCamera)
            {
                switch(_outputImageOrientation)
                {
                    case UIInterfaceOrientationPortrait:internalRotation = kGPUImageRotateRightFlipVertical; break;
                    case UIInterfaceOrientationPortraitUpsideDown:internalRotation = kGPUImageRotateLeft; break;
                    case UIInterfaceOrientationLandscapeLeft:internalRotation = kGPUImageFlipHorizonal; break;
                    case UIInterfaceOrientationLandscapeRight:internalRotation = kGPUImageFlipVertical; break;
                    default:internalRotation = kGPUImageNoRotation;
                }
            }
            else
            {
                switch(_outputImageOrientation)
                {
                    case UIInterfaceOrientationPortrait:internalRotation = kGPUImageRotateRight; break;
                    case UIInterfaceOrientationPortraitUpsideDown:internalRotation = kGPUImageRotateLeft; break;
                    case UIInterfaceOrientationLandscapeLeft:internalRotation = kGPUImageRotate180; break;
                    case UIInterfaceOrientationLandscapeRight:internalRotation = kGPUImageNoRotation; break;
                    default:internalRotation = kGPUImageNoRotation;
                }
            }
        } else {
            if (_horizontallyMirrorFrontFacingCamera)
            {
                switch(_outputImageOrientation)
                {
                    case UIInterfaceOrientationPortrait:internalRotation = kGPUImageRotateRightFlipVertical; break;
                    case UIInterfaceOrientationPortraitUpsideDown:internalRotation = kGPUImageRotateRightFlipHorizontal; break;
                    case UIInterfaceOrientationLandscapeLeft:internalRotation = kGPUImageFlipHorizonal; break;
                    case UIInterfaceOrientationLandscapeRight:internalRotation = kGPUImageFlipVertical; break;
                    default:internalRotation = kGPUImageNoRotation;
                }
            }
            else
            {
                switch(_outputImageOrientation)
                {
                    case UIInterfaceOrientationPortrait:internalRotation = kGPUImageRotateRight; break;
                    case UIInterfaceOrientationPortraitUpsideDown:internalRotation = kGPUImageRotateLeft; break;
                    case UIInterfaceOrientationLandscapeLeft:internalRotation = kGPUImageNoRotation; break;
                    case UIInterfaceOrientationLandscapeRight:internalRotation = kGPUImageRotate180; break;
                    default:internalRotation = kGPUImageNoRotation;
                }
            }
        }

        for (id<GPUImageInput> currentTarget in targets)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            [currentTarget setInputRotation:outputRotation atIndex:[[targetTextureIndices objectAtIndex:indexOfObject] integerValue]];
        }
    });
}

- (void)setOutputImageOrientation:(UIInterfaceOrientation)newValue;
{
    _outputImageOrientation = newValue;
    [self updateOrientationSendToTargets];
}

- (void)setHorizontallyMirrorFrontFacingCamera:(BOOL)newValue
{
    _horizontallyMirrorFrontFacingCamera = newValue;
    [self updateOrientationSendToTargets];
}

@end

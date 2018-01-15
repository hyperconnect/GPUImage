#import "GPUImageYuvDataOutput.h"

NSString *const kGPUImageLuminanceForYUVFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     mediump vec3 rgb;
     mediump float luminance;

     rgb = texture2D(inputImageTexture, textureCoordinate).rgb;
     luminance = (0.298 * rgb.x) + (0.587 * rgb.y) + (0.114 * rgb.z);
     gl_FragColor = vec4(luminance, 0, 0, 1);
 }
);

NSString *const kGPUImageChrominanceForYUVFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     mediump vec3 rgb;
     mediump vec2 chrominance;
     
     rgb = texture2D(inputImageTexture, textureCoordinate).rgb;
     chrominance.x = (-0.169 * rgb.x) + (-0.332 * rgb.y) + (0.501 * rgb.z) + 0.5;
     chrominance.y = (0.501 * rgb.x) + (-0.419 * rgb.y) + (-0.081 * rgb.z) + 0.5;
     gl_FragColor = vec4(chrominance, 0, 1);
 }
);


static const GLfloat squareVertices[] = {
    -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f,  1.0f,
    1.0f,  1.0f,
};

static const GLfloat textureCoordinates[] = {
    0.0f, 0.0f,
    1.0f, 0.0f,
    0.0f, 1.0f,
    1.0f, 1.0f,
};

@interface GPUImageYuvDataOutput ()
{
    GPUImageFramebuffer *firstInputFramebuffer, *outputFramebuffer[2], *retainedFramebuffer[2];
    GPUTextureOptions textureOptions[2];
    
    BOOL hasReadFromTheCurrentFrame;
    
    GLProgram *dataProgram[2];
    GLint dataPositionAttribute[2], dataTextureCoordinateAttribute[2];
    GLint dataInputTextureUniform[2];
    
    NSUInteger _bufferSize;
    
    BOOL lockNextFramebuffer;
    
    CGSize imageSize[2];
    GPUImageRotationMode inputRotation;
}

// Frame rendering
- (void)renderAtInternalSize;

- (void)getRawBytesForPlanes;

@end

@implementation GPUImageYuvDataOutput

@synthesize rawBytesForImageYPlane = _rawBytesForImageYPlane;
@synthesize rawBytesForImageUVPlane = _rawBytesForImageUVPlane;
@synthesize bufferSize = _bufferSize;
@synthesize newFrameAvailableBlock = _newFrameAvailableBlock;
@synthesize enabled;

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithImageSize:(CGSize)newImageSize;
{
    if (!(self = [super init]))
    {
		return nil;
    }

    self.enabled = YES;
    lockNextFramebuffer = NO;
    imageSize[0] = newImageSize; // Y Plane은 원본 사이즈
    imageSize[1] = CGSizeMake((newImageSize.width+1)/2, (newImageSize.height+1)/2); // UV Plane은 가로세로 1/2
    hasReadFromTheCurrentFrame = NO;
    _bufferSize = (imageSize[0].width * imageSize[0].height) + (2 * imageSize[1].width * imageSize[1].height);
    inputRotation = kGPUImageNoRotation;

    [GPUImageContext useImageProcessingContext];
    
    [self initFrameBuffer:0 fragmentShaderSting:kGPUImageLuminanceForYUVFragmentShaderString];
    [self initFrameBuffer:1 fragmentShaderSting:kGPUImageChrominanceForYUVFragmentShaderString];
    
    textureOptions[0].minFilter = textureOptions[1].minFilter = GL_LINEAR;
    textureOptions[0].magFilter = textureOptions[1].magFilter = GL_LINEAR;
    textureOptions[0].wrapS = textureOptions[1].wrapS = GL_CLAMP_TO_EDGE;
    textureOptions[0].wrapT = textureOptions[1].wrapT = GL_CLAMP_TO_EDGE;
    
    textureOptions[0].internalFormat = GL_RED_EXT;
    textureOptions[0].format = GL_RED_EXT;
    textureOptions[0].type = GL_UNSIGNED_BYTE;
    
    textureOptions[1].internalFormat = GL_RG_EXT;
    textureOptions[1].format = GL_RG_EXT;
    textureOptions[1].type = GL_UNSIGNED_BYTE;
    return self;
}

- (void)initFrameBuffer:(int)idx fragmentShaderSting:(NSString*)fragmentShaderSting; {
    dataProgram[idx] = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:fragmentShaderSting];
    
    if (!dataProgram[idx].initialized)
    {
        [dataProgram[idx] addAttribute:@"position"];
        [dataProgram[idx] addAttribute:@"inputTextureCoordinate"];
        
        if (![dataProgram[idx] link])
        {
            NSString *progLog = [dataProgram[idx] programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [dataProgram[idx] fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [dataProgram[idx] vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            dataProgram[idx] = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
    
    dataPositionAttribute[idx] = [dataProgram[idx] attributeIndex:@"position"];
    dataTextureCoordinateAttribute[idx] = [dataProgram[idx] attributeIndex:@"inputTextureCoordinate"];
    dataInputTextureUniform[idx] = [dataProgram[idx] uniformIndex:@"inputImageTexture"];
}


#pragma mark -
#pragma mark Data access

- (void)renderAtInternalSize;
{
    // 2 pass 처리가 필요할 듯. 처음에는 정사이즈로 Y 플레인->GL_RED_EXT, 다음에는 반반사이즈로 UV->GL_RG_EXT
    // I420 대신 NV12을 만드는데 만족하자. 화면 출력 속도 향상 및 H.264 인코딩 향상을 위해 CVPixelBufferPool을 도입
    // AzarNativeFrame을 만들어내게 할 수 있을듯..
    
    
    [self renderFrameBuffer:0 lockFrameBuffer:lockNextFramebuffer];
    [self renderFrameBuffer:1 lockFrameBuffer:lockNextFramebuffer];
    
    if(lockNextFramebuffer)  {
        lockNextFramebuffer = NO;
    }
    
    [firstInputFramebuffer unlock];
}

- (void)renderFrameBuffer:(int)idx lockFrameBuffer:(BOOL)lockFrameBuffer; {
    
    [GPUImageContext setActiveShaderProgram:dataProgram[idx]];
    
    outputFramebuffer[idx] = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:imageSize[idx] textureOptions:textureOptions[idx] onlyTexture:NO];
    [outputFramebuffer[idx] activateFramebuffer];
    
    if(lockFrameBuffer)
    {
        retainedFramebuffer[idx] = outputFramebuffer[idx];
        [retainedFramebuffer[idx] lock];
        [retainedFramebuffer[idx] lockForReading];
    }
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(dataInputTextureUniform[idx], 4);
    
    glVertexAttribPointer(dataPositionAttribute[idx], 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(dataTextureCoordinateAttribute[idx], 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glEnableVertexAttribArray(dataPositionAttribute[idx]);
    glEnableVertexAttribArray(dataTextureCoordinateAttribute[idx]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDisableVertexAttribArray(dataPositionAttribute[idx]);
    glDisableVertexAttribArray(dataTextureCoordinateAttribute[idx]);
    
    [outputFramebuffer[idx] unlock];
}


#pragma mark -
#pragma mark GPUImageInput protocol

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    hasReadFromTheCurrentFrame = NO;
    
    if (_newFrameAvailableBlock != NULL)
    {
        _newFrameAvailableBlock();
    }
}

- (NSInteger)nextAvailableTextureIndex;
{
    return 0;
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    firstInputFramebuffer = newInputFramebuffer;
    [firstInputFramebuffer lock];
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    inputRotation = newInputRotation;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
}

- (CGSize)maximumOutputSize;
{
    return imageSize[0];
}

- (void)endProcessing;
{
}

- (BOOL)shouldIgnoreUpdatesToThisTarget;
{
    return NO;
}

- (BOOL)wantsMonochromeInput;
{
    return NO;
}

- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue;
{
    
}

#pragma mark -
#pragma mark Accessors

- (GLubyte *)rawBytesForImageYPlane;
{
    if (hasReadFromTheCurrentFrame)
    {
        return _rawBytesForImageYPlane;
    }
    else
    {
        [self getRawBytesForPlanes];
        return _rawBytesForImageYPlane;
    }
}

- (GLubyte *)rawBytesForImageUVPlane;
{
    if (hasReadFromTheCurrentFrame)
    {
        return _rawBytesForImageUVPlane;
    }
    else
    {
        [self getRawBytesForPlanes];
        return _rawBytesForImageUVPlane;
    }
}

- (void)getRawBytesForPlanes;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        // Note: the fast texture caches speed up 640x480 frame reads from 9.6 ms to 3.1 ms on iPhone 4S

        [GPUImageContext useImageProcessingContext];
        [self renderAtInternalSize];

        glFinish();
        _rawBytesForImageYPlane = [retainedFramebuffer[0] byteBuffer];
        _rawBytesForImageUVPlane = [retainedFramebuffer[1] byteBuffer];
        hasReadFromTheCurrentFrame = YES;
    });
}

- (NSUInteger)bytesPerRowInYPlane;
{
    return [retainedFramebuffer[0] bytesPerRow];
}

- (NSUInteger)bytesPerRowInUVPlane;
{
    return [retainedFramebuffer[1] bytesPerRow];
}

- (void)lockFramebufferForReading;
{
    lockNextFramebuffer = YES;
}

- (void)unlockFramebufferAfterReading;
{
    lockNextFramebuffer = NO;
    [retainedFramebuffer[0] unlockAfterReading];
    [retainedFramebuffer[0] unlock];
    [retainedFramebuffer[1] unlockAfterReading];
    [retainedFramebuffer[1] unlock];
    retainedFramebuffer[0] = retainedFramebuffer[1] = nil;
}

@end

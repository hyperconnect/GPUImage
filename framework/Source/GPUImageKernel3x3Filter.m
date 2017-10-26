//
//  Created by haru on 2017. 10. 25..
//  Copyright © 2017 Hyperconnect. All rights reserved.
//

#import "GPUImageKernel3x3Filter.h"

NSString *const kGPUImageKernel3x3VertexShaderString = SHADER_STRING
(
 precision mediump float;
 attribute vec4 position;
 uniform vec2 uTexelStepSize;

 varying vec2 kernel3x3Coordinates[9];

 void main()
 {
     gl_Position = position;

     vec2 textCoord = vec4((position.xy + 1.0) * 0.5, 0.0, 1.0).xy;

     kernel3x3Coordinates[0] = textCoord + vec2(-uTexelStepSize.x, uTexelStepSize.y);
     kernel3x3Coordinates[1] = textCoord + vec2(0, uTexelStepSize.y);
     kernel3x3Coordinates[2] = textCoord + vec2(uTexelStepSize.x, uTexelStepSize.y);
     kernel3x3Coordinates[3] = textCoord + vec2(-uTexelStepSize.x, 0);
     kernel3x3Coordinates[4] = textCoord;
     kernel3x3Coordinates[5] = textCoord + vec2(uTexelStepSize.x, 0);
     kernel3x3Coordinates[6] = textCoord + vec2(-uTexelStepSize.x, -uTexelStepSize.y);
     kernel3x3Coordinates[7] = textCoord + vec2(0, -uTexelStepSize.y);
     kernel3x3Coordinates[8] = textCoord + vec2(uTexelStepSize.x, -uTexelStepSize.y);
 }
);

@implementation GPUImageKernel3x3Filter

- (id)initWithTexelStepSize:(CGSize)texelStepSize fragmentShaderFromString:(NSString *)fragmentShaderString
{
    if (!(self = [super initWithVertexShaderFromString: kGPUImageKernel3x3VertexShaderString
                              fragmentShaderFromString: fragmentShaderString]))
    {
        return nil;
    }

    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];

        uTexelStepSize = [filterProgram uniformIndex:@"uTexelStepSize"];
    });

    self.texelStepSize = texelStepSize;

    return self;
}

- (id)initWithFrameSize:(CGSize)frameSize fragmentShaderFromString:(NSString *)fragmentShaderString
{
    return [self initWithTexelStepSize: CGSizeMake(1.0 / frameSize.width, 1.0 / frameSize.height)
              fragmentShaderFromString:fragmentShaderString];
}

- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;
{
    [super setUniformsForProgramAtIndex:programIndex];

    if (programIndex == 0)
    {
        glUniform2f(uTexelStepSize, self.texelStepSize.width, self.texelStepSize.height);
    }
}
@end

//
//  Created by haru on 2017. 7. 13..
//  Copyright © 2017년 Brad Larson. All rights reserved.
//

#import "GPUImageBilateralTwoPassFilter.h"

extern CGFloat const kGPUImageBilateralDefaultDistanceNormalizationFactor;
extern NSString *const kGPUImageBilateral1DVertexShaderString;
extern NSString *const kGPUImageBilateral1DFragmentShaderString;

@implementation GPUImageBilateralTwoPassFilter

- (id)initWithTexelStepSize:(CGSize)texelStepSize distanceNormalizationFactor:(CGFloat)factor
{
    if (!(self = [super initWithFirstStageVertexShaderFromString: kGPUImageBilateral1DVertexShaderString
                              firstStageFragmentShaderFromString: kGPUImageBilateral1DFragmentShaderString
                                secondStageVertexShaderFromString: kGPUImageBilateral1DVertexShaderString
                             secondStageFragmentShaderFromString: kGPUImageBilateral1DFragmentShaderString]))
    {
        return nil;
    }

    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];

        firstDirection = [filterProgram uniformIndex:@"uDirection"];
        firstTexelStepSize = [filterProgram uniformIndex:@"uTexelStepSize"];
        firstDistanceNormalizationFactor = [filterProgram uniformIndex:@"uDistanceNormalizationFactor"];

        secondDirection = [secondFilterProgram uniformIndex:@"uDirection"];
        secondTexelStepSize = [secondFilterProgram uniformIndex:@"uTexelStepSize"];
        secondDistanceNormalizationFactor = [secondFilterProgram uniformIndex:@"uDistanceNormalizationFactor"];
    });

    self.texelStepSize = texelStepSize;
    self.distanceNormalizationFactor = factor;

    return self;
}

- (id)initWithTexelStepSize:(CGSize)texelStepSize
{
    return [self initWithTexelStepSize: texelStepSize
           distanceNormalizationFactor: kGPUImageBilateralDefaultDistanceNormalizationFactor];
}

- (id)initWithFrameSize:(CGSize)frameSize
{
    return [self initWithTexelStepSize: CGSizeMake(1.0 / frameSize.width, 1.0 / frameSize.height)
           distanceNormalizationFactor: kGPUImageBilateralDefaultDistanceNormalizationFactor];
}

- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;
{
    [super setUniformsForProgramAtIndex:programIndex];

    if (programIndex == 0)
    {
        // horizontal direction
        glUniform2f(firstDirection, 1, 0);
        glUniform2f(firstTexelStepSize, self.texelStepSize.width, self.texelStepSize.height);
        glUniform1f(firstDistanceNormalizationFactor, self.distanceNormalizationFactor);
    }
    else if (programIndex == 1)
    {
        // vertical direction
        glUniform2f(secondDirection, 0, 1);
        glUniform2f(secondTexelStepSize, self.texelStepSize.width, self.texelStepSize.height);
        glUniform1f(secondDistanceNormalizationFactor, self.distanceNormalizationFactor);
    }
}

@end

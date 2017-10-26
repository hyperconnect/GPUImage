//
//  GPUImageCrossHatch2Filter.m
//  GPUImage
//
//  Created by haru on 2017. 10. 26..
//  Copyright © 2017년 Brad Larson. All rights reserved.
//

#import "GPUImageCrossHatch2Filter.h"

@implementation GPUImageCrossHatch2Filter

- (id)initWithCrossHatchSpacing:(CGFloat)crossHatchSpacing
                      lineWidth:(CGFloat)lineWidth
       fragmentShaderFromString:(NSString *)fragmentShaderString
{
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderString]))
    {
        return nil;
    }

    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];

        uCrossHatchSpacing = [filterProgram uniformIndex:@"crossHatchSpacing"];
        uLineWidth = [filterProgram uniformIndex:@"lineWidth"];
    });

    self.crossHatchSpacing = crossHatchSpacing;
    self.lineWidth = lineWidth;

    return self;
}

- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;
{
    [super setUniformsForProgramAtIndex:programIndex];

    if (programIndex == 0)
    {
        glUniform1f(uCrossHatchSpacing, self.crossHatchSpacing);
        glUniform1f(uLineWidth, self.lineWidth);
    }
}

@end

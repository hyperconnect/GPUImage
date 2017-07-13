//
//  Created by haru on 2017. 7. 13..
//  Copyright © 2017 Hyperconnect. All rights reserved.
//

#import "GPUImageTwoPassFilter.h"

@interface GPUImageBilateralTwoPassFilter : GPUImageTwoPassFilter
{
    GLint firstDirection;
    GLint firstTexelStepSize;
    GLint firstDistanceNormalizationFactor;

    GLint secondDirection;
    GLint secondTexelStepSize;
    GLint secondDistanceNormalizationFactor;
}

@property (nonatomic, assign) CGSize texelStepSize;
@property (nonatomic, assign) CGFloat distanceNormalizationFactor;

- (id)initWithTexelStepSize:(CGSize)texelStepSize distanceNormalizationFactor:(CGFloat)factor;
- (id)initWithTexelStepSize:(CGSize)texelStepSize;
- (id)initWithFrameSize:(CGSize)frameSize;

@end

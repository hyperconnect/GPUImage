//
//  Created by haru on 2017. 7. 12..
//  Copyright © 2017 Hyperconnect. All rights reserved.
//

#import "GPUImageFilter.h"

extern CGFloat const kGPUImageBilateralDefaultDistanceNormalizationFactor;
extern NSString *const kGPUImageBilateral1DVertexShaderString;
extern NSString *const kGPUImageBilateral1DFragmentShaderString;

@interface GPUImageBilateral1DFilter : GPUImageFilter
{
    GLint uDirection;
    GLint uTexelStepSize;
    GLint uDistanceNormalizationFactor;
}

@property (nonatomic, assign) CGPoint direction;
@property (nonatomic, assign) CGSize texelStepSize;
@property (nonatomic, assign) CGFloat distanceNormalizationFactor;

- (id)initWithDirection:(CGPoint)direction texelStepSize:(CGSize)texelStepSize distanceNormalizationFactor:(CGFloat)factor;
- (id)initWithDirection:(CGPoint)direction texelStepSize:(CGSize)texelStepSize;

@end

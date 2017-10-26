//
//  Created by haru on 2017. 10. 25..
//  Copyright © 2017 Hyperconnect. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface GPUImageKernel3x3Filter : GPUImageFilter
{
    GLint uTexelStepSize;
}
@property (nonatomic, assign) CGSize texelStepSize;

- (id)initWithTexelStepSize:(CGSize)texelStepSize fragmentShaderFromString:(NSString *)fragmentShaderString;
- (id)initWithFrameSize:(CGSize)frameSize fragmentShaderFromString:(NSString *)fragmentShaderString;
@end

//
//  Created by haru on 2017. 10. 26..
//  Copyright © 2017 Hyperconnect. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface GPUImageCrossHatch2Filter : GPUImageFilter
{
    GLint uCrossHatchSpacing;
    GLint uLineWidth;
}

@property (nonatomic, assign) CGFloat crossHatchSpacing;
@property (nonatomic, assign) CGFloat lineWidth;

- (id)initWithCrossHatchSpacing:(CGFloat)crossHatchSpacing
                      lineWidth:(CGFloat)lineWidth
       fragmentShaderFromString:(NSString *)fragmentShaderString;

@end

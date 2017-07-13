//
//  Created by haru on 2017. 7. 12..
//  Copyright © 2017 Hyperconnect. All rights reserved.
//

#import "GPUImageBilateral1DFilter.h"

NSString *const kGPUImageBilateral1DVertexShaderString = SHADER_STRING
(
 precision mediump float;
 attribute vec2 position;
 uniform vec2 uTexelStepSize;
 uniform vec2 uDirection;
 varying vec2 blurCoordinates[5];

 void main() {
     gl_Position = vec4(position, 0.0, 1.0);
     vec2 textCoord = ((gl_Position + 1.0) * 0.5).xy;
     vec2 direction = uDirection * uTexelStepSize;
     blurCoordinates[0] = textCoord;
     blurCoordinates[1] = textCoord - direction * 1.3846153;
     blurCoordinates[2] = textCoord + direction * 1.3846153;
     blurCoordinates[3] = textCoord - direction * 3.2307692;
     blurCoordinates[4] = textCoord + direction * 3.2307692;
 }
);

NSString *const kGPUImageBilateral1DFragmentShaderString = SHADER_STRING
(
 precision mediump float;
 uniform sampler2D inputImageTexture;
 uniform float uDistanceNormalizationFactor;
 varying vec2 blurCoordinates[5];

 void main() {
     vec4 centralColor = vec4(0.0);
     float gaussianWeightTotal = 0.0;
     vec4 sum = vec4(0.0);
     vec4 sampleColor = vec4(0.0);
     float distanceFromCentralColor = 0.0;
     float gaussianWeight = 0.0;

     centralColor = texture2D(inputImageTexture, blurCoordinates[0]);
     gaussianWeightTotal = 0.22702703;
     sum = centralColor * 0.22702703;

     sampleColor = texture2D(inputImageTexture, blurCoordinates[1]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * uDistanceNormalizationFactor, 1.0);
     gaussianWeight = 0.31621623 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;

     sampleColor = texture2D(inputImageTexture, blurCoordinates[2]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * uDistanceNormalizationFactor, 1.0);
     gaussianWeight = 0.31621623 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;

     sampleColor = texture2D(inputImageTexture, blurCoordinates[3]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * uDistanceNormalizationFactor, 1.0);
     gaussianWeight = 0.07027027 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;

     sampleColor = texture2D(inputImageTexture, blurCoordinates[4]);
     distanceFromCentralColor = min(distance(centralColor, sampleColor) * uDistanceNormalizationFactor, 1.0);
     gaussianWeight = 0.07027027 * (1.0 - distanceFromCentralColor);
     gaussianWeightTotal += gaussianWeight;
     sum += sampleColor * gaussianWeight;
     
     gl_FragColor = sum / gaussianWeightTotal;
 }
);

@implementation GPUImageBilateral1DFilter

- (id)initWithDirection:(CGPoint)direction texelStepSize:(CGSize)texelStepSize distanceNormalizationFactor:(CGFloat)factor
{
    if (!(self = [super initWithVertexShaderFromString: kGPUImageBilateral1DVertexShaderString
                              fragmentShaderFromString: kGPUImageBilateral1DFragmentShaderString]))
    {
        return nil;
    }

    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];

        uDirection = [filterProgram uniformIndex:@"uDirection"];
        uTexelStepSize = [filterProgram uniformIndex:@"uTexelStepSize"];
        uDistanceNormalizationFactor = [filterProgram uniformIndex:@"uDistanceNormalizationFactor"];
    });

    self.direction = direction;
    self.texelStepSize = texelStepSize;
    self.distanceNormalizationFactor = factor;

    return self;
}

- (id)initWithDirection:(CGPoint)direction texelStepSize:(CGSize)texelStepSize
{
    return [self initWithDirection: direction
                     texelStepSize: texelStepSize
       distanceNormalizationFactor: 10];
}

- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;
{
    [super setUniformsForProgramAtIndex:programIndex];

    if (programIndex == 0)
    {
        glUniform2f(uDirection, self.direction.x, self.direction.y);
        glUniform2f(uTexelStepSize, self.texelStepSize.width, self.texelStepSize.height);
        glUniform1f(uDistanceNormalizationFactor, self.distanceNormalizationFactor);
    }
}

@end

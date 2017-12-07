#import <UIKit/UIKit.h>
#import "GPUImageView.h"

/**
 GPUImageView에 상하/좌우 비율을 조정할 수 있는 기능만 추가한 버전. 상속을 통한 기능확장이 어렵게 되어 있기 때문에 소스를 복사하여 새로운
 클래스를 작성함. 일반적인 의미의 aspect ratio를 조정하는 것이 아닌 렌더링 시 상하/좌우를 얼마나 넓적하게/홀쭉하게 표시할지 여부를 조정함에 유의
 */
@interface GPUImageAspectRatioView : UIView <GPUImageInput>
{
    GPUImageRotationMode inputRotation;
}

/** The fill mode dictates how images are fit in the view, with the default being kGPUImageFillModePreserveAspectRatio
 */
@property(readwrite, nonatomic) GPUImageFillModeType fillMode;

/** This calculates the current display size, in pixels, taking into account Retina scaling factors
 */
@property(readonly, nonatomic) CGSize sizeInPixels;

@property(nonatomic) BOOL enabled;


/** 화면에 최종 렌더링 하기전에 반영하는 좌우 크기조정값. 1보다 작을수록 실제보다 홀쭉하게 표시된다.
 */
@property (assign, nonatomic) double widthRatio;


/** 화면에 최종 렌더링 하기전에 반영하는 상하 크기조정값. 1보다 작을수록 실제보다 홀쭉하게 표시된다.
 */
@property (assign, nonatomic) double heightRatio;

/** Handling fill mode
 
 @param redComponent Red component for background color
 @param greenComponent Green component for background color
 @param blueComponent Blue component for background color
 @param alphaComponent Alpha component for background color
 */
- (void)setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent;

- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue;

@end

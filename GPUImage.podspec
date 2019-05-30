Pod::Spec.new do |s|
  s.name     = 'GPUImage'
  s.version  = '1.0.5-hakuna'
  s.license  = 'BSD'
  s.summary  = 'An open source iOS framework for GPU-based image and video processing.'
  s.homepage = 'https://github.com/BradLarson/GPUImage'
  s.author   = { 'Brad Larson' => 'contact@sunsetlakesoftware.com' }
  s.source   = { :git => 'https://github.com/hyperconnect/GPUImage.git', :tag => "v#{s.version.to_s}" }

  s.source_files = 'framework/Source/**/*.{h,m}'
  s.requires_arc = true
  s.xcconfig = { 'CLANG_MODULES_AUTOLINK' => 'YES' }

  s.ios.deployment_target = '5.0'
  s.ios.exclude_files = 'framework/Source/Mac',
                        'framework/Source/GPUImageBgraVideoOutput.h',
                        'framework/Source/GPUImageBgraVideoOutput.m',
                        'framework/Source/GPUImage3x3ConvolutionFilter.h',
                        'framework/Source/GPUImage3x3ConvolutionFilter.m',
                        'framework/Source/GPUImage3x3TextureSamplingFilter.h',
                        'framework/Source/GPUImage3x3TextureSamplingFilter.m',
                        'framework/Source/GPUImageAdaptiveThresholdFilter.h',
                        'framework/Source/GPUImageAdaptiveThresholdFilter.m',
                        'framework/Source/GPUImageAddBlendFilter.h',
                        'framework/Source/GPUImageAddBlendFilter.m',
                        'framework/Source/GPUImageAlphaBlendFilter.h',
                        'framework/Source/GPUImageAlphaBlendFilter.m',
                        'framework/Source/GPUImageAmatorkaFilter.h',
                        'framework/Source/GPUImageAmatorkaFilter.m',
                        'framework/Source/GPUImageAverageColor.h',
                        'framework/Source/GPUImageAverageColor.m',
                        'framework/Source/GPUImageAverageLuminanceThresholdFilter.h',
                        'framework/Source/GPUImageAverageLuminanceThresholdFilter.m',
                        'framework/Source/GPUImageBilateralFilter.h',
                        'framework/Source/GPUImageBilateralFilter.m',
                        'framework/Source/GPUImageBoxBlurFilter.h',
                        'framework/Source/GPUImageBoxBlurFilter.m',
                        'framework/Source/GPUImageBrightnessFilter.h',
                        'framework/Source/GPUImageBrightnessFilter.m',
                        'framework/Source/GPUImageBulgeDistortionFilter.h',
                        'framework/Source/GPUImageBulgeDistortionFilter.m',
                        'framework/Source/GPUImageCGAColorspaceFilter.h',
                        'framework/Source/GPUImageCGAColorspaceFilter.m',
                        'framework/Source/GPUImageCannyEdgeDetectionFilter.h',
                        'framework/Source/GPUImageCannyEdgeDetectionFilter.m',
                        'framework/Source/GPUImageChromaKeyBlendFilter.h',
                        'framework/Source/GPUImageChromaKeyBlendFilter.m',
                        'framework/Source/GPUImageChromaKeyFilter.h',
                        'framework/Source/GPUImageChromaKeyFilter.m',
                        'framework/Source/GPUImageClosingFilter.h',
                        'framework/Source/GPUImageClosingFilter.m',
                        'framework/Source/GPUImageColorBlendFilter.h',
                        'framework/Source/GPUImageColorBlendFilter.m',
                        'framework/Source/GPUImageColorBurnBlendFilter.h',
                        'framework/Source/GPUImageColorBurnBlendFilter.m',
                        'framework/Source/GPUImageColorDodgeBlendFilter.h',
                        'framework/Source/GPUImageColorDodgeBlendFilter.m',
                        'framework/Source/GPUImageColorInvertFilter.h',
                        'framework/Source/GPUImageColorInvertFilter.m',
                        'framework/Source/GPUImageColorMatrixFilter.h',
                        'framework/Source/GPUImageColorMatrixFilter.m',
                        'framework/Source/GPUImageColorPackingFilter.h',
                        'framework/Source/GPUImageColorPackingFilter.m',
                        'framework/Source/GPUImageContrastFilter.h',
                        'framework/Source/GPUImageContrastFilter.m',
                        'framework/Source/GPUImageCropFilter.h',
                        'framework/Source/GPUImageCropFilter.m',
                        'framework/Source/GPUImageCrosshairGenerator.h',
                        'framework/Source/GPUImageCrosshairGenerator.m',
                        'framework/Source/GPUImageCrosshatchFilter.h',
                        'framework/Source/GPUImageCrosshatchFilter.m',
                        'framework/Source/GPUImageDarkenBlendFilter.h',
                        'framework/Source/GPUImageDarkenBlendFilter.m',
                        'framework/Source/GPUImageDifferenceBlendFilter.h',
                        'framework/Source/GPUImageDifferenceBlendFilter.m',
                        'framework/Source/GPUImageDilationFilter.h',
                        'framework/Source/GPUImageDilationFilter.m',
                        'framework/Source/GPUImageDirectionalNonMaximumSuppressionFilter.h',
                        'framework/Source/GPUImageDirectionalNonMaximumSuppressionFilter.m',
                        'framework/Source/GPUImageDirectionalSobelEdgeDetectionFilter.h',
                        'framework/Source/GPUImageDirectionalSobelEdgeDetectionFilter.m',
                        'framework/Source/GPUImageDissolveBlendFilter.h',
                        'framework/Source/GPUImageDissolveBlendFilter.m',
                        'framework/Source/GPUImageDivideBlendFilter.h',
                        'framework/Source/GPUImageDivideBlendFilter.m',
                        'framework/Source/GPUImageEmbossFilter.h',
                        'framework/Source/GPUImageEmbossFilter.m',
                        'framework/Source/GPUImageErosionFilter.h',
                        'framework/Source/GPUImageErosionFilter.m',
                        'framework/Source/GPUImageExclusionBlendFilter.h',
                        'framework/Source/GPUImageExclusionBlendFilter.m',
                        'framework/Source/GPUImageExposureFilter.h',
                        'framework/Source/GPUImageExposureFilter.m',
                        'framework/Source/GPUImageFASTCornerDetectionFilter.h',
                        'framework/Source/GPUImageFASTCornerDetectionFilter.m',
                        'framework/Source/GPUImageFalseColorFilter.h',
                        'framework/Source/GPUImageFalseColorFilter.m',
                        'framework/Source/GPUImageFourInputFilter.h',
                        'framework/Source/GPUImageFourInputFilter.m',
                        'framework/Source/GPUImageGammaFilter.h',
                        'framework/Source/GPUImageGammaFilter.m',
                        'framework/Source/GPUImageGaussianBlurPositionFilter.h',
                        'framework/Source/GPUImageGaussianBlurPositionFilter.m',
                        'framework/Source/GPUImageGaussianSelectiveBlurFilter.h',
                        'framework/Source/GPUImageGaussianSelectiveBlurFilter.m',
                        'framework/Source/GPUImageGlassSphereFilter.h',
                        'framework/Source/GPUImageGlassSphereFilter.m',
                        'framework/Source/GPUImageGrayscaleFilter.h',
                        'framework/Source/GPUImageGrayscaleFilter.m',
                        'framework/Source/GPUImageHSBFilter.h',
                        'framework/Source/GPUImageHSBFilter.m',
                        'framework/Source/GPUImageHalftoneFilter.h',
                        'framework/Source/GPUImageHalftoneFilter.m',
                        'framework/Source/GPUImageHardLightBlendFilter.h',
                        'framework/Source/GPUImageHardLightBlendFilter.m',
                        'framework/Source/GPUImageHarrisCornerDetectionFilter.h',
                        'framework/Source/GPUImageHarrisCornerDetectionFilter.m',
                        'framework/Source/GPUImageHazeFilter.h',
                        'framework/Source/GPUImageHazeFilter.m',
                        'framework/Source/GPUImageHighPassFilter.h',
                        'framework/Source/GPUImageHighPassFilter.m',
                        'framework/Source/GPUImageHighlightShadowFilter.h',
                        'framework/Source/GPUImageHighlightShadowFilter.m',
                        'framework/Source/GPUImageHistogramEqualizationFilter.h',
                        'framework/Source/GPUImageHistogramEqualizationFilter.m',
                        'framework/Source/GPUImageHistogramFilter.h',
                        'framework/Source/GPUImageHistogramFilter.m',
                        'framework/Source/GPUImageHistogramGenerator.h',
                        'framework/Source/GPUImageHistogramGenerator.m',
                        'framework/Source/GPUImageHoughTransformLineDetector.h',
                        'framework/Source/GPUImageHoughTransformLineDetector.m',
                        'framework/Source/GPUImageHueBlendFilter.h',
                        'framework/Source/GPUImageHueBlendFilter.m',
                        'framework/Source/GPUImageHueFilter.h',
                        'framework/Source/GPUImageHueFilter.m',
                        'framework/Source/GPUImageJFAVoronoiFilter.h',
                        'framework/Source/GPUImageJFAVoronoiFilter.m',
                        'framework/Source/GPUImageKuwaharaFilter.h',
                        'framework/Source/GPUImageKuwaharaFilter.m',
                        'framework/Source/GPUImageKuwaharaRadius3Filter.h',
                        'framework/Source/GPUImageKuwaharaRadius3Filter.m',
                        'framework/Source/GPUImageLanczosResamplingFilter.h',
                        'framework/Source/GPUImageLanczosResamplingFilter.m',
                        'framework/Source/GPUImageLaplacianFilter.h',
                        'framework/Source/GPUImageLaplacianFilter.m',
                        'framework/Source/GPUImageLevelsFilter.h',
                        'framework/Source/GPUImageLevelsFilter.m',
                        'framework/Source/GPUImageLightenBlendFilter.h',
                        'framework/Source/GPUImageLightenBlendFilter.m',
                        'framework/Source/GPUImageLineGenerator.h',
                        'framework/Source/GPUImageLineGenerator.m',
                        'framework/Source/GPUImageLinearBurnBlendFilter.h',
                        'framework/Source/GPUImageLinearBurnBlendFilter.m',
                        'framework/Source/GPUImageLocalBinaryPatternFilter.h',
                        'framework/Source/GPUImageLocalBinaryPatternFilter.m',
                        'framework/Source/GPUImageLookupFilter.h',
                        'framework/Source/GPUImageLookupFilter.m',
                        'framework/Source/GPUImageLowPassFilter.h',
                        'framework/Source/GPUImageLowPassFilter.m',
                        'framework/Source/GPUImageLuminanceThresholdFilter.h',
                        'framework/Source/GPUImageLuminanceThresholdFilter.m',
                        'framework/Source/GPUImageLuminosity.h',
                        'framework/Source/GPUImageLuminosity.m',
                        'framework/Source/GPUImageLuminosityBlendFilter.h',
                        'framework/Source/GPUImageLuminosityBlendFilter.m',
                        'framework/Source/GPUImageMaskFilter.h',
                        'framework/Source/GPUImageMaskFilter.m',
                        'framework/Source/GPUImageMedianFilter.h',
                        'framework/Source/GPUImageMedianFilter.m',
                        'framework/Source/GPUImageMissEtikateFilter.h',
                        'framework/Source/GPUImageMissEtikateFilter.m',
                        'framework/Source/GPUImageMonochromeFilter.h',
                        'framework/Source/GPUImageMonochromeFilter.m',
                        'framework/Source/GPUImageMosaicFilter.h',
                        'framework/Source/GPUImageMosaicFilter.m',
                        'framework/Source/GPUImageMotionBlurFilter.h',
                        'framework/Source/GPUImageMotionBlurFilter.m',
                        'framework/Source/GPUImageMotionDetector.h',
                        'framework/Source/GPUImageMotionDetector.m',
                        'framework/Source/GPUImageMovieComposition.h',
                        'framework/Source/GPUImageMovieComposition.m',
                        'framework/Source/GPUImageMultiplyBlendFilter.h',
                        'framework/Source/GPUImageMultiplyBlendFilter.m',
                        'framework/Source/GPUImageNobleCornerDetectionFilter.h',
                        'framework/Source/GPUImageNobleCornerDetectionFilter.m',
                        'framework/Source/GPUImageNonMaximumSuppressionFilter.h',
                        'framework/Source/GPUImageNonMaximumSuppressionFilter.m',
                        'framework/Source/GPUImageNormalBlendFilter.h',
                        'framework/Source/GPUImageNormalBlendFilter.m',
                        'framework/Source/GPUImageOpacityFilter.h',
                        'framework/Source/GPUImageOpacityFilter.m',
                        'framework/Source/GPUImageOpeningFilter.h',
                        'framework/Source/GPUImageOpeningFilter.m',
                        'framework/Source/GPUImageOverlayBlendFilter.h',
                        'framework/Source/GPUImageOverlayBlendFilter.m',
                        'framework/Source/GPUImageParallelCoordinateLineTransformFilter.h',
                        'framework/Source/GPUImageParallelCoordinateLineTransformFilter.m',
                        'framework/Source/GPUImagePerlinNoiseFilter.h',
                        'framework/Source/GPUImagePerlinNoiseFilter.m',
                        'framework/Source/GPUImagePinchDistortionFilter.h',
                        'framework/Source/GPUImagePinchDistortionFilter.m',
                        'framework/Source/GPUImagePixellateFilter.h',
                        'framework/Source/GPUImagePixellateFilter.m',
                        'framework/Source/GPUImagePixellatePositionFilter.h',
                        'framework/Source/GPUImagePixellatePositionFilter.m',
                        'framework/Source/GPUImagePoissonBlendFilter.h',
                        'framework/Source/GPUImagePoissonBlendFilter.m',
                        'framework/Source/GPUImagePolarPixellateFilter.h',
                        'framework/Source/GPUImagePolarPixellateFilter.m',
                        'framework/Source/GPUImagePolkaDotFilter.h',
                        'framework/Source/GPUImagePolkaDotFilter.m',
                        'framework/Source/GPUImagePosterizeFilter.h',
                        'framework/Source/GPUImagePosterizeFilter.m',
                        'framework/Source/GPUImagePrewittEdgeDetectionFilter.h',
                        'framework/Source/GPUImagePrewittEdgeDetectionFilter.m',
                        'framework/Source/GPUImageRGBClosingFilter.h',
                        'framework/Source/GPUImageRGBClosingFilter.m',
                        'framework/Source/GPUImageRGBDilationFilter.h',
                        'framework/Source/GPUImageRGBDilationFilter.m',
                        'framework/Source/GPUImageRGBErosionFilter.h',
                        'framework/Source/GPUImageRGBErosionFilter.m',
                        'framework/Source/GPUImageRGBFilter.h',
                        'framework/Source/GPUImageRGBFilter.m',
                        'framework/Source/GPUImageRGBOpeningFilter.h',
                        'framework/Source/GPUImageRGBOpeningFilter.m',
                        'framework/Source/GPUImageSaturationBlendFilter.h',
                        'framework/Source/GPUImageSaturationBlendFilter.m',
                        'framework/Source/GPUImageScreenBlendFilter.h',
                        'framework/Source/GPUImageScreenBlendFilter.m',
                        'framework/Source/GPUImageSepiaFilter.h',
                        'framework/Source/GPUImageSepiaFilter.m',
                        'framework/Source/GPUImageSharpenFilter.h',
                        'framework/Source/GPUImageSharpenFilter.m',
                        'framework/Source/GPUImageShiTomasiFeatureDetectionFilter.h',
                        'framework/Source/GPUImageShiTomasiFeatureDetectionFilter.m',
                        'framework/Source/GPUImageSingleComponentGaussianBlurFilter.h',
                        'framework/Source/GPUImageSingleComponentGaussianBlurFilter.m',
                        'framework/Source/GPUImageSketchFilter.h',
                        'framework/Source/GPUImageSketchFilter.m',
                        'framework/Source/GPUImageSmoothToonFilter.h',
                        'framework/Source/GPUImageSmoothToonFilter.m',
                        'framework/Source/GPUImageSobelEdgeDetectionFilter.h',
                        'framework/Source/GPUImageSobelEdgeDetectionFilter.m',
                        'framework/Source/GPUImageSoftEleganceFilter.h',
                        'framework/Source/GPUImageSoftEleganceFilter.m',
                        'framework/Source/GPUImageSoftLightBlendFilter.h',
                        'framework/Source/GPUImageSoftLightBlendFilter.m',
                        'framework/Source/GPUImageSolidColorGenerator.h',
                        'framework/Source/GPUImageSolidColorGenerator.m',
                        'framework/Source/GPUImageSourceOverBlendFilter.h',
                        'framework/Source/GPUImageSourceOverBlendFilter.m',
                        'framework/Source/GPUImageSphereRefractionFilter.h',
                        'framework/Source/GPUImageSphereRefractionFilter.m',
                        'framework/Source/GPUImageStretchDistortionFilter.h',
                        'framework/Source/GPUImageStretchDistortionFilter.m',
                        'framework/Source/GPUImageSubtractBlendFilter.h',
                        'framework/Source/GPUImageSubtractBlendFilter.m',
                        'framework/Source/GPUImageSwirlFilter.h',
                        'framework/Source/GPUImageSwirlFilter.m',
                        'framework/Source/GPUImageThreeInputFilter.h',
                        'framework/Source/GPUImageThreeInputFilter.m',
                        'framework/Source/GPUImageThresholdEdgeDetectionFilter.h',
                        'framework/Source/GPUImageThresholdEdgeDetectionFilter.m',
                        'framework/Source/GPUImageThresholdSketchFilter.h',
                        'framework/Source/GPUImageThresholdSketchFilter.m',
                        'framework/Source/GPUImageThresholdedNonMaximumSuppressionFilter.h',
                        'framework/Source/GPUImageThresholdedNonMaximumSuppressionFilter.m',
                        'framework/Source/GPUImageTiltShiftFilter.h',
                        'framework/Source/GPUImageTiltShiftFilter.m',
                        'framework/Source/GPUImageToneCurveFilter.h',
                        'framework/Source/GPUImageToneCurveFilter.m',
                        'framework/Source/GPUImageToonFilter.h',
                        'framework/Source/GPUImageToonFilter.m',
                        'framework/Source/GPUImageTransformFilter.h',
                        'framework/Source/GPUImageTransformFilter.m',
                        'framework/Source/GPUImageTwoInputCrossTextureSamplingFilter.h',
                        'framework/Source/GPUImageTwoInputCrossTextureSamplingFilter.m',
                        'framework/Source/GPUImageUnsharpMaskFilter.h',
                        'framework/Source/GPUImageUnsharpMaskFilter.m',
                        'framework/Source/GPUImageVignetteFilter.h',
                        'framework/Source/GPUImageVignetteFilter.m',
                        'framework/Source/GPUImageVoronoiConsumerFilter.h',
                        'framework/Source/GPUImageVoronoiConsumerFilter.m',
                        'framework/Source/GPUImageWeakPixelInclusionFilter.h',
                        'framework/Source/GPUImageWeakPixelInclusionFilter.m',
                        'framework/Source/GPUImageWhiteBalanceFilter.h',
                        'framework/Source/GPUImageWhiteBalanceFilter.m',
                        'framework/Source/GPUImageXYDerivativeFilter.h',
                        'framework/Source/GPUImageXYDerivativeFilter.m',
                        'framework/Source/GPUImageZoomBlurFilter.h',
                        'framework/Source/GPUImageZoomBlurFilter.m'
  s.ios.frameworks   = ['OpenGLES', 'CoreMedia', 'QuartzCore', 'AVFoundation']

  s.osx.deployment_target = '10.6'
  s.osx.exclude_files = 'framework/Source/iOS',
                        'framework/Source/GPUImageFilterPipeline.*',
                        'framework/Source/GPUImageMovie.*',
                        'framework/Source/GPUImageMovieComposition.*',
                        'framework/Source/GPUImageVideoCamera.*',
                        'framework/Source/GPUImageStillCamera.*',
                        'framework/Source/GPUImageUIElement.*'
  s.osx.xcconfig = { 'GCC_WARN_ABOUT_RETURN_TYPE' => 'YES' }
end

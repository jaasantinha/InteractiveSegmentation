//
//  InteractiveSegmentationController.h
//  InteractiveSegmentation
//
//  Created by Joao Santinha on 15/06/16.
//
//

#import <Cocoa/Cocoa.h>
#import <HorosAPI/ViewerController.h>
#import <HorosAPI/DCMPix.h>
#import <HorosAPI/ROI.h>
#import "ITKHeaders/itkImage.h"
#import "ITKHeaders/itkImportImageFilter.h"
#import "ITKHeaders/itkBinaryThresholdImageFilter.h"
#import "ITKHeaders/itkMinimumMaximumImageCalculator.h"

typedef float pixTypeFloat;
typedef unsigned char pixTypeUChar;
typedef itk::Image< pixTypeFloat, 3 > ImageTypeFloat3D;
typedef itk::Image< pixTypeUChar, 3 > ImageTypeUChar3D;
typedef itk::ImportImageFilter< pixTypeFloat, 3 > ImportFilterTypeFloat3D;

//typedef itk::MinimumMaximumImageFilter<ImageTypeFloat3D> MinimumMaximumFilterType;
typedef itk::MinimumMaximumImageCalculator <ImageTypeFloat3D>
ImageCalculatorFilterType;

typedef itk::BinaryThresholdImageFilter<ImageTypeFloat3D, ImageTypeUChar3D> BinaryThresholdFilterType;


@interface InteractiveSegmentationController : NSWindowController {
    ViewerController *viewerC;
    
    NSSlider *lowerSlider;
    NSSlider *upperSlider;
    
    ImageTypeFloat3D::Pointer originalImage;
    ImageTypeUChar3D::Pointer segmentedMaskImage;
    
    float maxIntensity;
    float minIntensity;
}

- (instancetype) initWithViewerController:(ViewerController *) viewer;

@end

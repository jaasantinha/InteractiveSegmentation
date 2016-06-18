//
//  InteractiveSegmentationController.m
//  InteractiveSegmentation
//
//  Created by Joao Santinha on 15/06/16.
//
//

#import "InteractiveSegmentationController.h"

@interface InteractiveSegmentationController ()

@end

NSString *segmentationROIName = @"Segmentation ROI";


@implementation InteractiveSegmentationController

- (instancetype) initWithViewerController:(ViewerController *) viewer;
{
    viewerC = viewer;
    
    
    self = [super initWithWindowNibName:@"InteractiveSegmentationController"];
    
    if (self)
    {
        [self getITKImageFrom:viewer];
        
        ImageCalculatorFilterType::Pointer imageCalculatorFilter
        = ImageCalculatorFilterType::New ();
        imageCalculatorFilter->SetImage(originalImage);
        imageCalculatorFilter->Compute();
        
        minIntensity = imageCalculatorFilter->GetMinimum();
        maxIntensity = imageCalculatorFilter->GetMaximum();
        
        lowerSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(18, 67, 327, 20)];
        [lowerSlider setMinValue:minIntensity];
        [lowerSlider setMaxValue:maxIntensity];
        [lowerSlider setFloatValue:minIntensity + (maxIntensity - minIntensity)/2.];
        [lowerSlider setTag:1];
        [lowerSlider setTarget:self];
        [lowerSlider setAction:@selector(sliderChanged:)];
        
        upperSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(18, 18, 327, 20)];
        [upperSlider setMinValue:minIntensity];
        [upperSlider setMaxValue:maxIntensity];
        [upperSlider setFloatValue:maxIntensity];
        [upperSlider setTag:2];
        [upperSlider setTarget:self];
        [upperSlider setAction:@selector(sliderChanged:)];
        
        
        [self createSegmentationMask];
        [self propagateSegmentationROI];
        
        
        [[[self window] contentView] addSubview:lowerSlider];
        [[[self window] contentView] addSubview:upperSlider];
        
        [self showWindow:self];
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark sliders actions
- (void) sliderChanged:(id) sender;
{
    if ([sender tag] == 1)
    {
        NSLog(@"LowerSliderChanged");
        if ([lowerSlider floatValue] >= [upperSlider floatValue])
        {
            NSLog(@"LowerSliderChanged inside if with value: %f", [lowerSlider floatValue]);
            [lowerSlider setFloatValue:[upperSlider floatValue] - 1./100.];
        }
    }
    else
    {
        NSLog(@"UpperSliderChanged");
        if ([upperSlider floatValue] <= [lowerSlider floatValue])
        {
            NSLog(@"UpperSliderChanged inside if with value: %f", [upperSlider floatValue]);
            [upperSlider setFloatValue:[lowerSlider floatValue] + 1./100.];
        }
    }
    
    [self createSegmentationMask];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(propagateSegmentationROI) object:nil];
    [self performSelector:@selector(propagateSegmentationROI) withObject:nil afterDelay:0.05];
}

- (void) lowerSliderChanged:(id) sender;
{
    NSLog(@"LowerSliderChanged");
    if ([lowerSlider floatValue] >= [upperSlider floatValue])
    {
        NSLog(@"LowerSliderChanged inside if");
        [lowerSlider setFloatValue:[upperSlider floatValue] - 1./100.];
    }
}



#pragma mark ITK-ViewerController interface
- (void) getITKImageFrom:(ViewerController*) Viewer
{
    ImportFilterTypeFloat3D::Pointer importFilter = ImportFilterTypeFloat3D::New();
    ImportFilterTypeFloat3D::SizeType size;
    ImportFilterTypeFloat3D::IndexType start;
    ImportFilterTypeFloat3D::RegionType region;
    
    
    DCMPix *firstPix = [[Viewer pixList] objectAtIndex:0];
    int slices = [[Viewer pixList] count];
    
    
    //Size Width * Height * NoOfSlices
    size[0] = [firstPix pwidth];
    size[1] = [firstPix pheight];
    size[2] = slices;
    
    
    long bufferSize = size[0] * size[1] * size[2];
    
    
    start.Fill(0);
    
    
    region.SetIndex(start);
    region.SetSize(size);
    
    
    double voxelSpacing[3];
    double originConverted[3];
    double vectorOriginal[9];
    double origin[3];
    
    
    origin[0] = [firstPix originX];
    origin[1] = [firstPix originY];
    origin[2] = [firstPix originZ];
    
    
    [firstPix orientationDouble: vectorOriginal];
    originConverted[ 0] = origin[ 0] * vectorOriginal[ 0] + origin[ 1] * vectorOriginal[ 1] + origin[ 2] * vectorOriginal[ 2];
    originConverted[ 1] = origin[ 0] * vectorOriginal[ 3] + origin[ 1] * vectorOriginal[ 4] + origin[ 2] * vectorOriginal[ 5];
    originConverted[ 2] = origin[ 0] * vectorOriginal[ 6] + origin[ 1] * vectorOriginal[ 7] + origin[ 2] * vectorOriginal[ 8];
    
    
    voxelSpacing[0] = [firstPix pixelSpacingX];
    voxelSpacing[1] = [firstPix pixelSpacingY];
    voxelSpacing[2] = [firstPix sliceInterval];
    
    
    importFilter->SetRegion(region);
    importFilter->SetOrigin(originConverted);
    importFilter->SetSpacing(voxelSpacing);
    importFilter->SetImportPointer([Viewer volumePtr] , bufferSize, false);
    importFilter->Update();
    
    originalImage = importFilter->GetOutput();
}

- (void) binarizeImage
{
    BinaryThresholdFilterType::Pointer binaryFilter = BinaryThresholdFilterType::New();
    binaryFilter->SetInput(originalImage);
    binaryFilter->SetLowerThreshold([lowerSlider floatValue]);
    binaryFilter->SetUpperThreshold([upperSlider floatValue]);
    binaryFilter->Update();
    
    segmentedMaskImage = binaryFilter->GetOutput();
}

- (void) createSegmentationMask
{
    [self binarizeImage];
    
    [self createMaskCurPix];
}

- (void) propagateSegmentationROI
{
    [self createMaskNonCurPix];
}

- (void) createMaskCurPix
{
    [viewerC roiIntDeleteAllROIsWithSameName:segmentationROIName];
    
    short currentImage = [[viewerC imageView] curImage];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        unsigned char *buff = segmentedMaskImage->GetBufferPointer();
        
        int buffHeight = [[[viewerC pixList] objectAtIndex: 0] pheight];
        
        int buffWidth = [[[viewerC pixList] objectAtIndex: 0] pwidth];
        
        if( buff )
        {
            if( memchr( buff + currentImage * buffWidth * buffHeight, 255, buffWidth * buffHeight))
            {
                ROI *theNewROI = [[ROI alloc] initWithTexture: (buff + currentImage * buffWidth * buffHeight)
                                                    textWidth:buffWidth
                                                   textHeight:buffHeight
                                                     textName:segmentationROIName
                                                    positionX:0
                                                    positionY:0
                                                     spacingX:[[[viewerC imageView] curDCM] pixelSpacingX]
                                                     spacingY:[[[viewerC imageView] curDCM] pixelSpacingY]
                                                  imageOrigin: [DCMPix originCorrectedAccordingToOrientation: [[viewerC imageView] curDCM]]];
                
                [[[viewerC roiList] objectAtIndex:currentImage] addObject:theNewROI];
                
                RGBColor color;
                color.red = 0.67*65535.;
                color.green = 0.98*65535.;
                color.blue = 0.58*65535.;
                
                [theNewROI setColor: color];
                [theNewROI setSliceThickness:[[[viewerC imageView] curDCM] sliceThickness]];
                
                dispatch_async(dispatch_get_main_queue(), ^{[viewerC needsDisplayUpdate];});
            }
        }
        buff = nil;
    });
}

- (void) createMaskNonCurPix
{
    short currentImage = [[viewerC imageView] curImage];
    NSLog(@"Current Image: %d", currentImage);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        unsigned char *buff = segmentedMaskImage->GetBufferPointer();
    
        int buffHeight = [[[viewerC pixList] objectAtIndex: 0] pheight];
        int buffWidth = [[[viewerC pixList] objectAtIndex: 0] pwidth];
        
        if( buff )
        {
            for( int j = currentImage + 1; j < [[viewerC pixList] count]; j++)
            {
                if( memchr( buff + j * buffWidth * buffHeight, 255, buffWidth * buffHeight))
                {
                    ROI *theNewROI = [[ROI alloc] initWithTexture:(buff + j * buffWidth * buffHeight)
                                                        textWidth:buffWidth
                                                       textHeight:buffHeight
                                                         textName:segmentationROIName
                                                        positionX:0
                                                        positionY:0
                                                         spacingX:[[[viewerC imageView] curDCM] pixelSpacingX]
                                                         spacingY:[[[viewerC imageView] curDCM] pixelSpacingY]
                                                      imageOrigin: [DCMPix originCorrectedAccordingToOrientation: [[viewerC imageView] curDCM]]];
                    [[[viewerC roiList] objectAtIndex:j] addObject:theNewROI];
                    
                    RGBColor color;
                    color.red = 0.67*65535.;
                    color.green = 0.98*65535.;
                    color.blue = 0.58*65535.;
                    
                    [theNewROI setColor: color];
                    [theNewROI setSliceThickness:[[[viewerC imageView] curDCM] sliceThickness]];
                }
            }
        }
        
        buff = nil;
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        unsigned char *buff = segmentedMaskImage->GetBufferPointer();
        
        int buffHeight = [[[viewerC pixList] objectAtIndex: 0] pheight];
        int buffWidth = [[[viewerC pixList] objectAtIndex: 0] pwidth];
        
        if( buff )
        {
            for( int j = currentImage - 1; j >= 0; j--)
            {
                if( memchr( buff + j * buffWidth * buffHeight, 255, buffWidth * buffHeight))
                {
                    ROI *theNewROI = [[ROI alloc] initWithTexture:(buff + j * buffWidth * buffHeight)
                                                        textWidth:buffWidth
                                                       textHeight:buffHeight
                                                         textName:segmentationROIName
                                                        positionX:0
                                                        positionY:0
                                                         spacingX:[[[viewerC imageView] curDCM] pixelSpacingX]
                                                         spacingY:[[[viewerC imageView] curDCM] pixelSpacingY]
                                                      imageOrigin: [DCMPix originCorrectedAccordingToOrientation: [[viewerC imageView] curDCM]]];
                    
                    [[[viewerC roiList] objectAtIndex:j] addObject:theNewROI];
                    
                    RGBColor color;
                    color.red = 0.67*65535.;
                    color.green = 0.98*65535.;
                    color.blue = 0.58*65535.;
                    
                    [theNewROI setColor: color];
                    
                    [theNewROI setSliceThickness:[[[viewerC imageView] curDCM] sliceThickness]];
                }
            }
        }
        
        buff = nil;
    });
}

@end

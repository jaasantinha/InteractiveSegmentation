//
//  InteractiveSegmentationFilter.m
//  InteractiveSegmentation
//
//  Copyright (c) 2016 Joao Santinha. All rights reserved.
//

#import "InteractiveSegmentationFilter.h"

@implementation InteractiveSegmentationFilter

- (void) initPlugin
{
}

- (long) filterImage:(NSString*) menuName
{
    InteractiveSegmentationController *controller = [[InteractiveSegmentationController alloc] initWithViewerController:viewerController];
    return 0;
//	ViewerController	*new2DViewer;
//	
//	// In this plugin, we will simply duplicate the current 2D window!
//	
//	new2DViewer = [self duplicateCurrent2DViewerWindow];
//	
//	if( new2DViewer) return 0; // No Errors
//	else return -1;
}

@end

//
//  InteractiveSegmentationFilter.h
//  InteractiveSegmentation
//
//  Copyright (c) 2016 Joao Santinha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HorosAPI/PluginFilter.h>
#import "InteractiveSegmentationController.h"

@interface InteractiveSegmentationFilter : PluginFilter {

}

- (long) filterImage:(NSString*) menuName;

@end

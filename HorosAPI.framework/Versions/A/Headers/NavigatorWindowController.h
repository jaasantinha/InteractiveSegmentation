/*=========================================================================
  Program:   OsiriX

  Copyright (c) OsiriX Team
  All rights reserved.
  Distributed under GNU - LGPL
  
  See http://www.osirix-viewer.com/copyright.html for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.
 ---------------------------------------------------------------------------
 
 This file is part of the Horos Project.
 
 Current contributors to the project include Alex Bettarini and Danny Weissman.
 
 Horos is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation,  version 3 of the License.
 
 Horos is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Horos.  If not, see <http://www.gnu.org/licenses/>.

 

 
 ---------------------------------------------------------------------------
 
 This file is part of the Horos Project.
 
 Current contributors to the project include Alex Bettarini and Danny Weissman.
 
 Horos is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation,  version 3 of the License.
 
 Horos is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Horos.  If not, see <http://www.gnu.org/licenses/>.

=========================================================================*/

#import <Cocoa/Cocoa.h>
#import "NavigatorView.h"
@class ViewerController;
@class DCMView;

/** \brief Window Controller for the Navigator. The Navigator provides a unrolled view of the selected series (in 3D and in 4D).*/
@interface NavigatorWindowController : NSWindowController
{
	ViewerController *viewerController;
	IBOutlet NavigatorView *navigatorView;
    IBOutlet NSScrollView *scrollview;
	BOOL dontReEnter;
}

/**  Returns the Navigator Window Controller (which is a unique object).*/
+ (NavigatorWindowController*) navigatorWindowController;
- (void) adjustWindowPosition;
- (id)initWithViewer:(ViewerController*)viewer;
- (void)setViewer:(ViewerController*)viewer;
- (void)initView;
/**  Computes minSize and maxSize of its window.*/
- (void)computeMinAndMaxSize;
- (void)setWindowLevel:(NSNotification*)notification;

@property(readonly) NavigatorView *navigatorView;
@property(readonly) ViewerController *viewerController;

@end

//
//  SLCircleGestureRecognizer.h
//  Punchtimer
//
//  Created by Sigurd Ljødal on 08.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface SLCircleGestureRecognizer : UIGestureRecognizer

@property (nonatomic, readonly) CGFloat progress;

@end
//
//  Three_D_TemplateLayer.h
//  Three D Template
//
//  Created by Matthew Demma on 2/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "CC3Layer.h"


/** A sample application-specific CC3Layer subclass. */
@interface Three_D_TemplateLayer : CC3Layer {

    UISwipeGestureRecognizer * _swipeRightRecognizer;
    UISwipeGestureRecognizer * _swipeLeftRecognizer;

}

@property (retain) UISwipeGestureRecognizer * swipeRightRecognizer;
@property (retain) UISwipeGestureRecognizer * swipeLeftRecognizer;
@end

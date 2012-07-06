//
//  RolePickerController.h
//  RoleScroll
//
//  Created by Matthew Demma on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RolePickerController : UIPickerView<UIPickerViewDelegate, UIPickerViewDataSource>
{
NSMutableArray *roles;
}

@property (readwrite,retain) NSMutableArray* roles;

-(void)spinToMe;

@end

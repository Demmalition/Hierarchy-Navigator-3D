//
//  RecordTypeTableController.h
//  RoleScroll
//
//  Created by Matthew Demma on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordTypeTableController : UITableViewController {
    BOOL isGrouped;
    BOOL useAccessory;
    BOOL useThumbnail;
    NSArray *recTypes;
    
}

@property (nonatomic, retain, strong) NSArray* recTypes;

-(void) addAccessory;
-(void) addThumbnail;
@end

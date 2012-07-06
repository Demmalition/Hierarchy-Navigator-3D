//
//  RolePickerController.m
//  RoleScroll
//
//  Created by Matthew Demma on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RolePickerController.h"
#import "GameVars.h"

@implementation RolePickerController

@synthesize roles;

GameVars *theseVars;
 NSArray *sortedArray;

- (id)initWithFrame:(CGRect)frame roles:(NSMutableArray*) passRoles
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate=self;
        theseVars = [GameVars sharedGameVars];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"Name"
                                                      ascending:YES] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
       
        sortedArray = [passRoles sortedArrayUsingDescriptors:sortDescriptors];

        //[passRoles sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        self.roles=(NSMutableArray*)sortedArray;
        
                  
    return self;
}
    
}

-(void) spinToMe {
    NSIndexSet *defaultRole;
    NSDictionary *userObj=[theseVars.userDetails objectAtIndex:0];
    NSString *myRole=[userObj objectForKey:@"UserRoleId"];
    defaultRole = [self.roles indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL * stop){ 
        return [[obj objectForKey:@"Id"]  isEqualToString:myRole];}];
    NSLog(@"MyRoles: ,%i",[defaultRole count]);
    [self selectRow:[defaultRole firstIndex] inComponent:0 animated:YES];
    theseVars.startNode=myRole;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    NSLog(@"SFAuthorizingViewController shouldAutorotateToInterfaceOrientation:%d",interfaceOrientation);
//    // Return YES for supported orientations
//	return YES;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    NSDictionary *thisRole = [roles objectAtIndex:row];
    NSString *newRole=[thisRole objectForKey:@"Id"];
    theseVars.startNode=newRole;
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return roles.count;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    NSDictionary *thisRole = [roles objectAtIndex:row];
    title=[thisRole objectForKey:@"Name"] ;
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

- (void)dealloc {
    [roles release];
    roles = nil;
    
    [super dealloc];
}

@end

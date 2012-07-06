//
//  roleNode.h
//  RoleScroll
//
//  Created by Matthew Demma on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CC3Node.h"

@interface roleNode : CC3Node  {
    
    NSString *roleId;
    NSString *roleName;
    int numOpptys;
    int numClosed;
    int numWon;
    int sumValue;
    int pipeOpptys;
    int pipeClosed;
    int pipeWon;
    int pipeValue;
    
}

@property (readwrite, retain) NSString *roleId;
@property (readwrite, retain) NSString *roleName;
@property (readwrite, assign) int numOpptys;
@property (readwrite, assign) int numClosed;
@property (readwrite, assign) int numWon;
@property (readwrite, assign) int sumValue;
@property (readwrite, assign) int pipeOpptys;
@property (readwrite, assign) int pipeClosed;
@property (readwrite, assign) int pipeWon;
@property (readwrite, assign) int pipeValue;

@end

//
//  GameVars.h
//  3d test
//
//  Created by Matthew Demma on 6/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "cocos2d.h"

@interface GameVars : NSObject {
	
	NSMutableArray* records;
    NSMutableArray* metrics;
    NSMutableArray* userDetails;
    NSMutableArray* recordTypes;
    int hierLevels;
    int rootLevel;
    int dateFilter;
    NSString* userId;
    NSString* statText;
    NSString* navText;
    NSString* filterText;
    BOOL transitionText;
    NSString* startNode;

}



@property (readwrite, retain) NSMutableArray* records;
@property (readwrite, retain) NSMutableArray* metrics;
@property (readwrite, retain) NSMutableArray* userDetails;
@property (readwrite, retain) NSMutableArray* recordTypes;
@property (readwrite) int hierLevels;
@property (readwrite) int dateFilter;
@property (readwrite) int rootLevel;
@property (readwrite, retain) NSString* userId;
@property (readwrite, retain) NSString* statText;
@property (readwrite, retain) NSString* navText;
@property (readwrite, retain) NSString* filterText;
@property (readwrite, retain) NSString* startNode;
@property (readwrite) BOOL transitionText;
@end

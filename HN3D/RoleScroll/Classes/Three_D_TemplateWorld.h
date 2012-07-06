//
//  Three_D_TemplateWorld.h
//  Three D Template
//
//  Created by Matthew Demma on 2/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "CC3World.h"
#import "CC3MeshNode.h"
#import "SFRestAPI.h"
#import "TableViewController.h"


/** A sample application-specific CC3World subclass.*/
@interface Three_D_TemplateWorld : CC3World <SFRestDelegate>   {


}

- (void)indexRight;
- (void)indexLeft;
- (void)reQuery;
- (void)popoutDetails;
- (void)buildTree;

-(NSString*) buildString;
-(ccColor3B) metricColor: (float) metric;
@end

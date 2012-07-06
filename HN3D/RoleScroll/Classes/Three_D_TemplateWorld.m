//
//  Three_D_TemplateWorld.m
//  Three D Template
//
//  Created by Matthew Demma on 2/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "Three_D_TemplateWorld.h"
#import "CC3PODResourceNode.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3Billboard.h"
#import "GameVars.h"
#import "SBJson.h"
#import "SFRestAPI.h"
#import "SFRestRequest.h"
#import "CC3VertexArrayMesh.h"
#import "roleNode.h"
#import "MBProgressHUD.h"
#import "com.ccColor3B.h"

GameVars *theseVars;
float camDegrees;
float camDegrees2;
NSMutableArray *_nodes;
NSMutableArray *_lines;
NSMutableArray *_currentLevel;
NSMutableArray *_pipelineDetails;
int nowIndex;
CC3Billboard *bgDisplay;
NSString *thisId;
NSString *thisName;
NSString *prevName;
NSString *prevId;
CC3Node* helloTxt;
CC3Node* sphereMaster;
CC3Node *glowNode;
CC3Node* homeIcon;
int levCount;
int queryType;
CCSprite *bgSprite;
CCLabelTTF *bonus;
int currLevel;
ccColor3B thisColor;

NSString *skin;
NSString *sizeMetric;
NSString *colorMetric;

@implementation Three_D_TemplateWorld



-(void) dealloc {
	[super dealloc];
}

/**
 * Constructs the 3D world.
 *
 * Adds 3D objects to the world, loading a 3D 'hello, world' message
 * from a POD file, and creating the camera and light programatically.
 *
 * When adapting this template to your application, remove all of the content
 * of this method, and add your own to construct your 3D model world.
 *
 * NOTE: The POD file used for the 'hello, world' message model is fairly large,
 * because converting a font to a mesh results in a LOT of triangles. When adapting
 * this template project for your own application, REMOVE the POD file 'hello-world.pod'
 * from the Resources folder of your project!!
 */
-(void) initializeWorld {
    
    [self registerDefaultsFromSettingsBundle];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs synchronize];
    
	skin = [defs stringForKey:@"skin_pref"];
    sizeMetric=[defs stringForKey:@"size_metric"];    
    colorMetric=[defs objectForKey:@"color_metric"];

	theseVars = [GameVars sharedGameVars];
    queryType=1;
    _nodes = [[NSMutableArray alloc] init];
    _lines = [[NSMutableArray alloc] init];
    _currentLevel = [[NSMutableArray alloc] init];
    _pipelineDetails = [[NSMutableArray alloc] init];
    // Create the camera, place it back a bit, and add it to the world
	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v( 0.0, -1.0, 12.0 );
    cam.nearClippingPlane=4;
    [cam setIsUsingParallelProjection:NO];
	[self addChild: cam];
    //[self setColor:ccc3(255, 0, 0)];
	// Create a light, place it back and to the left at a specific
	// position (not just directional lighting), and add it to the world
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( -5.0, -2.0, 0.0 );
	lamp.isDirectionalOnly = NO;
	[cam addChild: lamp];
    CC3Light* lamp2 = [CC3Light nodeWithName: @"Lamp2"];
	lamp2.location = cc3v( 5.0, -4.0, 0.0 );
    lamp2.color=ccc3(0, 250, 0);
	lamp2.isDirectionalOnly = YES;
	[cam addChild: lamp2];
	// This is the simplest way to load a POD resource file and add the
	// nodes to the CC3World, if no customized resource subclass is needed.
	//[self addContentFromPODResourceFile: @"hello-world.pod"];
	[self addContentFromPODResourceFile: @"sphere.pod"];
    //[self addContentFromPODResourceFile: @"home.pod"];
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantData];

	
	// If you encounter issues creating and adding nodes, or loading models from
	// files, the following line is used to log the full structure of the world.
	LogDebug(@"The structure of this world is: %@", [self structureDescription]);
	
	// ------------------------------------------

	// But to add some dynamism, we'll animate the 'hello, world' message
	// using a couple of cocos2d actions...
	
	// Fetch the 'hello, world' 3D text object that was loaded from the
	// POD file and start it rotating
    if ([skin isEqualToString:@"sky"]) {
        bgSprite =  [CCSprite spriteWithFile:@"bg1.jpg"];
    } else if ([skin isEqualToString:@"space"]) {
        bgSprite =  [CCSprite spriteWithFile:@"bg1black.jpg"];
        bgSprite.opacity=.1;
    }
    else {
         bgSprite =  [CCSprite spriteWithFile:@"consolebg.jpg"];
    }
     
    
    bgDisplay=[CC3Billboard nodeWithBillboard:bgSprite];
    bgDisplay.location=cc3v(0,0,-8);
    bgDisplay.uniformScale=.02;
   
    
    [self addChild:bgDisplay];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[CCDirector sharedDirector] openGLView].window animated:YES];
    
    hud.labelText = @"Preparing Hierarchy...";
    [self queryStats];
    
	sphereMaster = (roleNode*)[self getNodeNamed: @"Sphere"];
  
    sphereMaster.uniformScale=.4;
    //sphereMaster.color=ccc3(150, 150, 150);
    //sphereMaster.ambientColor=ccc4f(.25, .25, .25, 1);
    //sphereMaster.diffuseColor=ccc4f(.4, .4, .4, 1);
    //sphereMaster.specularColor=ccc4f(0.774597, 0.774597, 0.774597, 1);
    
    sphereMaster.isTouchEnabled=YES;
    if ([skin isEqualToString:@"console"]) {
        sphereMaster.shouldUseLighting=NO;
    }
    
    helloTxt = (roleNode*)[sphereMaster copyAutoreleased];
    [self addAndLocalizeChild:helloTxt];
    helloTxt.name=@"Sphere";
    sphereMaster.name=@"Master";
    helloTxt.uniformScale=.5;
    cam.targetLocation=CC3VectorAdd(helloTxt.location,cc3v(0,-1.5,0));
   
   
   
   
    sphereMaster.visible=NO;
	currLevel=0;
    nowIndex=0;
    
    
    
}

-(void) queryStats {
    
    //NSLog(@"%i",theseVars.dateFilter);
    NSString *thisQuery=@"SELECT Owner.UserRoleId, IsClosed, IsWon, COUNT(Id), SUM(Amount) From Opportunity ";
     thisQuery=[thisQuery stringByAppendingString:[self buildString]];
    thisQuery=[thisQuery stringByAppendingString:[self buildRecTypeClause]];
    
    thisQuery=[thisQuery stringByAppendingString:@" GROUP BY Owner.UserRoleId, IsClosed, IsWon ORDER BY Owner.UserRoleId "];
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:thisQuery];
    
    [[SFRestAPI sharedInstance] send:request delegate:self]; 
}

-(void) queryDetails {
    
    queryType=3;
    //NSLog(@"%i",theseVars.dateFilter);
    NSString *thisQuery=@"SELECT StageName, COUNT(Id), SUM(Amount) From Opportunity ";
    thisQuery=[thisQuery stringByAppendingString:[self buildString]];
    thisQuery=[thisQuery stringByAppendingString:[self buildRecTypeClause]];
    
    thisQuery=[thisQuery stringByAppendingString:@" GROUP BY StageName ORDER BY Owner.UserRoleId "];
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:thisQuery];
    
    [[SFRestAPI sharedInstance] send:request delegate:self]; 
}

-(NSString*) buildString {
    
    NSString *returnString;
    
    switch (theseVars.dateFilter) {
        case 1:
            returnString=@" WHERE CloseDate=THIS_FISCAL_YEAR";
            theseVars.filterText=@"This Fiscal Year";
            break;
        case 2:
            returnString=@" WHERE CloseDate=LAST_FISCAL_YEAR";
            theseVars.filterText=@"Last Fiscal Year";
            break;
        case 3:
            returnString=@" WHERE (CloseDate=LAST_FISCAL_YEAR OR CloseDate=THIS_FISCAL_YEAR)";
            theseVars.filterText=@"Current & Last Fiscal Year";
            break;
        case 4:
            returnString=@" WHERE CloseDate=THIS_YEAR";
            theseVars.filterText=@"This Calendar Year";
            break;
        case 5:
            returnString=@" WHERE CloseDate=LAST_YEAR";
            theseVars.filterText=@"Last Calendar Year";
            break;
        case 6:
            returnString=@" WHERE (CloseDate=LAST_YEAR OR CloseDate=THIS_YEAR)";
            theseVars.filterText=@"Current & Last Calendar Year";
            break;
        case 7:
            returnString=@" WHERE CloseDate=THIS_FISCAL_QUARTER";
            theseVars.filterText=@"This Fiscal Quarter";
            break;
        case 8:
            returnString=@" WHERE CloseDate=LAST_FISCAL_QUARTER";
            theseVars.filterText=@"Last Fiscal Quarter";
            break;
        case 9:
            returnString=@" WHERE (CloseDate=LAST_FISCAL_QUARTER OR CloseDate=THIS_FISCAL_QUARTER)";
            theseVars.filterText=@"Current & Last Fiscal Quarter";
            break;
        case 10:
            returnString=@" WHERE CloseDate=THIS_QUARTER";
            theseVars.filterText=@"This Calendar Quarter";
            break;
        case 11:
            returnString=@" WHERE CloseDate=LAST_QUARTER";
            theseVars.filterText=@"Last Calendar Quarter";
            break;
        case 12:
            returnString=@" WHERE (CloseDate=LAST_QUARTER OR CloseDate=THIS_QUARTER)";
            theseVars.filterText=@"Current & Last Calendar Q";
            break;

        case 13:
            returnString=@" WHERE CloseDate=THIS_MONTH";
            theseVars.filterText=@"This Calendar Month";
            break;
        case 14:
            returnString=@" WHERE CloseDate=LAST_MONTH";
            theseVars.filterText=@"Last Calendar Month";
            break;
        case 15:
            returnString=@" WHERE (CloseDate=LAST_MONTH OR CloseDate=THIS_MONTH)";
            theseVars.filterText=@"Current & Last Calendar M";
            break;
            
        default:
            break;
    }
    
    return returnString;
    
}

-(NSString*) buildRecTypeClause {
    
    NSString *recTypeClause=@" AND RecordTypeId IN ('";

    NSString *result =  [[theseVars.recordTypes valueForKey:@"Id"] componentsJoinedByString:@"','"];
    recTypeClause=[recTypeClause stringByAppendingString:result];
    recTypeClause=[recTypeClause stringByAppendingString:@"') "];
    
    return recTypeClause;
    
    
    
}

-(void) buildTree {
    
    if ([_currentLevel count]>0) {
        
    
    queryType=3;
    NSDictionary *obj = [_currentLevel objectAtIndex:nowIndex];
    int startLevel=[[obj objectForKey:@"Level"] integerValue];
    NSMutableArray *parents=[[NSMutableArray alloc] init];
    NSMutableArray *allKids=[[NSMutableArray alloc] init];
    [parents addObject:[obj objectForKey:@"Id"]];
    startLevel=startLevel+1;

    while (startLevel<=theseVars.hierLevels) {
        NSIndexSet *nextChildren = [theseVars.records indexesOfObjectsPassingTest:^(id obj3, NSUInteger idx, BOOL * stop){ 
            
            int myLevel=(int)[[obj3 objectForKey:@"Level"] integerValue];
            
            BOOL isLevel;
            if (myLevel==startLevel) {
                isLevel=true;
            }
            else{
                isLevel=false;
            }
            BOOL isChild = [parents containsObject:[obj3 objectForKey:@"ParentRoleId"]];
            if (isLevel==true && isChild==true) {
                [parents addObject:[obj3 objectForKey:@"Id"]];
            }
            return (BOOL)(isLevel==true && isChild==true);                
        }];
        
        [allKids addObjectsFromArray:[theseVars.records objectsAtIndexes:nextChildren]];
        
        startLevel++;
        
    }
    NSString *thisQuery=@"SELECT StageName, AVG(Probability), COUNT(Id), SUM(Amount) From Opportunity ";
    thisQuery=[thisQuery stringByAppendingString:[self buildString]];
    NSString *roleClause=@" AND Owner.UserRoleId IN ('";
    roleClause=[roleClause stringByAppendingString:[obj objectForKey:@"Id"]];
    roleClause=[roleClause stringByAppendingString:@"','"];
    NSString *result =  [[allKids valueForKey:@"Id"] componentsJoinedByString:@"','"];
    roleClause=[roleClause stringByAppendingString:result];
    roleClause=[roleClause stringByAppendingString:@"') "];
    thisQuery=[thisQuery stringByAppendingString:roleClause];
    thisQuery=[thisQuery stringByAppendingString:@" GROUP BY StageName ORDER BY AVG(Probability) "];
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:thisQuery];
    
    [[SFRestAPI sharedInstance] send:request delegate:self]; 
   
    }
    
}

-(void) buildStats {
    
    // set base metrics
    for (NSMutableDictionary *obj in theseVars.records) {
        NSIndexSet *firstMetrics = [theseVars.metrics indexesOfObjectsPassingTest:^(id obj2, NSUInteger idx, BOOL * stop){ 
            return ([[obj objectForKey:@"Id"] isEqualToString:[obj2 objectForKey:@"UserRoleId"]]);
            
        }];
        NSInteger numOpptys;
        NSInteger sumValues;
        NSInteger sumClosed;
        NSInteger sumWon;
        //NSLog(@"Count for Role %@ is: %d", [obj objectForKey:@"Name"],[firstMetrics count]);
        if ([firstMetrics count]>0 && ![firstMetrics  isEqual:[NSNull null]] ) {
            
            NSArray *firstResults=[[NSArray alloc] init];
            firstResults = [theseVars.metrics objectsAtIndexes:firstMetrics];
            numOpptys=[[firstResults valueForKeyPath:@"@sum.expr0"] integerValue];
            if ([firstResults valueForKeyPath:@"@sum.expr1"] != [NSNull null]) {

            sumValues=[[firstResults valueForKeyPath:@"@sum.expr1"] integerValue];
            }
            else {
                sumValues=0;  
            }
            sumClosed=[[firstResults valueForKeyPath:@"@sum.IsClosed"] integerValue];
            sumWon=[[firstResults valueForKeyPath:@"@sum.IsWon"] integerValue];
            
            
        }
        else {
            
            numOpptys=0;
            sumValues=0;
            sumClosed=0;
            sumWon=0;
            
        }
        
        //NSLog(@"role=%@ count=%d value=%d",[obj objectForKey:@"Id"],numOpptys,sumValues);
        [obj setValue:[NSNumber numberWithInt:sumClosed] forKey:@"numClosed"];
        [obj setValue:[NSNumber numberWithInt:numOpptys] forKey:@"numOpptys"];
        [obj setValue:[NSNumber numberWithInt:sumValues] forKey:@"totValue"];
        [obj setValue:[NSNumber numberWithInt:sumWon] forKey:@"numWon"];
        
        int startLevel=[[obj objectForKey:@"Level"] integerValue];
        NSMutableArray *parents=[[NSMutableArray alloc] init];
        NSMutableArray *allKids=[[NSMutableArray alloc] init];
        [parents addObject:[obj objectForKey:@"Id"]];
        startLevel=startLevel+1;
        
        while (startLevel<=theseVars.hierLevels) {
            NSIndexSet *nextChildren = [theseVars.records indexesOfObjectsPassingTest:^(id obj3, NSUInteger idx, BOOL * stop){ 
                
                int myLevel=(int)[[obj3 objectForKey:@"Level"] integerValue];
                
                BOOL isLevel;
                if (myLevel==startLevel) {
                    isLevel=true;
                }
                else{
                    isLevel=false;
                }
                BOOL isChild = [parents containsObject:[obj3 objectForKey:@"ParentRoleId"]];
                if (isLevel==true && isChild==true) {
                    [parents addObject:[obj3 objectForKey:@"Id"]];
                }
                return (BOOL)(isLevel==true && isChild==true);                
            }];
            
            [allKids addObjectsFromArray:[theseVars.records objectsAtIndexes:nextChildren]];
            
            startLevel++;
            
        }
        int pipelineOpptys; 
        int pipelineValue; 
        int pipelineClosed;
        int pipelineWon;
        if ([allKids count]>0) {
            NSMutableArray *kidIds=[allKids mutableArrayValueForKey:@"Id"];
            NSIndexSet *pipeMetrics = [theseVars.metrics indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL * stop){ 
                return [kidIds containsObject:[obj objectForKey:@"UserRoleId"]];
                
                
            }];
            NSArray *pipeResults = (NSMutableArray*)[theseVars.metrics objectsAtIndexes:pipeMetrics];
            pipelineClosed=[[pipeResults valueForKeyPath:@"@sum.IsClosed"] integerValue] + sumClosed;
            pipelineOpptys=[[pipeResults valueForKeyPath:@"@sum.expr0"] integerValue] + numOpptys;
            pipelineValue=[[pipeResults valueForKeyPath:@"@sum.expr1"] integerValue] + sumValues;
            pipelineWon=[[pipeResults valueForKeyPath:@"@sum.IsWon"] integerValue] + sumWon;
            
        }
        else {
            pipelineOpptys=0 + numOpptys;
            pipelineClosed=0 + sumClosed;
            pipelineValue=0 +sumValues;
            pipelineWon = 0 + sumWon;
        }
        //NSLog(@"role=%@ count=%i closed=%i pipeline=%i value=%i",[obj objectForKey:@"Name"],[allKids count],pipelineClosed,pipelineOpptys,pipelineValue);
        [obj setValue:[NSNumber numberWithInt:pipelineClosed] forKey:@"pipeClosed"];
        [obj setValue:[NSNumber numberWithInt:pipelineOpptys] forKey:@"pipeOpptys"];
        [obj setValue:[NSNumber numberWithInt:pipelineValue] forKey:@"pipeValue"];
        [obj setValue:[NSNumber numberWithInt:pipelineWon] forKey:@"pipeWon"];
    }
    
    NSLog(@"StatsDone");    
}

-(void) indexRight {
    
    theseVars.transitionText=YES;
    CC3Node *lastNode=[_nodes objectAtIndex:nowIndex];
    [lastNode stopAllActions];
    
    int i=0; 
    
    if ((nowIndex)<levCount-1)
    {
    nowIndex++; 

        float changePer = (float)(360/levCount);
        float changeDegrees = (float)((i/(float)levCount)*360)+90-(changePer*nowIndex);
        float alpha = changeDegrees * (M_PI/ 180) ;
        
        //float ellipseX = 4.5 * cos(alpha);  //changed from 80
        //float ellipseY = 3.5 * sin(alpha);
       

       
        [helloTxt runAction:[CC3RotateBy actionWithDuration: 0.5
                                                   rotateBy: cc3v(0.0, changePer, 0.0)]];
        
       
        i++;
    //}
    
    }
    NSDictionary *obj = [_currentLevel objectAtIndex:nowIndex];
    NSString *textName = @"Highlighted Role: ";
    textName = [textName stringByAppendingString:[obj objectForKey:@"Name"]];
    textName = [textName stringByAppendingString:@"\n Opptys for Role: "];
    textName = [textName stringByAppendingFormat:@"%i",[[obj objectForKey:@"numOpptys"] integerValue]];
    textName = [textName stringByAppendingString:@"\n Opptys Closed for Role: "];
    textName = [textName stringByAppendingFormat:@"%i",[[obj objectForKey:@"numClosed"] integerValue]];
    textName = [textName stringByAppendingString:@"\n Opptys in Pipeline: "];
    textName = [textName stringByAppendingFormat:@"%i",[[obj objectForKey:@"pipeOpptys"] integerValue]];
    textName = [textName stringByAppendingString:@"\n Opptys Closed in Pipeline: "];
    textName = [textName stringByAppendingFormat:@"%i",[[obj objectForKey:@"pipeClosed"] integerValue]];
    textName = [textName stringByAppendingString:@"\n Pipeline Value: "];
    textName = [textName stringByAppendingFormat:@"%i",[[obj objectForKey:@"pipeValue"] integerValue]];
    
    
    theseVars.statText=textName;
    
    CC3Node *currNode=[_nodes objectAtIndex:nowIndex];
    glowNode.location=currNode.location;
    glowNode.shouldInheritTouchability=NO;
    glowNode.shouldUseLighting=FALSE;
    glowNode.isTouchEnabled=NO;
    glowNode.color=currNode.color;
    float myScale=currNode.uniformScale;
    float lowScale=myScale*.95;
    
    CC3ScaleTo *scaleIn = [CC3ScaleTo actionWithDuration:0.75 scaleTo:cc3v(lowScale,lowScale,lowScale)];
    CC3ScaleTo *scaleOut =   [CC3ScaleTo actionWithDuration:0.75 scaleTo:cc3v(myScale,myScale,myScale)];
    
    CCSequence *pulseSequence = [CCSequence actionOne:scaleIn two:scaleOut];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
    [currNode runAction:repeat];
    
  
    
}

-(void) indexLeft {
    
    theseVars.transitionText=YES; 
    CC3Node *lastNode=[_nodes objectAtIndex:nowIndex];
    [lastNode stopAllActions];
    int i=0; 
    
    if ((nowIndex)>0)
    {
        nowIndex=nowIndex-1; 

        float changePer = (float)(360/levCount);
        float changeDegrees = (float)((i/(float)levCount)*360)+90-(changePer*nowIndex);
        //float alpha = changeDegrees * (M_PI/ 180) ;
        //float ellipseX = 4.5 * cos(alpha);  //changed from 80
        //float ellipseY = 3.5 * sin(alpha);
        //[thisNode runAction:[CC3MoveTo actionWithDuration:1.0 moveTo:cc3v(ellipseX,-1,ellipseY)]];
        
        [helloTxt runAction:[CC3RotateBy actionWithDuration: 0.5
                                                   rotateBy: cc3v(0.0, -changePer, 0.0)]];
       
                i++;
           
    }
    NSDictionary *obj = [_currentLevel objectAtIndex:nowIndex];
    NSString *textName = @"Highlighted Role: ";
    textName = [textName stringByAppendingString:[obj objectForKey:@"Name"]];
    textName = [textName stringByAppendingString:@"\n Opptys for Role: "];
    textName = [textName stringByAppendingFormat:@"%i",[[obj objectForKey:@"numOpptys"] integerValue]];
    textName = [textName stringByAppendingString:@"\n Opptys Closed for Role: "];
    textName = [textName stringByAppendingFormat:@"%i",[[obj objectForKey:@"numClosed"] integerValue]];
    textName = [textName stringByAppendingString:@"\n Opptys in Pipeline: "];
    textName = [textName stringByAppendingFormat:@"%i",[[obj objectForKey:@"pipeOpptys"] integerValue]];
    textName = [textName stringByAppendingString:@"\n Opptys Closed in Pipeline: "];
    textName = [textName stringByAppendingFormat:@"%i",[[obj objectForKey:@"pipeClosed"] integerValue]];
    textName = [textName stringByAppendingString:@"\n Pipeline Value: "];
    textName = [textName stringByAppendingFormat:@"%i",[[obj objectForKey:@"pipeValue"] integerValue]];
   theseVars.statText=textName;
    
    CC3Node *currNode=[_nodes objectAtIndex:nowIndex];
    glowNode.location=currNode.location;
    glowNode.shouldInheritTouchability=NO;
    glowNode.shouldUseLighting=FALSE;
    glowNode.isTouchEnabled=NO;
    glowNode.color=currNode.color;
    float myScale=currNode.uniformScale;
    float lowScale=myScale*.95;
    
    CC3ScaleTo *scaleIn = [CC3ScaleTo actionWithDuration:0.75 scaleTo:cc3v(lowScale,lowScale,lowScale)];
    CC3ScaleTo *scaleOut =   [CC3ScaleTo actionWithDuration:0.75 scaleTo:cc3v(myScale,myScale,myScale)];
    
    CCSequence *pulseSequence = [CCSequence actionOne:scaleIn two:scaleOut];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
    [currNode runAction:repeat];
    
   
}


-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {
	NSLog(aNode.name);
    if ([aNode.name isEqualToString:@"Node"]) {
         
    roleNode *thisNode = (roleNode*) aNode;
    prevId=thisId;
    thisId = thisNode.roleId;
    thisName = thisNode.roleName;
    thisColor = thisNode.color;
    currLevel=currLevel+1;
    [self animateTransition];
      
    }
    else if ([aNode.name isEqualToString:@"Sphere"]) {
       
        NSLog(@"Root clicked");
        
        if (currLevel>0) {
            currLevel=currLevel-1;
            if (currLevel>0) {
                thisId=prevId;
                NSUInteger newRootIndex = [theseVars.records indexOfObjectPassingTest:^(id obj3, NSUInteger idx, BOOL * stop){ 
                    
                    return [[obj3 objectForKey:@"Id"]  isEqualToString:thisId];               
                }];
                NSDictionary *newObj=[theseVars.records objectAtIndex:newRootIndex];
                
                thisName=[newObj objectForKey:@"Name"];
                prevId=[newObj objectForKey:@"ParentRoleId"];
            }
            [self animateBackUp];
        }
        
        
        
    }
    
       
    
}


-(void)animateTransition {
    
    
    
    helloTxt.visible=NO;
    [helloTxt removeChild:glowNode];
    for (roleNode *node in _nodes) {
        node.isTouchEnabled=NO;
        if (node.roleId!=thisId) {
            [node stopAllActions];
            [self addAndLocalizeChild:node];
            [node runAction:[CCFadeOut actionWithDuration:2]];
            [node runAction:[CC3MoveBy actionWithDuration:2 moveBy:cc3v(0,5,0)]];
        }
        else {
            [node stopAllActions];
            [self addAndLocalizeChild:node];
            [node runAction:[CC3ScaleTo actionWithDuration:1.5 scaleTo:cc3v(.4,.4,.4)]];
            [node runAction:[CC3MoveTo actionWithDuration:1.5 moveTo:helloTxt.location]];
        }
    }
    for (CC3LineNode *thisLine in _lines)  {
        
        [helloTxt removeChild:thisLine];
        
    }
    CCActionInterval* waitThreeSec = [CCDelayTime actionWithDuration: 2.5];
    CCActionInstant* cleanUp = [CCCallFunc actionWithTarget: self selector: @selector(setupRoot)];
    [self runAction: [CCSequence actionOne: waitThreeSec two: cleanUp]];
    
}

-(void)animateBackUp {
    
    
    
    helloTxt.visible=NO;
    [helloTxt removeChild:glowNode];
    for (roleNode *node in _nodes) {
        node.isTouchEnabled=NO;
        if (node.roleId!=thisId) {
            [node stopAllActions];
            [self addAndLocalizeChild:node];
            [node runAction:[CCFadeOut actionWithDuration:2]];
            [node runAction:[CC3MoveBy actionWithDuration:2 moveBy:cc3v(0,-5,0)]];
        }
        else {
            [node stopAllActions];
            [self addAndLocalizeChild:node];
            [node runAction:[CC3ScaleTo actionWithDuration:1.5 scaleTo:cc3v(.4,.4,.4)]];
            [node runAction:[CC3MoveTo actionWithDuration:1.5 moveTo:helloTxt.location]];
        }
    }
    for (CC3LineNode *thisLine in _lines)  {
        
        [helloTxt removeChild:thisLine];
        
    }
    CCActionInterval* waitThreeSec = [CCDelayTime actionWithDuration: 2.5];
    CCActionInstant* cleanUp;
    if (currLevel>0) {
        cleanUp = [CCCallFunc actionWithTarget: self selector: @selector(setupRoot)];
    } else {
        cleanUp = [CCCallFunc actionWithTarget: self selector: @selector(setupRoot)];
    }
    
    [self runAction: [CCSequence actionOne: waitThreeSec two: cleanUp]];
    
}


-(void) reQuery {
    [theseVars.records setValue:[NSNumber numberWithInt:0] forKey:@"numOpptys"];
    [theseVars.records setValue:[NSNumber numberWithInt:0] forKey:@"totValue"];
    [theseVars.records setValue:[NSNumber numberWithInt:0] forKey:@"numClosed"];
    [theseVars.records setValue:[NSNumber numberWithInt:0] forKey:@"numWon"];
    [theseVars.records setValue:[NSNumber numberWithInt:0] forKey:@"pipeOpptys"];
    [theseVars.records setValue:[NSNumber numberWithInt:0] forKey:@"pipeValue"];
    [theseVars.records setValue:[NSNumber numberWithInt:0] forKey:@"pipeClosed"];
    [theseVars.records setValue:[NSNumber numberWithInt:0] forKey:@"pipeWon"];
    [theseVars.metrics removeAllObjects];
    queryType=2;
    
    [self queryStats];
   
    
    
}



-(void) setupRoot {
    NSLog(@"Setting up Again");
    helloTxt.visible=YES;
    [self registerDefaultsFromSettingsBundle];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs synchronize];
    
	skin = [defs stringForKey:@"skin_pref"];
    sizeMetric=[defs stringForKey:@"size_metric"];    
    colorMetric=[defs objectForKey:@"color_metric"];
    for (roleNode *node in _nodes) {
        
        //[node remove];
        [self removeChild:node];
        
    }
    for (CC3LineNode *thisLine in _lines)  {
        
        [helloTxt removeChild:thisLine];
        
    }
    [_currentLevel removeAllObjects];
    [_nodes removeAllObjects];
    [_lines removeAllObjects];
    
    
    int maxOpptys = 0;
    int minOpptys = 0;
    helloTxt.rotation=cc3v(0,0,0);
    if (currLevel==0) {
        theseVars.navText=@"At top of hierarchy.  Viewing top-level role.\nClick a child to drill down to the next level.";
        helloTxt.color=ccGRAY;
         
    }
    else {
        NSString *navUpdate=@"Viewing children of ";
        navUpdate=[navUpdate stringByAppendingString:thisName];
        navUpdate=[navUpdate stringByAppendingString:@".\nClick root to move up a level.\nClick a child to drill down to the next level."];
        theseVars.navText=navUpdate; 
        helloTxt.color=thisColor;

       
        
    }

    NSIndexSet *firstLevel;
    if (currLevel==0) {
       firstLevel = [theseVars.records indexesOfObjectsPassingTest:^(id obj3, NSUInteger idx, BOOL * stop){ 
            
            int myLevel=(int)[[obj3 objectForKey:@"Level"] integerValue];
            return (BOOL)(myLevel==1);               
        }];
        
        NSLog(@"Using Level 0");
    }
    
    else {
    
    firstLevel = [theseVars.records indexesOfObjectsPassingTest:^(id obj3, NSUInteger idx, BOOL * stop){ 
        
        return [[obj3 objectForKey:@"ParentRoleId"]  isEqualToString:thisId];               
    }];
        
        NSLog(@"Using Parent Role ID");
    }
    
    int lev1Count=[[theseVars.records objectsAtIndexes:firstLevel] count];
    levCount=lev1Count;
    
    int i=0;
    [_currentLevel addObjectsFromArray:[theseVars.records objectsAtIndexes:firstLevel]];
    
    //Set size comparators
    if ([sizeMetric isEqualToString:@"sizecount"])
    {    
    maxOpptys=[[_currentLevel valueForKeyPath:@"@max.pipeOpptys"] integerValue];
    minOpptys=[[_currentLevel valueForKeyPath:@"@min.pipeOpptys"] integerValue];
    }
    else
    {
    maxOpptys=[[_currentLevel valueForKeyPath:@"@max.pipeValue"] integerValue];
    minOpptys=[[_currentLevel valueForKeyPath:@"@min.pipeValue"] integerValue];   
        
    }
    
    
    if (minOpptys==maxOpptys) {
        minOpptys=0;
    }
    
    
        
    for (NSDictionary *obj in [theseVars.records objectsAtIndexes:firstLevel]) {
        

        roleNode* body;
        body = (roleNode*)[sphereMaster copyWithName:@"Node" asClass:[roleNode class]];
        body.visible=YES;
        body.isTouchEnabled=YES;
        body.opacity=255;
        body.roleId=[obj objectForKey:@"Id"];
        body.roleName=[obj objectForKey:@"Name"];
        body.pipeOpptys=[[obj objectForKey:@"pipeOpptys"] integerValue]; 
        body.pipeValue=[[obj objectForKey:@"pipeValue"] integerValue];
        camDegrees = (float)((i/(float)lev1Count)*359)+85;
        
        
        float alpha = camDegrees * (M_PI/ 180) ;
        
        float ellipseX = 4.5 * cos(alpha);  //changed from 80
        float ellipseY = 3.5 * sin(alpha);
        
        
        body.location= cc3v(ellipseX,-3,ellipseY);
        CC3LineNode* thisLine;
        thisLine = [CC3LineNode nodeWithName: @"Line"];
        CC3Vector vertices[2];
        vertices[0]=body.location;
        vertices[1]=helloTxt.location;
        [thisLine populateAsLineStripWith:2 vertices: vertices andRetain:YES];
        thisLine.lineWidth=3;
        thisLine.color=ccWHITE;
        [helloTxt addChild:thisLine];
        [_lines addObject:thisLine];
        
        //Set object size
        if ([sizeMetric isEqualToString:@"sizecount"])
        {   
            if (body.pipeOpptys>0) {
                float thisScale=(float)body.pipeOpptys/(float)(maxOpptys-minOpptys);
                
                body.uniformScale=.35+(.3*thisScale);
      
            }
            else {
                body.uniformScale=.35;
            }
        }
        else
        {
            if (body.pipeValue>0) {
                float thisScale=(float)body.pipeValue/(float)(maxOpptys-minOpptys);
                
                body.uniformScale=.35+(.3*thisScale);
               
            }
            else {
                body.uniformScale=.35;
            }   
            
            
        }
        
        float closePer;
        body.pipeClosed=[[obj objectForKey:@"pipeClosed"] integerValue];
        body.pipeWon=[[obj objectForKey:@"pipeWon"] integerValue];
        if ([colorMetric isEqualToString:@"colwinper"]) {
        
            if (body.pipeClosed>0) {
                closePer=(float)body.pipeWon/(float)body.pipeClosed;
            }
            if (body.pipeOpptys>0) {
                body.color=[self metricColor:closePer];
            }
            else
            {
                
                body.color=ccGRAY;
                
            }

        
        }
        
        else {
            
            if (body.pipeOpptys>0) {
                closePer=(float)body.pipeClosed/(float)body.pipeOpptys;
                NSLog(@"Close Percentage:, %f",closePer);

            }
            if (body.pipeOpptys>0) {
                body.color=[self metricColor:closePer];
            }
            else
            {
                
                body.color=ccGRAY;
                
            } 
            
            
        }
        
    

        [_nodes addObject:body]; 
        
       
        
        
        
        [thisLine addChild:body];
        
        
        i++;
       
        
        //Do immediate children
        
        NSIndexSet *nextKids = [theseVars.records indexesOfObjectsPassingTest:^(id obj4, NSUInteger idx, BOOL * stop){ 
            
            
            return [[obj4 objectForKey:@"ParentRoleId"]  isEqualToString:body.roleId];             
        }];
        int j=0;
        int kidsCount=[[theseVars.records objectsAtIndexes:nextKids] count];
        for (NSDictionary *obj2 in [theseVars.records objectsAtIndexes:nextKids]) {
            
            roleNode* body2;
            //body = [roleNode nodeWithName:@"Node"];
            body2 = (roleNode*)[sphereMaster copyWithName:@"Dummy" asClass:[roleNode class]];
            body2.visible=YES;
            body2.shouldInheritTouchability=NO;
            body2.isTouchEnabled=NO;
            body2.opacity=255;
            body2.roleId=[obj2 objectForKey:@"Id"];
            body2.pipeOpptys=[[obj2 objectForKey:@"pipeOpptys"] integerValue];
            body2.pipeValue=[[obj2 objectForKey:@"pipeValue"] integerValue];
            camDegrees2 = (float)((j/(float)kidsCount)*359)+85;
            
            
            float alpha2 = camDegrees2 * (M_PI/ 180) ;
            
            float ellipseX2 = ((3.5) * cos(alpha2));  //changed from 80
            float ellipseY2 = ((2.5) * sin(alpha2));
            
            
            body2.location= cc3v(ellipseX2,-3,ellipseY2);
            CC3LineNode* thisLine2;
            thisLine2 = [CC3LineNode nodeWithName: @"Line2"];
            CC3Vector vertices2[2];
            vertices2[0]=body2.location;
            vertices2[1]=body.globalLocation;
            [thisLine2 populateAsLineStripWith:2 vertices: vertices2 andRetain:YES];
            thisLine2.lineWidth=3;
            
            [body addChild:thisLine2];
            [_lines addObject:thisLine2];
           
            if (body2.pipeOpptys>0) {
                //float thisScale=(float)(maxOpptys-minOpptys)/(float)body2.pipeOpptys;
                
                body2.uniformScale=.2;
            }
            else {
                body2.uniformScale=.2;
            }
            float closePer2;
            body2.pipeClosed=[[obj2 objectForKey:@"pipeClosed"] integerValue];
            body2.pipeWon=[[obj2 objectForKey:@"pipeWon"] integerValue];
            
            if ([colorMetric isEqualToString:@"colwinper"]) {
                if (body2.pipeClosed>0) {
                    closePer2=(float)body2.pipeWon/(float)body2.pipeClosed;
                }
                
                [thisLine2 addChild:body2];
                thisLine2.color=ccWHITE;
                if (body2.pipeOpptys>0) {
                   body2.color= [self metricColor:closePer2];
                }
                else
                {
                    
                    body2.color=ccGRAY;
                    
                } 
            }
            else {
                
                if (body2.pipeOpptys>0) {
                    closePer2=(float)body2.pipeClosed/(float)body2.pipeOpptys;
                    NSLog(@"Close Percentage:, %f",closePer2);
                }
                
                [thisLine2 addChild:body2];
                thisLine2.color=ccWHITE;
                if (body2.pipeOpptys>0) {
                    body2.color= [self metricColor:closePer2];
                }
                else
                {
              
                    body2.color=ccGRAY;
                    
                }               
                
                
            }
            
            
            
            j++;
            
        }

            
            
        
    }  
    //currLevel=0;
    if ([_currentLevel count]>0) {
        
    NSDictionary *firstObj = [_currentLevel objectAtIndex:0];
        NSString *textName = @"Highlighted Role: ";
        textName = [textName stringByAppendingString:[firstObj objectForKey:@"Name"]];
        textName = [textName stringByAppendingString:@"\n Opptys for Role: "];
        textName = [textName stringByAppendingFormat:@"%i",[[firstObj objectForKey:@"numOpptys"] integerValue]];
        textName = [textName stringByAppendingString:@"\n Opptys Closed for Role: "];
        textName = [textName stringByAppendingFormat:@"%i",[[firstObj objectForKey:@"numClosed"] integerValue]];
        textName = [textName stringByAppendingString:@"\n Opptys in Pipeline: "];
        textName = [textName stringByAppendingFormat:@"%i",[[firstObj objectForKey:@"pipeOpptys"] integerValue]];
        textName = [textName stringByAppendingString:@"\n Opptys Closed in Pipeline: "];
        textName = [textName stringByAppendingFormat:@"%i",[[firstObj objectForKey:@"pipeClosed"] integerValue]];
        textName = [textName stringByAppendingString:@"\n Pipeline Value: "];
        textName = [textName stringByAppendingFormat:@"%i",[[firstObj objectForKey:@"pipeValue"] integerValue]];
    theseVars.statText=textName;
    
    CC3Node *currNode=[_nodes objectAtIndex:0];
    glowNode=[sphereMaster copyWithName:@"Glower"];
    glowNode.opacity=75;
    glowNode.uniformScale=currNode.uniformScale*1.2;
    
    
    glowNode.visible=YES;
    [helloTxt addChild:glowNode];
    glowNode.location=currNode.location;
    glowNode.shouldInheritTouchability=NO;
    glowNode.shouldUseLighting=FALSE;
    glowNode.isTouchEnabled=NO;
    glowNode.color=currNode.color;
    float myScale=currNode.uniformScale;
    float lowScale=myScale*.95;
    
    CC3ScaleTo *scaleIn = [CC3ScaleTo actionWithDuration:0.75 scaleTo:cc3v(lowScale,lowScale,lowScale)];
    CC3ScaleTo *scaleOut =   [CC3ScaleTo actionWithDuration:0.75 scaleTo:cc3v(myScale,myScale,myScale)];
    
    CCSequence *pulseSequence = [CCSequence actionOne:scaleIn two:scaleOut];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
    [currNode runAction:repeat];
    }
    sphereMaster.visible=NO;
	
    nowIndex=0;
    
}

-(void) refreshMetrics {
    
    NSLog(@"Refreshing Metrics");
    
    [_currentLevel removeAllObjects];
    NSIndexSet *nextLevel;
    NSArray *newLevel;
    if (currLevel>0) {
        nextLevel = [theseVars.records indexesOfObjectsPassingTest:^(id obj3, NSUInteger idx, BOOL * stop){ 
            
            return [[obj3 objectForKey:@"ParentRoleId"]  isEqualToString:thisId];               
        }];
       
        newLevel = [theseVars.records objectsAtIndexes:nextLevel];
        [_currentLevel addObjectsFromArray:newLevel];
    }
    else {
        nextLevel = [theseVars.records indexesOfObjectsPassingTest:^(id obj3, NSUInteger idx, BOOL * stop){ 
            
            int myLevel=(int)[[obj3 objectForKey:@"Level"] integerValue];
            return (BOOL)(myLevel==1);               
        }];
        newLevel = [theseVars.records objectsAtIndexes:nextLevel];
        [_currentLevel addObjectsFromArray:newLevel];
        
        
    }
    
    
    int maxOpptys;
    int minOpptys;
    if ([sizeMetric isEqualToString:@"sizecount"])
    {    
        maxOpptys=[[_currentLevel valueForKeyPath:@"@max.pipeOpptys"] integerValue];
        minOpptys=[[_currentLevel valueForKeyPath:@"@min.pipeOpptys"] integerValue];
    }
    else
    {
        maxOpptys=[[_currentLevel valueForKeyPath:@"@max.pipeValue"] integerValue];
        minOpptys=[[_currentLevel valueForKeyPath:@"@min.pipeValue"] integerValue];   
        
    }

    if (minOpptys==maxOpptys) {
        minOpptys=0;
    }
    
    for (roleNode *node in _nodes) {
        
        NSIndexSet *thisIndex = [newLevel indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL * stop){ 
            return [[obj objectForKey:@"Id"]  isEqualToString:node.roleId];
            
        }];
        NSArray *thisResult = [newLevel objectsAtIndexes:thisIndex];
       
        NSDictionary *thisObj = [thisResult objectAtIndex:0];
        [node stopAllActions];
       // if (node.numOpptys != [[thisObj valueForKey:@"numOpptys"] intValue]){
            node.pipeOpptys=[[thisObj objectForKey:@"pipeOpptys"] integerValue];
             node.pipeValue=[[thisObj objectForKey:@"pipeValue"] integerValue];
        if ([sizeMetric isEqualToString:@"sizecount"])
        { 
            if (node.pipeOpptys>0) {
                float thisScale=(float)node.pipeOpptys/(float)(maxOpptys-minOpptys);
               
                [node runAction:[CC3ScaleTo actionWithDuration:1 scaleTo:cc3v(.35+(.3*thisScale),.35+(.3*thisScale),.35+(.3*thisScale))]];
                
            }
            else {
                 
                [node runAction:[CC3ScaleTo actionWithDuration:1 scaleTo:cc3v(.35,.35,.35)]];
            }
        }
        else
        {
            if (node.pipeValue>0) {
                float thisScale=(float)node.pipeValue/(float)(maxOpptys-minOpptys);
                
                [node runAction:[CC3ScaleTo actionWithDuration:1 scaleTo:cc3v(.35+(.3*thisScale),.35+(.3*thisScale),.35+(.3*thisScale))]];
                
            }
            else {
                
                [node runAction:[CC3ScaleTo actionWithDuration:1 scaleTo:cc3v(.35,.35,.35)]];
            } 
            
            
            
        }
        
        
        float closePer2;
        node.pipeClosed=[[thisObj objectForKey:@"pipeClosed"] integerValue];
        node.pipeWon=[[thisObj objectForKey:@"pipeWon"] integerValue];
        
        if ([colorMetric isEqualToString:@"colwinper"]) {
            if (node.pipeClosed>0) {
                closePer2=(float)node.pipeWon/(float)node.pipeClosed;
            }
            
           
            if (node.pipeOpptys>0) {
                node.color=[self metricColor:closePer2];
            }
            
            else
            {
                //[node runAction:[CC3TintDiffuseTo actionWithDuration:1 colorTo:kCCC4FLightGray]];
                node.color=ccGRAY;
                
            }
        }
        else {
            
            if (node.pipeOpptys>0) {
                closePer2=(float)node.pipeClosed/(float)node.pipeOpptys;
            }
            
           
            if (node.pipeOpptys>0) {
                node.color=[self metricColor:closePer2];
            }
            
            else
            {
                //[node runAction:[CC3TintDiffuseTo actionWithDuration:1 colorTo:kCCC4FLightGray]];
                node.color=ccGRAY;
            }
            
            
            
        }
        
        
        //NSLog(@"%@ %@ Count: @%i Scale: @%f",node.roleId, [thisObj valueForKey:@"Id"],node.pipeOpptys,node.uniformScale);
    }
    CC3Node *currNode=[_nodes objectAtIndex:nowIndex];
    
    for (CC3LineNode *thisLine in _lines)  {
        
        NSString *thisName=thisLine.parent.name;
        if ([thisName isEqualToString:@"Node"]) {
            thisLine.color=ccWHITE;
        }
        
        
    }
    
    glowNode.color=currNode.color;
    
    if ([_currentLevel count]>0) {
        
        NSDictionary *firstObj = [_currentLevel objectAtIndex:nowIndex];
        NSString *textName = @"Highlighted Role: ";
        textName = [textName stringByAppendingString:[firstObj objectForKey:@"Name"]];
        textName = [textName stringByAppendingString:@"\n Opptys for Role: "];
        textName = [textName stringByAppendingFormat:@"%i",[[firstObj objectForKey:@"numOpptys"] integerValue]];
        textName = [textName stringByAppendingString:@"\n Opptys Closed for Role: "];
        textName = [textName stringByAppendingFormat:@"%i",[[firstObj objectForKey:@"numClosed"] integerValue]];
        textName = [textName stringByAppendingString:@"\n Opptys in Pipeline: "];
        textName = [textName stringByAppendingFormat:@"%i",[[firstObj objectForKey:@"pipeOpptys"] integerValue]];
        textName = [textName stringByAppendingString:@"\n Opptys Closed in Pipeline: "];
        textName = [textName stringByAppendingFormat:@"%i",[[firstObj objectForKey:@"pipeClosed"] integerValue]];
        textName = [textName stringByAppendingString:@"\n Pipeline Value: "];
        textName = [textName stringByAppendingFormat:@"%i",[[firstObj objectForKey:@"pipeValue"] integerValue]];
    theseVars.statText=textName;
    };
    
    float myScale=currNode.uniformScale;
    float lowScale=myScale*.95;
    
    CC3ScaleTo *scaleIn = [CC3ScaleTo actionWithDuration:0.75 scaleTo:cc3v(lowScale,lowScale,lowScale)];
    CC3ScaleTo *scaleOut =   [CC3ScaleTo actionWithDuration:0.75 scaleTo:cc3v(myScale,myScale,myScale)];
    
    CCSequence *pulseSequence = [CCSequence actionOne:scaleIn two:scaleOut];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
    [currNode runAction:repeat];
  
    
}

-(void) popoutDetails {
    
    //UIViewController *myViewController = [[UIViewController alloc] init];
    
    // Add the temporary UIViewController to the main OpenGL view
    //[[[CCDirector sharedDirector] openGLView] addSubview:myViewController.view];
    
    // Tell UIViewController to present the leaderboard
    
    TableViewController *tableViewController = [[TableViewController alloc] initWithStyle:UITableViewStylePlain];
    tableViewController.stages=_pipelineDetails;
    UIView *view = tableViewController.view;
    view.bounds=CGRectMake(0, 0, 480, 500); 
    view.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90.0f));
    //[myViewController presentModalViewController:tableViewController animated:YES];
    
    [[[CCDirector sharedDirector] openGLView] addSubview:view];
    
}

-(ccColor3B) metricColor: (float) metric {
    
    NSLog(@"Metric Received:, %f",metric);
  
    if (metric<=.2) {
        return ccRED;
    } 
    else if (metric >.2 && metric <=.3) {
        return ccORANGERED;
    }
    else if (metric >.3 && metric <=.4) {
        return ccORANGE;
    }
    else if (metric >.4 && metric <=.5) {
        return ccYELLOW;
    }
    else if (metric >.5 && metric <=.6) {
        return ccYELLOWGREEN;
    }
    else if (metric >.6 && metric <=.7) {
        return ccGREENYELLOW;
    }
    else if (metric >.7 && metric <=.8) {
        
        return ccLIGHTGREEN;
    }
    else {
        
        return ccGREEN;
    }
    
    
}

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides this node with an opportunity to perform update activities before
 * any changes are applied to the transformMatrix of the node. The similar and complimentary
 * method updateAfterTransform: is automatically invoked after the transformMatrix has been
 * recalculated. If you need to make changes to the transform properties (location, rotation,
 * scale) of the node, or any child nodes, you should override this method to perform those
 * changes.
 *
 * The global transform properties of a node (globalLocation, globalRotation, globalScale)
 * will not have accurate values when this method is run, since they are only valid after
 * the transformMatrix has been updated. If you need to make use of the global properties
 * of a node (such as for collision detection), override the udpateAfterTransform: method
 * instead, and access those properties there.
 *
 * The specified visitor encapsulates the CC3World instance, to allow this node to interact
 * with other nodes in its world.
 *
 * The visitor also encapsulates the deltaTime, which is the interval, in seconds, since
 * the previous update. This value can be used to create realistic real-time motion that
 * is independent of specific frame or update rates. Depending on the setting of the
 * maxUpdateInterval property of the CC3World instance, the value of dt may be clamped to
 * an upper limit before being passed to this method. See the description of the CC3World
 * maxUpdateInterval property for more information about clamping the updatobj2nterval.
 *
 * As described in the class documentation, in keeping with best practices, updating the
 * model state should be kept separate from frame rendering. Therefore, when overriding
 * this method in a subclass, do not perform any drawing or rending operations. This
 * method should perform model updates only.
 *
 * This method is invoked automatically at each scheduled update. Usually, the application
 * never needs to invoke this method directly.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {}

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides this node with an opportunity to perform update activities after
 * the transformMatrix of the node has been recalculated. The similar and complimentary
 * method updateBeforeTransform: is automatically invoked before the transformMatrix
 * has been recalculated.
 *
 * The global transform properties of a node (globalLocation, globalRotation, globalScale)
 * will have accurate values when this method is run, since they are only valid after the
 * transformMatrix has been updated. If you need to make use of the global properties
 * of a node (such as for collision detection), override this method.
 *
 * Since the transformMatrix has already been updated when this method is invoked, if
 * you override this method and make any changes to the transform properties (location,
 * rotation, scale) of any node, you should invoke the updateTransformMatrices method of
 * that node, to have its transformMatrix, and those of its child nodes, recalculated.
 *
 * The specified visitor encapsulates the CC3World instance, to allow this node to interact
 * with other nodes in its world.
 *
 * The visitor also encapsulates the deltaTime, which is the interval, in seconds, since
 * the previous update. This value can be used to create realistic real-time motion that
 * is independent of specific frame or update rates. Depending on the setting of the
 * maxUpdateInterval property of the CC3World instance, the value of dt may be clamped to
 * an upper limit before being passed to this method. See the description of the CC3World
 * maxUpdateInterval property for more information about clamping the update interval.
 *
 * As described in the class documentation, in keeping with best practices, updating the
 * model state should be kept separate from frame rendering. Therefore, when overriding
 * this method in a subclass, do not perform any drawing or rending operations. This
 * method should perform model updates only.
 *
 * This method is invoked automatically at each scheduled update. Usually, the application
 * never needs to invoke this method directly.
 */
-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
  
   
    
}

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    NSMutableArray *records = [jsonResponse objectForKey:@"records"];
    NSLog(@"request:didLoadResponse: #records: %d", records.count);
    if (queryType==1 || queryType==2) {
        [theseVars.metrics removeAllObjects];
        theseVars.metrics=records;
        // Zero null amounts
        NSIndexSet *nullAmounts;
        nullAmounts = [theseVars.metrics indexesOfObjectsPassingTest:^(id obj2, NSUInteger idx, BOOL * stop){ 
            return ([[obj2 objectForKey:@"expr1"] isEqual:[NSNull null]]);
            
        }];
        
        [[theseVars.metrics objectsAtIndexes:nullAmounts] setValue:[NSNumber numberWithInt:0] forKey:@"expr1"];
        [self buildStats];

    }
        if (queryType==1) {
         [MBProgressHUD hideHUDForView:[[CCDirector sharedDirector] openGLView].window animated:NO];
        [self setupRoot];
    }
    
    else if (queryType==2) {
        [self refreshMetrics];
        [MBProgressHUD hideHUDForView:[[CCDirector sharedDirector] openGLView].window animated:NO];
    }
    else if (queryType==3) {
        _pipelineDetails=records;
        [self popoutDetails];
        [MBProgressHUD hideHUDForView:[[CCDirector sharedDirector] openGLView].window animated:NO];
    }
    
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}

- (void)registerDefaultsFromSettingsBundle
{
    NSLog(@"Registering default values from Settings.bundle");
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs synchronize];
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    if(!settingsBundle)
    {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    
    for (NSDictionary *prefSpecification in preferences)
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if ([key isEqualToString:@"color_metric"] || [key isEqualToString:@"size_metric"] || [key isEqualToString:@"skin_pref"])
        {
            // check if value readable in userDefaults
            id currentObject = [defs objectForKey:key];
            if (currentObject == nil)
            {
                // not readable: set value from Settings.bundle
                id objectToSet = [prefSpecification objectForKey:@"DefaultValue"];
                [defaultsToRegister setObject:objectToSet forKey:key];
                NSLog(@"Setting object %@ for key %@", objectToSet, key);
            }
            else
            {
                // already readable: don't touch
                id objectToSet = [prefSpecification objectForKey:@"DefaultValue"];
                [defaultsToRegister setObject:objectToSet forKey:key];
                NSLog(@"Setting object %@ for key %@", objectToSet, key);
                //NSLog(@"Key %@ is readable (value: %@), nothing written to defaults.", key, currentObject);
            }
        }
    }
    
    [defs registerDefaults:defaultsToRegister];
    [defaultsToRegister release];
    [defs synchronize];
}


@end


/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "RootViewController.h"

#import "SBJson.h"
#import "SFRestAPI.h"
#import "SFRestRequest.h"
#import "Three_D_TemplateLayer.h"
#import "Three_D_TemplateWorld.h"
#import "CC3EAGLView.h"
#import "GameVars.h"
#import "MBProgressHUD.h"
#import "RolePickerController.h"
#import "RecordTypeTableController.h"
#import <QuartzCore/QuartzCore.h>


@implementation RootViewController

@synthesize dataRows;

UIWindow* window;
GameVars *theseVars;
int queryType;
NSString *pref;
UIView *controlsView;
NSMutableArray* opptyRecTypes;

#pragma mark Misc

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    self.dataRows = nil;
    [opptyRecTypes release];
    [super dealloc];
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    theseVars = [GameVars sharedGameVars];
    [self registerDefaultsFromSettingsBundle];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs synchronize];
    opptyRecTypes = [[NSMutableArray alloc] init];
    //pref = [defs stringForKey:@"start_node_pref"];
    self.title = @"Hierarchy Navigator";
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading...";
    hud.transform=CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90.0f));
    //Here we use a query that should work on either Force.com or Database.com
    queryType=1;
    theseVars.dateFilter=1;
    NSString *userQuery=@"SELECT Name, Username, UserRoleId, UserRole.Name FROM User WHERE Id='";
    userQuery=[userQuery stringByAppendingString:theseVars.userId];
    userQuery=[userQuery stringByAppendingString:@"'"];
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:userQuery];    
    [[SFRestAPI sharedInstance] send:request delegate:self];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"SFAuthorizingViewController shouldAutorotateToInterfaceOrientation:%d",interfaceOrientation);
    // Return YES for supported orientations
	return NO;
}

- (void)nextQuery {
    
    queryType=2;
    theseVars.dateFilter=1;
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:@"SELECT Name, Id, ParentRoleId FROM UserRole WHERE PortalType='None'"];    
    [[SFRestAPI sharedInstance] send:request delegate:self];
    
}

-(void)recTypesQuery {
    
    queryType=22;
    
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:@"SELECT Name, Id FROM RecordType WHERE SobjectType='Opportunity'"];    
    [[SFRestAPI sharedInstance] send:request delegate:self];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    NSMutableArray *records = [jsonResponse objectForKey:@"records"];
    NSLog(@"request:didLoadResponse: #records: %d", records.count);
    if (queryType==1)
    {
        theseVars.userDetails=records;
        [self recTypesQuery];
        
    }
    else if (queryType==22){
        
        NSMutableDictionary *defaultRecType = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"Master", @"", nil]
                                                                   forKeys:[NSArray arrayWithObjects:@"Name", @"Id"]];
        
        [opptyRecTypes addObject:defaultRecType];
        
        [opptyRecTypes addObjectsFromArray:records];
        
        for (NSMutableDictionary *thisType in opptyRecTypes) {
            
            [thisType setValue:@"Yes" forKey:@"Selected" ];
        }
        
      
        
        
        [self nextQuery];
    }
    else if (queryType==2) {
        theseVars.records=records;
        [self presentControls];
        
    }
    
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
   
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Timeout Requesting Data" 
                                                    message:@"Problems reaching server or slow connection.  Please retry."
                                                   delegate:nil
                                          cancelButtonTitle:@"Retry"
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
}

-(void)presentControls {
    controlsView=[[UIView alloc] initWithFrame:CGRectMake(0, 250, 800, 500)];
    controlsView.backgroundColor=[UIColor lightGrayColor];
    controlsView.layer.cornerRadius = 5;
    controlsView.layer.masksToBounds = YES;
   controlsView.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(90.0f));
    
    
    UIButton *btnDeco = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnDeco.frame = CGRectMake(400, 450, 120, 40);
    [btnDeco setTitle:@"Accept" forState:UIControlStateNormal];
    btnDeco.backgroundColor = [UIColor clearColor];
    
    [btnDeco setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnDeco addTarget:self action:@selector(proceed:) forControlEvents:UIControlEventTouchUpInside];
    
    [controlsView addSubview:btnDeco];
    
    //Add Title Bar
    UILabel *value = [[[UILabel alloc] initWithFrame:CGRectMake(30, 10, 740.0, 50.0)] autorelease];
    
    value.backgroundColor=[UIColor colorWithRed:21.0/255.0 green:92.0/255.0 blue:136.0/255.0 alpha:1.0];
    
    
    value.font = [UIFont systemFontOfSize:24.0];
    value.textColor = [UIColor whiteColor];
    value.text=@"Configure Your View" ;
    value.lineBreakMode = UILineBreakModeWordWrap;
    value.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    value.textAlignment = UITextAlignmentCenter;
    value.layer.cornerRadius = 10;
    value.layer.masksToBounds = YES;
    [controlsView addSubview:value];
    
    //Add Role Picker Caption
    
    UILabel *roleCaption = [[[UILabel alloc] initWithFrame:CGRectMake(80, 80, 320, 50.0)] autorelease];
    
    roleCaption.backgroundColor=[UIColor darkGrayColor];
    
    
    roleCaption.font = [UIFont systemFontOfSize:18.0];
    roleCaption.textColor = [UIColor whiteColor];
    roleCaption.text=@"Select Root Role" ;
    roleCaption.lineBreakMode = UILineBreakModeWordWrap;
    roleCaption.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    roleCaption.textAlignment = UITextAlignmentCenter;
    roleCaption.layer.cornerRadius = 10;
    roleCaption.layer.masksToBounds = YES;
    [controlsView addSubview:roleCaption];
    
    //Add Role Picker
    RolePickerController *myPickerView = [[RolePickerController alloc] initWithFrame:CGRectMake(80, 160, 320, 450) roles:theseVars.records];
    
    
    myPickerView.showsSelectionIndicator = YES;
    
    [myPickerView spinToMe];
    
    [controlsView addSubview:myPickerView];
    
    //Add Record Type Caption
    
    UILabel *recCaption = [[[UILabel alloc] initWithFrame:CGRectMake(420, 80, 320, 50.0)] autorelease];
    
    recCaption.backgroundColor=[UIColor darkGrayColor];
    
    
    recCaption.font = [UIFont systemFontOfSize:18.0];
    recCaption.textColor = [UIColor whiteColor];
    recCaption.text=@"Select Record Types" ;
    recCaption.lineBreakMode = UILineBreakModeWordWrap;
    recCaption.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    recCaption.textAlignment = UITextAlignmentCenter;
    recCaption.layer.cornerRadius = 10;
    recCaption.layer.masksToBounds = YES;
    [controlsView addSubview:recCaption];
    
    //Add Record Type Table
    RecordTypeTableController *myRecTypeView = [[RecordTypeTableController alloc] initWithStyle:UITableViewStylePlain recTypes:opptyRecTypes];
    
    
   
    UIView *view = myRecTypeView.view;
    
    
    [controlsView addSubview:myRecTypeView.view];
     view.frame=CGRectMake(420, 160, 320, 250);
    
    [self.view addSubview:controlsView];
    
    
}


-(void)buildHierarchy {
    [theseVars.records setValue:[NSNumber numberWithInt:-1] forKey:@"Level"];
    NSIndexSet *rootRecords=[[NSIndexSet alloc]init];
    rootRecords = [theseVars.records indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL * stop){ 
        return [[obj objectForKey:@"ParentRoleId"]  isEqual:[NSNull null]];
        
    }];
    if ([rootRecords count]==0 || (theseVars.startNode!=NULL)) {
        if (theseVars.startNode==NULL) {
            NSDictionary *userObj=[theseVars.userDetails objectAtIndex:0];
            theseVars.startNode=[userObj objectForKey:@"UserRoleId"];
        }
        
        rootRecords = [theseVars.records indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL * stop){ 
            return [[obj objectForKey:@"Id"]  isEqualToString:theseVars.startNode];
            
        }];

    }
    NSMutableArray *results = (NSMutableArray*)[theseVars.records objectsAtIndexes:rootRecords];
    NSMutableArray *lev1Keys=[[NSMutableArray alloc] init];
    
    //Assign Level to Root
    for (NSMutableDictionary *obj in results) {
        NSNumber *myInt = [NSNumber numberWithInt:1];
        [obj setValue:myInt forKey:@"Level"];
        [obj setValue:@"NULL" forKey:@"ParentRoleId"];
        [lev1Keys addObject:[obj objectForKey:@"Id"]];
        
    }
    //Do Other Levels
    int moreLevel=2;
    while (moreLevel>1) {
        NSIndexSet *nextLevel = [theseVars.records indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL * stop){ 
            return [lev1Keys containsObject:[obj objectForKey:@"ParentRoleId"]];
            
        }];
        
        NSMutableArray *results2 = (NSMutableArray*)[theseVars.records objectsAtIndexes:nextLevel];
        if ([results2 count]>0) {
            [lev1Keys removeAllObjects];
            for (NSMutableDictionary *obj in results2) {
                NSNumber *myInt = [NSNumber numberWithInt:moreLevel];
                [obj setValue:myInt forKey:@"Level"];
                [lev1Keys addObject:[obj objectForKey:@"Id"]];
                
            }
            //NSLog(@"level=%i count=%i",moreLevel,[lev1Keys count]);
            
            moreLevel++;    
        }
        else {
            theseVars.hierLevels=moreLevel;
            moreLevel=0;
        }
        
    }
    
    NSIndexSet *badRecords=[[NSIndexSet alloc] init];
    badRecords = [theseVars.records indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL * stop){ 
        return [[obj objectForKey:@"Level"]  isEqualToValue:[NSNumber numberWithInt:-1]];
        
    }];
    NSLog(@"Counting Bad Records: %i",[badRecords count]);
    if ([badRecords count]>0) {
        NSLog(@"Removing Bad Records");
        [theseVars.records removeObjectsAtIndexes:badRecords];
    }
    
    
   [self setupCocos2D]; 

    
    
    
}

- proceed: (id) sender {
    NSLog(@"Here");
    [controlsView removeFromSuperview];
    NSIndexSet *badRecTypes=[[NSIndexSet alloc] init];
    badRecTypes = [theseVars.recordTypes indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL * stop){ 
        return [[obj objectForKey:@"Selected"]  isEqualToString:@"No"];
        
    }];
    [theseVars.recordTypes removeObjectsAtIndexes:badRecTypes];
   
   [self buildHierarchy];
    
} 


- (void)setupCocos2D {
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    //NSLog(@"scale=%f",scale);
   //CGFloat scaleFactor = 2.0;
   
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
     //[window setContentScaleFactor:scaleFactor];
   // [self.view setContentScaleFactor:scaleFactor];
   
    EAGLView *glView = [CC3EAGLView viewWithFrame: [window bounds]
									  pixelFormat: kEAGLColorFormatRGBA8
									  depthFormat: GL_DEPTH_COMPONENT16_OES
							   preserveBackbuffer: NO
									   sharegroup: nil
									multiSampling: NO
								  numberOfSamples: 2];
    glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [[CCDirector sharedDirector] setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
    
   
    [self.view insertSubview:glView atIndex:0];
    //[window addSubview: glView];
    [[CCDirector sharedDirector] setOpenGLView:glView];
    if( ! [[CCDirector sharedDirector] enableRetinaDisplay:YES] )
        NSLog(@"Retina Display Not supported");
    CC3World* cc3World = [Three_D_TemplateWorld world];
	
	// Create the customized CC3 layer that supports 3D rendering
	CC3Layer* cc3Layer = [Three_D_TemplateLayer node];
    
	cc3Layer.cc3World = cc3World;		// attach 3D world to 3D layer
	
	// Start the 3D world model and schedule its periodic updates.
	[cc3World play];
	[cc3Layer scheduleUpdate];
	
	ControllableCCLayer* mainLayer = cc3Layer;
	
	CCScene *scene = [CCScene node];
	[scene addChild: mainLayer];
	//[[CCDirector sharedDirector] replaceScene: scene];
    
    [[CCDirector sharedDirector] runWithScene:scene];
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
        if ([key isEqualToString:@"color_metric"] || [key isEqualToString:@"size_metric"] || [key isEqualToString:@"skin_pref"] )
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataRows count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *CellIdentifier = @"CellIdentifier";

   // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];

    }
	//if you want to add an image to your cell, here's how
	UIImage *image = [UIImage imageNamed:@"icon.png"];
	cell.imageView.image = image;

	// Configure the cell to show the data.
	NSDictionary *obj = [dataRows objectAtIndex:indexPath.row];
	cell.textLabel.text =  [obj objectForKey:@"Name"];

	//this adds the arrow to the right hand side.
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;

}
@end

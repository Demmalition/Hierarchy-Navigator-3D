//
//  Three_D_TemplateLayer.m
//  Three D Template
//
//  Created by Matthew Demma on 2/21/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "Three_D_TemplateLayer.h"
#import "Three_D_TemplateWorld.h"
#import "GameVars.h"
#import "CCLabelTTF.h"
#import "MBProgressHUD.h"
#import "com.ccColor3B.h"

@interface Three_D_TemplateLayer (TemplateMethods)
@property(nonatomic, readonly) Three_D_TemplateWorld* ourWorld;
@end

@implementation Three_D_TemplateLayer

@synthesize swipeRightRecognizer = _swipeRightRecognizer;
@synthesize swipeLeftRecognizer = _swipeLeftRecognizer;

CCSprite *sideSprite;
CCSprite *statSprite;
CCSprite *statGraphSprite;
CCSprite *statPane;
CCSprite *dateBar;
GameVars *theseVars;
NSString *statContent;

CCLabelBMFont *bonus;
CCLabelBMFont *bonusHead;
CCLabelBMFont *navLabel;
CCLabelBMFont *dateLabel;
CCLabelBMFont *sizeLabel;
CCLabelBMFont *colorLabel;
BOOL displayMenu;
CCMenu* viewMenu;
NSString *skin;
NSString *sizeMetric;
NSString *colorMetric;

-(Three_D_TemplateWorld*) ourWorld {
	return (Three_D_TemplateWorld*) cc3World;
}

- (void)dealloc {
    [super dealloc];
    [_swipeRightRecognizer release];
    _swipeRightRecognizer = nil;
    [_swipeLeftRecognizer release];
    _swipeLeftRecognizer = nil;
   
}


-(void) update:(ccTime)dt
{
	[super update:dt];
    if (theseVars.transitionText) {
        [self cycleText];
        
    }
    else {
        statContent=theseVars.statText;
        bonus.string=statContent;
        navLabel.string=theseVars.navText;
        dateLabel.string=theseVars.filterText;
    }
        
    
    
	
}


-(void) cycleText {
    
    CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:.3 opacity:0];
    CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:.3 opacity:255];
    CCActionInstant* updText = [CCCallFunc actionWithTarget: self selector: @selector(updateText)];
    //CCActionInstant* resVar =   [CCCallFunc actionWithTarget: self selector: @selector(resetVariable)];
    CCSequence *fadeSequence = [CCSequence actions:fadeOut,fadeIn,nil];
    CCSequence *textSequence = [CCSequence actions:[CCDelayTime actionWithDuration:1.0],updText,nil];
    [bonus runAction:fadeSequence];
    [bonus runAction:textSequence];
}

-(void) updateText {
    statContent=theseVars.statText;
    bonus.string=statContent;
    navLabel.string=theseVars.navText;
    theseVars.transitionText=NO;
    
}

-(void) resetVariable {
    
    
}

/**
 * Template method that is invoked automatically during initialization, regardless
 * of the actual init* method that was invoked. Subclasses can override to set up their
 * 2D controls and other initial state without having to override all of the possible
 * superclass init methods.
 *
 * The default implementation does nothing. It is not necessary to invoke the
 * superclass implementation when overriding in a subclass.
 */
-(void) initializeControls {
    theseVars = [GameVars sharedGameVars];
    [self registerDefaultsFromSettingsBundle];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs synchronize];
    
	skin = [defs stringForKey:@"skin_pref"];
    sizeMetric=[defs stringForKey:@"size_metric"];    
    colorMetric=[defs objectForKey:@"color_metric"];
    theseVars.navText=@"Test";
    theseVars.filterText=@"Current Fiscal Year";
    statPane = [CCSprite spriteWithFile:@"statspane.png"];
    statPane.position=ccp(512,120);
    statPane.scale=1.2;
    statPane.scaleX=2.5;
    
    [self addChild:statPane];
    
    if ([skin isEqualToString:@"sky"]) {
        bonus=[CCLabelBMFont labelWithString:statContent fntFile:@"myriad.fnt" ];
        bonusHead=[CCLabelBMFont labelWithString:statContent fntFile:@"myriad.fnt" ];
        dateLabel=[CCLabelBMFont labelWithString:theseVars.filterText fntFile:@"myriadwhite.fnt" ];
        navLabel=[CCLabelBMFont labelWithString:theseVars.navText fntFile:@"myriad.fnt" ];
        sizeLabel=[CCLabelBMFont labelWithString:theseVars.navText fntFile:@"myriad.fnt" ];
        colorLabel=[CCLabelBMFont labelWithString:theseVars.navText fntFile:@"myriad.fnt" ];
    } else if ([skin isEqualToString:@"space"]) {
        bonus=[CCLabelBMFont labelWithString:statContent fntFile:@"myriadgold.fnt" ];
        bonusHead=[CCLabelBMFont labelWithString:statContent fntFile:@"myriadgold.fnt" ];
        navLabel=[CCLabelBMFont labelWithString:theseVars.navText fntFile:@"myriadgold.fnt" ];
        dateLabel=[CCLabelBMFont labelWithString:theseVars.filterText fntFile:@"myriadwhite.fnt" ];
        sizeLabel=[CCLabelBMFont labelWithString:theseVars.navText fntFile:@"myriadgold.fnt" ];
        colorLabel=[CCLabelBMFont labelWithString:theseVars.navText fntFile:@"myriadgold.fnt" ];
    }
    else {
        bonus=[CCLabelBMFont labelWithString:statContent fntFile:@"myriadwhite.fnt" ];
        bonusHead=[CCLabelBMFont labelWithString:statContent fntFile:@"myriadwhite.fnt" ];
        navLabel=[CCLabelBMFont labelWithString:theseVars.navText fntFile:@"myriadwhite.fnt" ];
        dateLabel=[CCLabelBMFont labelWithString:theseVars.filterText fntFile:@"myriadwhite.fnt" ];
        sizeLabel=[CCLabelBMFont labelWithString:theseVars.navText fntFile:@"myriadwhite.fnt" ];
        colorLabel=[CCLabelBMFont labelWithString:theseVars.navText fntFile:@"myriadwhite.fnt" ];
        
    }
    
   
    
   
    bonus.position=ccp(480,120);
  
    
    [self addChild:bonus];
  
    navLabel.position=ccp(512,620);
    
    [self addChild:navLabel];

    
    CCMenuItemImage *dateBar = [CCMenuItemImage itemFromNormalImage:@"datestringbg.png"
                                                  selectedImage: @"datestringbg.png"
                                                         target:self
                                                       selector:@selector(toggleDisplay:)];
    
    dateBar.opacity=220;
    CCMenu* dateMenu = [CCMenu menuWithItems: dateBar, nil ];
	dateMenu.position = ccp(880,614.5);
    
	[self addChild: dateMenu];
    
    dateLabel.position=ccp(885,614.5);
    dateLabel.scale=.9;
    [self addChild:dateLabel];
    
    
    statSprite=[CCSprite spriteWithFile:@"statbar.png"];
    statSprite.position=ccp(42,400);
    statSprite.scaleX=1.2;
    statSprite.opacity=225;
    [self addChild:statSprite];
    
    statGraphSprite=[CCSprite spriteWithFile:@"statgraphs.png"];
    statGraphSprite.position=ccp(42,400);
    statGraphSprite.scaleX=1.2;
    statGraphSprite.opacity=225;
    [self addChild:statGraphSprite];
    
    if ([sizeMetric isEqualToString:@"sizecount"]) 
    {    
    sizeLabel.string=@"Pipeline\nSize" ;
    }
    else
    {    
    sizeLabel.string=@"Pipeline\nValue" ;
    }
    sizeLabel.position=ccp(42,600);
    [self addChild:sizeLabel];
    
    
    if ([colorMetric isEqualToString:@"colwinper"]) 
    { 
    colorLabel.string=@"Won/\nClosed" ;
    }
    else
    {
    colorLabel.string=@"Closed/\nTotal";    
        
    }
    colorLabel.position=ccp(42,400);
    [self addChild:colorLabel];
    
    [self buildMenu];
    
    // Add popout icon
    
    CCMenuItemImage *popoutIcon = [CCMenuItemImage itemFromNormalImage:@"popout.png"
                                                      selectedImage: @"popout.png"
                                                             target:self
                                                           selector:@selector(toggleDetails:)];
    
    popoutIcon.scale=.7;
    
    
    CCMenu* popoutMenu = [CCMenu menuWithItems: popoutIcon, nil ];
	popoutMenu.position = ccp(800,170);
    
	[self addChild: popoutMenu];
    
    NSDictionary *userObj=[theseVars.userDetails objectAtIndex:0];
    NSString *userString=@"Logged in As ";
    userString=[userString stringByAppendingString:[userObj valueForKey:@"Name"]];
    CCLabelTTF *logMess = [[CCLabelTTF labelWithString:userString fontName:@"Arial-BoldMT" fontSize:17] retain];
    logMess.color=ccc3(49,118,175);
    logMess.position=ccp(140,730);
    [self addChild:logMess];

}


-(void) buildMenu {
    
    sideSprite = [CCSprite spriteWithFile:@"dateselectbg.png"];
    sideSprite.position=ccp(880,400);
    sideSprite.scaleX=1;
    sideSprite.opacity=225;
    [self addChild:sideSprite];
    
    CCMenuItemImage *db1 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                          selectedImage: @"datebutton.png"
                                                                 target:self
                                                               selector:@selector(toggleMonth:)];
    CCMenuItemImage *db2 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                            selectedImage: @"datebutton.png"
                                                                   target:self
                                                                 selector:@selector(toggleMonth:)];
    CCMenuItemImage *db3 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                         selectedImage: @"datebutton.png"
                                                                target:self
                                                              selector:@selector(toggleMonth:)];
    CCMenuItemImage *db4 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                  selectedImage: @"datebutton.png"
                                                         target:self
                                                       selector:@selector(toggleMonth:)];
    CCMenuItemImage *db5 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                  selectedImage: @"datebutton.png"
                                                         target:self
                                                       selector:@selector(toggleMonth:)];
    CCMenuItemImage *db6 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                  selectedImage: @"datebutton.png"
                                                         target:self
                                                       selector:@selector(toggleMonth:)];
    CCMenuItemImage *db7 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                  selectedImage: @"datebutton.png"
                                                         target:self
                                                       selector:@selector(toggleMonth:)];
    CCMenuItemImage *db8 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                  selectedImage: @"datebutton.png"
                                                         target:self
                                                       selector:@selector(toggleMonth:)];
    CCMenuItemImage *db9 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                  selectedImage: @"datebutton.png"
                                                         target:self
                                                       selector:@selector(toggleMonth:)];
    CCMenuItemImage *db10 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                  selectedImage: @"datebutton.png"
                                                         target:self
                                                       selector:@selector(toggleMonth:)];
    CCMenuItemImage *db11 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                  selectedImage: @"datebutton.png"
                                                         target:self
                                                       selector:@selector(toggleMonth:)];
    CCMenuItemImage *db12 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                  selectedImage: @"datebutton.png"
                                                         target:self
                                                       selector:@selector(toggleMonth:)];
   
    CCMenuItemImage *db13 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                   selectedImage: @"datebutton.png"
                                                          target:self
                                                        selector:@selector(toggleMonth:)];
    CCMenuItemImage *db14 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                   selectedImage: @"datebutton.png"
                                                          target:self
                                                        selector:@selector(toggleMonth:)];
    CCMenuItemImage *db15 = [CCMenuItemImage itemFromNormalImage:@"datebuttoff.png"
                                                   selectedImage: @"datebutton.png"
                                                          target:self
                                                        selector:@selector(toggleMonth:)];
    

    db15.tag=15;
    db14.tag=14;
    db13.tag=13;
    db12.tag=12;
    db11.tag=11;
    db10.tag=10;
    db9.tag=9;
    db8.tag=8;
    db7.tag=7;
    db6.tag=6;
    db5.tag=5;
    db4.tag=4;
    db3.tag=3;
    db2.tag=2;
    db1.tag=1;
    viewMenu = [CCMenu menuWithItems: db1,db2,db3,db4,db5,db6,db7,db8,db9,db10,db11,db12,db13,db14,db15, nil ];
	viewMenu.position = ccp(800,435);
    [viewMenu alignItemsVerticallyWithPadding:3.25];
	[self addChild: viewMenu];  
    viewMenu.visible=FALSE;
    sideSprite.visible=FALSE;
    displayMenu=FALSE;
    
}

-(void) toggleDisplay: (CCMenuItem  *) menuItem{
    if (displayMenu==TRUE) {
        viewMenu.visible=FALSE;
        sideSprite.visible=FALSE;
        displayMenu=FALSE; 
        
    }
    else {
        viewMenu.visible=TRUE;
        sideSprite.visible=TRUE;
        displayMenu=TRUE;
        
    }
    
}

-(void) toggleDetails: (CCMenuItem  *) menuItem{
     [self.ourWorld buildTree];
    
}

-(void) toggleMonth: (CCMenuItem  *) menuItem{
    theseVars.dateFilter=menuItem.tag;
    viewMenu.visible=FALSE;
    sideSprite.visible=FALSE;
    displayMenu=FALSE; 
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[CCDirector sharedDirector] openGLView].window animated:YES];
   
    hud.labelText = @"Refreshing...";
    [self.ourWorld reQuery];
   
    
}

 // The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 // The event dispatcher will not dispatch events for which there is no method
 // implementation. Since the touch-move events are both voluminous and seldom used,
 // the implementation of ccTouchMoved:withEvent: has been left out of the default
 // CC3Layer implementation. To receive and handle touch-move events for object
 // picking,uncomment the following method implementation. To receive touch events,
 // you must also set the isTouchEnabled property of this instance to YES.
/*
 // Handles intermediate finger-moved touch events. 
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}
*/


- (void)handleRightSwipe:(UISwipeGestureRecognizer *)swipeRecognizer {
    
    [self.ourWorld indexRight]; 
}

- (void)handleLeftSwipe:(UISwipeGestureRecognizer *)swipeRecognizer {
   
    [self.ourWorld indexLeft]; 
}


- (void)onEnter {
     
    [super onEnter]; 
     self.isTouchEnabled = YES; 
    self.swipeRightRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)] autorelease];
    _swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:_swipeRightRecognizer]; 
    self.swipeLeftRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe:)] autorelease];
    _swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:_swipeLeftRecognizer]; 
}

- (void)onExit {
    
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:_swipeRightRecognizer];
     [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:_swipeLeftRecognizer];
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

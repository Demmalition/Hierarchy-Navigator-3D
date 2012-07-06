//
//  RecordTypeTableController.m
//  RoleScroll
//
//  Created by Matthew Demma on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordTypeTableController.h"
#import "GameVars.h"

@implementation RecordTypeTableController

@synthesize recTypes;

GameVars *theseVars;

- (id)initWithStyle:(UITableViewStyle)style recTypes:(NSMutableArray*) passTypes
{
    NSLog(@"Starting Table");
    self = [super initWithStyle:style];
    if (self) {
        theseVars = [GameVars sharedGameVars];
        self.recTypes=passTypes;
        theseVars.recordTypes=passTypes;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) addAccessory{
    useAccessory = !useAccessory;
    //[[self tableView] reloadData];
}

-(void) addThumbnail {
    useThumbnail = !useThumbnail;
    //[[self tableView] reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // create a UIButton (Deconnect button)
    
    
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //create a cell
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:@"cell"];
    
   
    NSLog(@"%i",recTypes.count);
    // fill it with contnets
    if (self.recTypes.count>0) {
        
        NSDictionary *thisStage = [self.recTypes objectAtIndex:indexPath.row];
        
        NSDictionary *masterStage=[theseVars.recordTypes objectAtIndex:indexPath.row];
        
        if ([[masterStage valueForKey:@"Selected"] isEqualToString:@"Yes"])
        {
         cell.accessoryType = UITableViewCellAccessoryCheckmark;   
        }
        cell.textLabel.text = [thisStage objectForKey:@"Name"] ;
       
    }
    
    // return it
    return cell;
    
}

- (void)tableView:(UITableView *)theTableView

didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
    
   
    
    [theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:NO];
    
    UITableViewCell *cell = [theTableView cellForRowAtIndexPath:newIndexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [[theseVars.recordTypes objectAtIndex:newIndexPath.row] setValue:@"Yes" forKey:@"Selected"];
       
       
        
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
         [[theseVars.recordTypes objectAtIndex:newIndexPath.row] setValue:@"No" forKey:@"Selected"];
        
    }
   
    NSLog(@"%i",self.recTypes.count);
}


@end

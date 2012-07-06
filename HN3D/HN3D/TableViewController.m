//
//  MyUITableView.m
//  UITableView-cocos2d
//
//  Created by Alexander Alemayhu on 14.11.11.
//  Copyright 2011 Flexnor. All rights reserved.
//


#import "TableViewController.h"
#import "AppDelegate.h"
#import "cocos2d.h"
#import "Common.h"
#import "CustomHeader.h"

@implementation TableViewController

@synthesize stages;

int maxSize;
int minSize;

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:style]) {
        if (style == UITableViewStyleGrouped) isGrouped = YES;
        else isGrouped = NO;
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
    [[self tableView] reloadData];
}

-(void) addThumbnail {
    useThumbnail = !useThumbnail;
    [[self tableView] reloadData];
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
    UIButton *btnDeco = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnDeco.frame = CGRectMake(0, 0, 120, 40);
    [btnDeco setTitle:@"Cancel" forState:UIControlStateNormal];
    btnDeco.backgroundColor = [UIColor clearColor];
    
    [btnDeco setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnDeco addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    maxSize=[[stages valueForKeyPath:@"@max.expr2"] integerValue];
    minSize=[[stages valueForKeyPath:@"@min.expr2"] integerValue];
    
    
    //create a footer view on the bottom of the tabeview
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 100)];
    
    [footerView addSubview:btnDeco];
    
    
    UILabel *value = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 50.0, 240.0, 40.0)] autorelease];
    
    value.backgroundColor=[UIColor darkGrayColor];
    
  
    value.font = [UIFont systemFontOfSize:22.0];
    value.textColor = [UIColor whiteColor];
    value.text=@"    Stage" ;
    value.lineBreakMode = UILineBreakModeWordWrap;
    value.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    value.textAlignment = UITextAlignmentLeft;
    [footerView addSubview:value];
    
    UILabel *value2 = [[[UILabel alloc] initWithFrame:CGRectMake(241.0, 50.0, 250.0, 40.0)] autorelease];
    
    value2.backgroundColor=[UIColor darkGrayColor];
    value2.font = [UIFont systemFontOfSize:22.0];
    value2.textColor = [UIColor whiteColor];
    value2.text=@"    Total Amounts" ;
    value2.lineBreakMode = UILineBreakModeWordWrap;
    value2.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    value2.textAlignment = UITextAlignmentLeft;
    [footerView addSubview:value2];
   
    
    self.tableView.tableHeaderView=footerView; 
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [footerView release];

}

- cancel: (id) sender {
    NSLog(@"Here");
    [self.view removeFromSuperview];

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isGrouped)
        return 2;
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return stages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //create a cell
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:@"cell"];
    
    // fill it with contnets
    NSDictionary *thisStage = [stages objectAtIndex:indexPath.row];


    
    CGRect frame = CGRectMake(0, 0, 450, 44);
    cell = [[[UITableViewCell alloc] initWithFrame:frame] retain] ;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
   
    
    UILabel *value = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 22.0, 250.0, 40.0)] retain];
    
    value.font = [UIFont systemFontOfSize:22.0];
    value.textColor = [UIColor blackColor];
    value.text=[thisStage objectForKey:@"StageName"] ;
    value.lineBreakMode = UILineBreakModeWordWrap;
    value.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    value.textAlignment = UITextAlignmentLeft;
    [cell.contentView addSubview:value];
    
    
    CustomHeader *header = [[[CustomHeader alloc] init] retain];
    header.titleLabel.text = [[thisStage objectForKey:@"expr2"] stringValue];
    if ([[thisStage objectForKey:@"expr0"] integerValue]>30) {
        
        header.lightColor = [UIColor colorWithRed:216.0f/255.0f green:199.0f/255.0f blue:102.0f/255.0f alpha:1.0];
        header.darkColor = [UIColor colorWithRed:136.0/255.0 green:132.0/255.0 blue:63.0/255.0 alpha:1.0];
        
    }
    if ([[thisStage objectForKey:@"expr0"] integerValue]>70) {
        
        header.lightColor = [UIColor colorWithRed:245.0f/255.0f green:100.0f/255.0f blue:102.0f/255.0f alpha:1.0];
        header.darkColor = [UIColor colorWithRed:136.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
        
    }
    
    double sizeNormal=(double)((double)[[thisStage objectForKey:@"expr2"] integerValue]/((double)maxSize-(double)minSize));
    double sizeRatio=.7+(.35*sizeNormal);
    if (stages.count<=1) {
        sizeRatio=1;
    }
    header.frame=CGRectMake(255.0+(62.5*(1-sizeRatio)), 22.0, 125.0*sizeRatio, 40.0);
    
    [cell.contentView addSubview:header];
    
    // return it
    return cell;

}

- (void)dealloc {
    [stages release];
    stages = nil;
   
    [super dealloc];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate


@end

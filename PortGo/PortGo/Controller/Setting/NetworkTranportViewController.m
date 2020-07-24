//
//  NetworkTranportViewController.m
//  telephony
//
//  Created by Joe Lepple on 4/19/13.
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "NetworkTranportViewController.h"
#import "DataBaseManage.h"

@implementation NetworkTranportViewController

@synthesize list;
@synthesize lastSelectTranport;


- (id)init
{
    self = [super init];
    
    return self;
}



-(void)viewDidLoad{
    NSArray *array = [[NSArray alloc]initWithObjects:@"UDP", @"TLS",@"TCP",@"PERS", nil];
    self.list = array;
    
    [super viewDidLoad];
    
}

-(void)viewDidUnload{
    
    self.list = nil;
    [super viewDidUnload];
    
}


#pragma mark - TableView DataSource Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.list count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"CellIdentifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
        
    }
    NSUInteger row = [indexPath row];
    //NSUInteger oldRow = [lastIndexPath row];
    cell.textLabel.text = [list objectAtIndex:row];
    
    if([cell.textLabel.text isEqualToString:lastSelectTranport])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
    
}


#pragma mark - TableView Delegate Method

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for(int i = 0; i < [[tableView visibleCells]count]; i++)
    {
        UITableViewCell *showCell = [[tableView visibleCells]objectAtIndex:i];
        showCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.lastSelectTranport = newCell.textLabel.text;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate didSelectTranport:newCell.textLabel.text];
}

@end

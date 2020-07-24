//
//  LineStateViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/6/13.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "LineStateViewController.h"

@interface LineStateViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_stateTableview;
    NSMutableArray *_stateItems;
    NSInteger lastSelect;
}
@end

@implementation LineStateViewController

-(UITableView *)createTableview {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.view.bounds.size.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    return tableView;
}

-(void)initItems {
    _stateItems = [NSMutableArray arrayWithCapacity:5];
    
    NSDictionary *dic = [[NSDictionary alloc] init];
    dic = @{@"set_status_online" : NSLocalizedString(@"online", @"online")};
    [_stateItems addObject:dic];
    
    dic = [[NSDictionary alloc] init];
    dic = @{@"set_status_away" : NSLocalizedString(@"Away", @"Away")};
    [_stateItems addObject:dic];
    
    dic = [[NSDictionary alloc] init];
    dic = @{@"set_status_shutup" : NSLocalizedString(@"Do not disturb", @"Do not disturb")};
    [_stateItems addObject:dic];
    
    dic = [[NSDictionary alloc] init];
    dic = @{@"mid_content_status_busy_ico" : NSLocalizedString(@"Busy", @"Busy")};
    [_stateItems addObject:dic];
    
    dic = [[NSDictionary alloc] init];
    dic = @{@"set_status_outline" : NSLocalizedString(@"offline", @"offline")};
    [_stateItems addObject:dic];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initItems];
    
    _stateTableview = [self createTableview];
    [self.view addSubview:_stateTableview];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _stateItems.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    NSDictionary *item = _stateItems[indexPath.row];
    NSString *key = [item allKeys][0];
    NSString *value = item[key];
    if ([value isEqualToString:_stateString]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    
    cell.imageView.image = [UIImage imageNamed:key];
    cell.textLabel.text = value;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelect inSection:0]];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    lastSelect = indexPath.row;
    NSDictionary *dic = _stateItems[indexPath.row];
    
    if (self.callback) {
        self.callback(dic);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didSelectlineStateCallback:(SelectStateCallback)callback {
    self.callback = callback;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

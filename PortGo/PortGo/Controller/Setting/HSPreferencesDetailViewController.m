//
//  HSPreferencesDetailViewController.m
//  PortGo
//
//  Created by MrLee on 14-10-10.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSPreferencesDetailViewController.h"
#import "UIBarButtonItem+HSBackItem.h"

@interface HSPreferencesDetailViewController ()
{
    NSString *_defaultSelectedStr;
    NSString *_titleStr;
    NSIndexPath *_lastSelectedIndexPath;
    NSIndexPath *_indexPath;
}

@end

@implementation HSPreferencesDetailViewController

- (instancetype)initWithArray:(NSArray *)array defaultSelected:(NSString*)defaultSelectedStr title:(NSString*)titleStr rowIndexPath:(NSIndexPath *)indexPath
{
    if (self = [super initWithNibName:@"HSPreferencesDetailViewController" bundle:nil]) {
        _cellDataArray = array;
        _defaultSelectedStr = defaultSelectedStr;
        _indexPath = indexPath;
        _titleStr = titleStr;
        NSLog(@"_cellDataArray===%@",_cellDataArray);
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(onBack:)];
    self.title = _titleStr;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* mainColor;
    if (@available(iOS 11.0, *)) {
        mainColor = [UIColor colorNamed:@"mainColor"];
    }
    else{
        mainColor = MAIN_COLOR;
    }
//    
//    self.view.backgroundColor = bkColor;
    self.navigationController.navigationBar.tintColor = mainColor;
}

- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"HSPreferencesDetailViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.textLabel.text = NSLocalizedString(_cellDataArray[indexPath.row], _cellDataArray[indexPath.row]);
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    
    if ([cell.textLabel.text isEqualToString:_defaultSelectedStr]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _lastSelectedIndexPath = indexPath;
    }

    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (_lastSelectedIndexPath) {
        cell = [tableView cellForRowAtIndexPath:_lastSelectedIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell = [tableView cellForRowAtIndexPath:indexPath];
    _lastSelectedIndexPath = indexPath;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate didSelectedRowWithString:(int)indexPath.row rowIndexPath:_indexPath];
}

@end

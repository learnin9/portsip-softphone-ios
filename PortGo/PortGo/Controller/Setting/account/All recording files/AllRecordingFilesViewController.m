//
//  AllRecordingFilesViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/11/16.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "AllRecordingFilesViewController.h"
#import "PlayerView.h"
#import "PlayViewController.h"


#define heightt 150


@interface AllRecordingFilesViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
    NSMutableArray *AllRecordingFiles;
    PlayerView *playerview;
    
    NSInteger  index;
    
    
    BOOL  headershow;
    
}

@property (nonatomic)  UITableView * AllRecordingFilesTableview;

@end

@implementation AllRecordingFilesViewController

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bkColor = [UIColor lightGrayColor];
    }
    self.AllRecordingFilesTableview.backgroundColor = bkColor;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = NSLocalizedString(@"All recording files",@"All recording files");
    
    self.view.backgroundColor = RGB(242, 242, 242);
    
    AllRecordingFiles = [[NSMutableArray alloc]init];
    
    
    [self.view addSubview:self.AllRecordingFilesTableview];
    
    
    [self getAllRecordingFiles];
    
    
    playerview = [PlayerView PlayerViewWithFrame:CGRectMake(0, ScreenHeight-150-64    , ScreenWid, 150)];
    
    __block AllRecordingFilesViewController *blockSelf = self;
    
    playerview.headviewBlock = ^{
        
        self->headershow = NO;
        self->index =-1;
        
        [blockSelf.AllRecordingFilesTableview reloadData];
        
    };
    
    index=-1;
    
    
    [self traitCollectionDidChange:self.traitCollection];
    
    // Do any additional setup after loading the view.
}

-(void)getAllRecordingFiles{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    for (NSString * file in fileList) {
        
        if  ([file rangeOfString:@"wav"].location !=NSNotFound||[file rangeOfString:@"avi"].location !=NSNotFound){
            [AllRecordingFiles addObject:file];
        }
        
    }
    
    [_AllRecordingFilesTableview reloadData];
    
}


#pragma mark --
#pragma mark tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return AllRecordingFiles.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * celld = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:celld];
    
    cell.textLabel.text = [AllRecordingFiles objectAtIndex:indexPath.row];
    
    
    if (indexPath.row == index) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else
    {
        
        cell.accessoryType = 0;
    }
    
    return cell;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 44;
    
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath\
{
    
    PlayViewController *playcon  = [[PlayViewController alloc]init];
    playcon.modalPresentationStyle = UIModalPresentationFullScreen;
    
    playcon.index = indexPath.row;
    playcon.audioArr =AllRecordingFiles;
    
    
    [self presentViewController:playcon animated:YES completion:nil];
}



-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return  playerview;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (headershow) {
        
        return 150;
    }
    else
    {
        
        return 0;
    }
    
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *path = [documentDir stringByAppendingPathComponent:[AllRecordingFiles objectAtIndex:indexPath.row]];
    
    BOOL blDele= [fileManager removeItemAtPath:path error:nil];
    
    if (blDele) {
        
        [AllRecordingFiles removeObjectAtIndex:indexPath.row];
        headershow =NO;
        [_AllRecordingFilesTableview reloadData];
    }else {
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete",@"Delete");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableView*)AllRecordingFilesTableview{
    
    
    if (!_AllRecordingFilesTableview) {
        
        
        _AllRecordingFilesTableview = [[UITableView alloc]initWithFrame:CGRectMake(0,0,ScreenWid,ScreenHeight) style:0];
        
        
        // [accountTableview zy_registClassCell:[yanchangshiyongCell class]];
        
        
        _AllRecordingFilesTableview.backgroundColor = [UIColor clearColor];
        //    _myTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.0001)];
        // _myTable.separatorStyle =0;
        //myTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
        _AllRecordingFilesTableview.delegate = self;
        _AllRecordingFilesTableview.dataSource = self;
        
        
        _AllRecordingFilesTableview.scrollEnabled = YES;
        
        _AllRecordingFilesTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [_AllRecordingFilesTableview flashScrollIndicators];
        
    }
    return _AllRecordingFilesTableview;
    
    
}
@end

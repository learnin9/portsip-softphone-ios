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
      
        headershow = NO;
        
        index =-1;
        
        [blockSelf.AllRecordingFilesTableview reloadData];
        
    };
    
    index=-1;
    
    
  
    
    // Do any additional setup after loading the view.
}

-(void)getAllRecordingFiles{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    NSLog(@"fileList====%@",fileList);
    
    for (NSString * file in fileList) {
        
        if  ([file rangeOfString:@"wav"].location !=NSNotFound){
            
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
//    NSURL *fileURL= nil;
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDir = [documentPaths objectAtIndex:0];
//    NSString *path = [documentDir stringByAppendingPathComponent:[AllRecordingFiles objectAtIndex:indexPath.row]];
//    fileURL = [NSURL fileURLWithPath:path];
//
//        index = indexPath.row;
//
//
//        headershow =YES;
//
//        [_AllRecordingFilesTableview reloadData];
//
//        [playerview play:fileURL];

    
    PlayViewController *playcon  = [[PlayViewController alloc]init];
    
    playcon.index = indexPath.row;
    playcon.audioArr =AllRecordingFiles;
    
    
   [self presentViewController:playcon animated:YES completion:nil];
    
    
   // [self .navigationController pushViewController:playcon animated:YES];
    
    
 
    
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

//左滑编辑模式
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //可在此对点击cell右边出现的按钮进行逻辑处理
    

    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *path = [documentDir stringByAppendingPathComponent:[AllRecordingFiles objectAtIndex:indexPath.row]];
    
    BOOL blDele= [fileManager removeItemAtPath:path error:nil];
    
    
 
    
   // [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    
    if (blDele) {
        NSLog(@"dele success");
        
     
        [AllRecordingFiles removeObjectAtIndex:indexPath.row];
        
        headershow =NO;
        
        
        [_AllRecordingFilesTableview reloadData];
        
        
    }else {
        NSLog(@"dele fail");
    }
    
}

//设置左滑删除按钮的文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置右边按钮的文字
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

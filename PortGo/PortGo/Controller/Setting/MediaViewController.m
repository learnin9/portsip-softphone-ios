//
//  CodecsViewController.m
//  telephony
//
//  Created by World on 12/15/11.
//  Copyright 2011 HaveSoft Network. All rights reserved.
//

#import "MediaViewController.h"
#import "DataBaseManage.h"
#import "UIBarButtonItem+HSBackItem.h"

#define  kAudioCodecsKey    NSLocalizedString(@"Audio Codecs", @"Audio Codecs")
#define  kVideoCodecsKey    NSLocalizedString(@"Video Codecs", @"Video Codecs")


#define audioFilePath @"AudioCodecs.plist"
#define videoFilePath @"VideoCodecs.plist"
#define cellID @"cellID"

@interface MediaViewController()
{
    NSMutableArray *audioCodecsArray;
    NSMutableArray *videoCodecsArray;
    UIBarButtonItem *doneItem;
    UIBarButtonItem *composeItem;
}

@end

@implementation MediaViewController

- (id)init
{
    self = [super init];
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Codecs", @"Codecs");
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    //    NSString *filePath = [path stringByAppendingString:audioFilePath];
    
    NSString *filePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@",audioFilePath]];
    
    audioCodecsArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    
    if (!audioCodecsArray) {
        NSString *audioPath = [[NSBundle mainBundle] pathForResource:audioFilePath ofType:nil];
        audioCodecsArray = [NSMutableArray arrayWithContentsOfFile:audioPath];
    }
    
    filePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@",videoFilePath]];
    videoCodecsArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    
    
    
    if (!videoCodecsArray) {
        NSString *videoPath = [[NSBundle mainBundle] pathForResource:videoFilePath ofType:nil];
        videoCodecsArray = [NSMutableArray arrayWithContentsOfFile:videoPath];
    }
    
    
    
    
    composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onRightNavButtonClick:)];
    doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneItemClick:)];
    
    self.navigationItem.rightBarButtonItem = composeItem;
    
    //  self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(onBack:)];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
}

-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        return nil;
    }
    return dic;
}




- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [databaseManage saveOptions];
    [super viewDidDisappear:animated];
}

- (void)onRightNavButtonClick:(id)sender
{
    self.editing = YES;
    self.navigationItem.rightBarButtonItem = doneItem;
}

- (void)onDoneItemClick:(id)sender
{
    self.editing = NO;
    self.navigationItem.rightBarButtonItem = composeItem;
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath = [path stringByAppendingString:audioFilePath];
    [audioCodecsArray writeToFile:filePath atomically:YES];
    
    filePath = [path stringByAppendingString:videoFilePath];
    [videoCodecsArray writeToFile:filePath atomically:YES];
}

#pragma mark - TableView DataSource Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return audioCodecsArray.count;
    }
    else{
        return videoCodecsArray.count;
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return kAudioCodecsKey;
        case 1:
            return kVideoCodecsKey;
        default:
            break;
    }
    return nil;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    
    return nil;
    
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#ifndef HAVE_VIDEO
    return 1;
#endif
    return 2;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    cell.selectionStyle =  UITableViewCellSelectionStyleGray;
    NSUInteger section = [indexPath section];
    
    
    UISwitch *switchOperation = [[UISwitch alloc]init];
    switchOperation.onTintColor = [UIColor colorWithRed:29.0/255 green:172.0/255 blue:239.0/255 alpha:1];
    [switchOperation addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
    
    if (section == 0) {
        cell.textLabel.text = NSLocalizedString(audioCodecsArray[indexPath.row][@"name"], audioCodecsArray[indexPath.row][@"name"]);
        
        
        switchOperation.tag = [audioCodecsArray[indexPath.row][@"tag"] intValue];
        
        switch (switchOperation.tag) {
            case 100 ://G722
                switchOperation.on = databaseManage.mOptions.codecOPUS;
                break;
            case 101 ://G729
                switchOperation.on = databaseManage.mOptions.codecG729;
                break;
            case 102 ://AMR
                switchOperation.on = databaseManage.mOptions.codecAMR;
                break;
            case 103 ://AMRWB
                switchOperation.on = databaseManage.mOptions.codecAMRwb;
                
                break;
            case 104 ://GSM
                switchOperation.on = databaseManage.mOptions.codecGSM;
                break;
            case 105 ://PCMA
                switchOperation.on = databaseManage.mOptions.codecPCMA;
                break;
            case 106 ://PCMU
                switchOperation.on = databaseManage.mOptions.codecPCMU;
                break;
            case 107 ://iLBC
                switchOperation.on = databaseManage.mOptions.codecILBC;
                break;
            case 108 ://SpeexNB
                switchOperation.on = databaseManage.mOptions.codecSpeexNB;
                break;
            case 109 ://SpeexWb
                switchOperation.on = databaseManage.mOptions.codecSpeexWB;
                break;
            case 110 ://OPUS
                switchOperation.on = databaseManage.mOptions.codecG722;
                break;
            default:
                break;
        }
    }
    else if(section == 1)
    {//Video Codec
        cell.textLabel.text = NSLocalizedString(videoCodecsArray[indexPath.row][@"name"], videoCodecsArray[indexPath.row][@"name"]);
        
        switchOperation.tag = [videoCodecsArray[indexPath.row][@"tag"] intValue];
        switch (switchOperation.tag) {
                //            case 200 :
                //                switchOperation.on = databaseManage.mOptions.codecH263;
                //                break;
                //            case 201 :
                //                switchOperation.on = databaseManage.mOptions.codecH263_1998;
                //                break;
            case 202 :
                switchOperation.on = databaseManage.mOptions.codecH264;
                break;
            case 203:
                switchOperation.on = databaseManage.mOptions.codecVP8;
                break;
                
            case 204:
                switchOperation.on = databaseManage.mOptions.codecVP9;
                break;
                
                
            default:
                break;
        }
        
    }
    cell.accessoryView = switchOperation;
    
    return cell;
}

-(IBAction)switchPressed:(id)sender
{
    NSInteger tagValue = ((UISwitch*)sender).tag;
    
    switch (tagValue) {
        case 100 ://OPU
            databaseManage.mOptions.codecOPUS = [sender isOn];
            break;
        case 101 ://G729
            databaseManage.mOptions.codecG729 = [sender isOn];
            break;
        case 102 ://AMR
            databaseManage.mOptions.codecAMR = [sender isOn];
            break;
        case 103 ://AMRwb
            databaseManage.mOptions.codecAMRwb = [sender isOn];
            break;
        case 104 ://GSM
            databaseManage.mOptions.codecGSM = [sender isOn];
            break;
        case 105 ://PCMA
            databaseManage.mOptions.codecPCMA = [sender isOn];
            break;
        case 106 ://PCMU
            databaseManage.mOptions.codecPCMU = [sender isOn];
            break;
        case 107 ://ilbc
            databaseManage.mOptions.codecILBC= [sender isOn];
            break;
        case 108 ://SPEEXNB
            databaseManage.mOptions.codecSpeexNB= [sender isOn];
            break;
        case 109 ://SPEEXWB
            databaseManage.mOptions.codecSpeexWB = [sender isOn];
            break;
        case 110 ://OPUS
            databaseManage.mOptions.codecG722 = [sender isOn];
            break;
            
            //        case 200 :
            //            databaseManage.mOptions.codecH263 = [sender isOn];
            //            break;
            //        case 201 :
            //            databaseManage.mOptions.codecH263_1998 = [sender isOn];
            //            break;
        case 202 :
            databaseManage.mOptions.codecH264 = [sender isOn];
            break;
        case 203:
            databaseManage.mOptions.codecVP8 = [sender isOn];
            break;
        case 204:
            databaseManage.mOptions.codecVP9 = [sender isOn];
            break;
            
        default:
            break;
    }
    [databaseManage saveOptions];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath.section == destinationIndexPath.section) {
        if (sourceIndexPath.section == 0) {
            NSDictionary *dict = audioCodecsArray[sourceIndexPath.row];
            [audioCodecsArray removeObjectAtIndex:sourceIndexPath.row];
            [audioCodecsArray insertObject:dict atIndex:destinationIndexPath.row];
            
        }
        else{
            NSDictionary *dict = videoCodecsArray[sourceIndexPath.row];
            [videoCodecsArray removeObjectAtIndex:sourceIndexPath.row];
            [videoCodecsArray insertObject:dict atIndex:destinationIndexPath.row];
        }
    }
    
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath1 = [path stringByAppendingString:[NSString stringWithFormat:@"/%@",audioFilePath]];
    NSString * filePath2 = [path stringByAppendingString:[NSString stringWithFormat:@"/%@",videoFilePath]];
    
    
    
    
    [audioCodecsArray writeToFile:filePath1 atomically:YES];
    [videoCodecsArray writeToFile:filePath2 atomically:YES];
    
    
    
    [self.tableView reloadData];
}

@end

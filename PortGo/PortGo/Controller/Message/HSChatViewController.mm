//
//  HSChatViewController.m
//  PortGo
//
//  Created by MrLee on 14-10-7.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//
#import "HSChatViewController.h"
#import "HSChatMessage.h"
#import "HSChatFrame.h"
#import "History.h"
#import "DataBaseManage.h"
#import "AppDelegate.h"
#import "PeoplePicker.h"
#import "NSString+HSFilterString.h"
#import "UIImage+HSImage.h"
#import "ChatViewCell.h"
#import "SelectNumberViewController.h"
#import "UIColor_Hex.h"
#import "Toast+UIView.h"
#import "MJRefresh.h"
#import "MBProgressHUD.h"

#import "PPStickerInputView.h"
#import "PPUtil.h"

#import "YJVideoController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PKShortVideo.h"

#import "ShortVideoCell.h"

#import "MSSBrowseDefine.h"
#import "UIImageView+WebCache.h"

#import "AFNetworking-umbrella.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "XMPlayer.h"
//#import <SDWebImage/UIImageView+WebCache.h>
//#import "DPAudioPlayer.h"

//#import "amr_wav_converter.h"
#include <CoreGraphics/CGImage.h>
#import "HttpHelper.h"

#define MAXBubbleWidth 250


#define UcBaseURl  @"http://192.168.1.11:8888"

@interface HSChatViewController ()<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate,ABUnknownPersonViewControllerDelegate,ABPersonViewControllerDelegate, UITextFieldDelegate, PeoplePickerDelegate,ABPeoplePickerNavigationControllerDelegate, UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIDocumentPickerDelegate,UINavigationControllerDelegate ,PPStickerInputViewDelegate,AVAudioPlayerDelegate,UIDocumentInteractionControllerDelegate>
{
    //    NSMutableArray *_messages;
    NSMutableDictionary *_messageDics;
    
    NSInteger showindex;
    NSMutableArray * showArray;
    
    NSMutableArray *orderSections;
    Contact *_contact;
    UIButton *_rightButton;
    UIView *_dimView;
    
    CGRect _footViewRect;
    CGRect _msgBoxRect;
    
    BOOL _showHeadView;
    BOOL _contactAdded;
    
    ChatViewCell *_mSelectedCell;
    NSIndexPath *_mSelectedIndexPath;
    
    ABPeoplePickerNavigationController *_picker;
    
    MediaType_t chatType;
    
    UIFont *_sysFont;
    
    NSTimeInterval lastInterval;
    NSTimeInterval currentInterval;
    //    HSChatMessage *lastMessage;
    __strong UIView *_statsView;
    NSString *timeTitle;
    NSString *tempnickName;
    BOOL  isExistenceData;
    BOOL sendImageBool;
    NSURL *testvideoURL;
    
    NSTimer *_timer; //定时器
    NSInteger countDown;  //倒计时
    NSString *filePath;
    
    HSChatMessage *fowardMessage;
    MBProgressHUD *_SendHUD;
}

@property (nonatomic, strong) PPStickerInputView *ppinputView;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
//@property (weak, nonatomic) IBOutlet UITextField *sendToTextField;
//@property (strong, nonatomic) IBOutlet UIView *headView;
@property (strong, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet UIView *moreView;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *userInfoButton;
@property (strong, nonatomic) IBOutlet UIView *addContactView;
@property (weak, nonatomic) IBOutlet UIButton *addContactButton;
@property (nonatomic, strong)NSArray<UIBarButtonItem *> *rightBarItems;
@property (strong, nonatomic) UILabel *titleLabel;


@property (strong, nonatomic) UITextView *msgBoxTextView;
@property (strong, nonatomic) UITextView *addContactTexteView;

@property BOOL   isEnclosure; //标识符  代表发送图片 音频 小视频
@property  NSString * temEnclosurepString;  //附件标识代码

@property UIImageView *  messageBackgroundImageview;
@property MBProgressHUD *HUD;

@property (nonatomic,strong) MPMoviePlayerViewController *mPMoviePlayerViewController;
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioRecorder *recorder;//录音器
@property (nonatomic, strong) AVAudioPlayer *player; //播放器
@property (nonatomic, strong) UIDocumentInteractionController *documentVC;
@property (nonatomic, strong) NSURL *recordFileUrl; //文件地址
//
//@property  NSString * MessageType;
//
//@property NSString * subMimeMessageType;

@end

@implementation HSChatViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _showHeadView = NO;
    }
    return self;
}

- (void)openDocumentVC:(NSURL*)fileUrl {
    self.documentVC = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
    self.documentVC.delegate = self;
    [self.documentVC presentPreviewAnimated:YES];
    //    [self.documentVC presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

- (UIViewController*)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController*)controller{
    return self;
    
}

- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller{
    return self.view;
    
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller{
    return self.view.frame;
    
}
//点击预览窗口的“Done”(完成)按钮时调用
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController*)_controller{
    //    [_controller autorelease];
}

#pragma mark ABPeoplePickerNavigationController

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    fowardMessage = nil;
    [_picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (property != kABPersonPhoneProperty && property != kABPersonEmailProperty && property != kABPersonSocialProfileProperty) {
        return;
    }
    
    ABMutableMultiValueRef phontMultif = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(phontMultif, identifier);
    
    NSString *disName = (__bridge NSString *)ABRecordCopyCompositeName(person);
    if (property == kABPersonSocialProfileProperty) {
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:(__bridge NSDictionary * _Nonnull)(ABMultiValueCopyValueAtIndex(phontMultif, index))];
        NSString *keyUrl = [dic allKeys][0];
        
        [_picker dismissViewControllerAnimated:YES completion:nil];
        if(fowardMessage!=nil){
            [self sendMessage:@"text" subMimeType:@"plain" sendTo:dic[keyUrl] sendToDisplayName:disName content:[fowardMessage.jsonContent valueForKey:KEY_TEXT_CONTENT] forward:TRUE];
        }
        fowardMessage = nil;
        
    } else if (property == kABPersonPhoneProperty) {
        NSString *aPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phontMultif, index);
        
        [_picker dismissViewControllerAnimated:YES completion:nil];
        if(fowardMessage!=nil){
            [self sendMessage:@"text" subMimeType:@"plain" sendTo:aPhone sendToDisplayName:disName content:[fowardMessage.jsonContent valueForKey:KEY_TEXT_CONTENT] forward:TRUE];
        }
        fowardMessage = nil;
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (property != kABPersonPhoneProperty && property != kABPersonEmailProperty && property != kABPersonSocialProfileProperty) {
        return YES;
    }
    
    ABMutableMultiValueRef phontMultif = ABRecordCopyValue(person, property);
    
    if (property == kABPersonPhoneProperty) {
        NSString *aPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phontMultif, identifier);
        
        [_picker dismissViewControllerAnimated:YES completion:nil];
        
        //        _numberTextField.text = aPhone;
        //        [self textFieldChanged:nil];
    }
    
    else if (property == kABPersonSocialProfileProperty) {
        NSDictionary *dic = (__bridge NSDictionary *)(ABMultiValueCopyValueAtIndex(phontMultif, identifier));
        NSString *key = [dic allKeys][0];
        
        [_picker dismissViewControllerAnimated:YES completion:nil];
        //        _numberTextField.text = dic[key];
        //        [self textFieldChanged:nil];
    }
    return NO;
}

- (void)pickPerson:(BOOL)animated {
    
    _picker = [[ABPeoplePickerNavigationController alloc] init];
    
    [_picker.topViewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tabbar_background.png"] forBarMetrics:UIBarMetricsDefault];
    [_picker.topViewController.navigationController.navigationBar setTintColor:MAIN_COLOR];
    //[self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : MAIN_COLOR}];
    [self.navigationController.navigationBar setTintColor:MAIN_COLOR];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:MAIN_COLOR}];
    
    
    
    // UIImage *colorImage = [UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)];
    
    
    [self.navigationController.navigationBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    [self.tabBarController.tabBar setShadowImage:[UIColor imageWithColor:[UIColor colorWithHexString:@"#dadada"] size:CGSizeMake(self.view.frame.size.width, 0.5)]];
    
    [self.tabBarController.tabBar setBackgroundImage:[[UIImage alloc]init]];
    
    _picker.peoplePickerDelegate = self;
    _picker.displayedProperties = @[[NSNumber numberWithInt:kABPersonSocialProfileProperty],[NSNumber numberWithInt:kABPersonPhoneProperty]];
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        _picker.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
    }
    _picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:_picker animated:animated completion:nil];
}

-(void)playSoundEffect:(NSString *)name{
    //  NSString *audioFile=[[NSBundle mainBundle] pathForResource:name ofType:nil];
    //   NSURL *fileUrl=[NSURL fileURLWithPath:name];
    //1.获得系统声音ID
    SystemSoundID soundID=1000;
    /**
     * inFileUrl: 音频文件url
     * outSystemSoundID:声 id(此函数会将音效文件加入到系统音频服务中并返回一个长整形ID) */
    // AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    //如果需要在播放完之后执行某些操作,可以调用如下方法注册一个播放完成回调函数 AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    //2.播放音频
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    if (![session setCategory:AVAudioSessionCategoryPlayback
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers
                        error:&setCategoryError]) {
        NSLog(@"开启扬声器发生错误:%@",setCategoryError.localizedDescription);
    }
    
    //AudioServicesPlaySystemSound(soundID);//播放音效
    AudioServicesPlayAlertSound(soundID);//播放音效并震动
}

- (void)reloadDataFromDB
{
    
    [_messageDics removeAllObjects];
    
    NSMutableArray *chatArray =nil;
    if(self.chatSession != nil){
        chatArray = [databaseManage selectMessageBySessionId:0 byMediaType:chatType Sessionid:self.chatSession.mRowid orderBYDESC:NO needCount:NO];
    }else{
        chatArray = [NSMutableArray new];
    }
    
    NSMutableArray *tempArr  = [NSMutableArray array];
    BOOL hasTitle = NO;
    for (History* chat in chatArray)
    {
        
        NSString *nickName = nil;
        if (IS_EVENT_OUTGOING(chat.mStatus)) {
            nickName = shareAppDelegate.account.userName;
        }
        else{
            nickName = self.chatSession.mRemoteDisname;
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        
        HSChatMessage *message = nil;
        NSDictionary *dict = nil;
        
        NSTimeInterval compare = chat.mTimeStart - lastInterval;
        NSInteger minute = ((int)compare)/(60);
        
        if (minute <= 3 && minute >= 0) {
            dict = [[NSDictionary alloc] initWithObjects:@[@(chat.mHistoryID), nickName, [chat getDetailsTimeStart], [chat getContentAsString], @(chat.mStatus),chat.mimeType,@(chat.mPlayDuration),@(chat.mRead)] forKeys:@[@"historyId", @"nickName", @"sendTime", @"msgBody", @"status",KEY_MIMETYPE,@"msglen",KEY_MESSAGE_READ]];
            message = [[HSChatMessage alloc] initWithDict:dict];
            [tempArr addObject:message];
            hasTitle = YES;
            
        } else {
            
            tempArr = [NSMutableArray array];
            hasTitle = NO;
            dict = [[NSDictionary alloc] initWithObjects:@[@(chat.mHistoryID), nickName, [chat getDetailsTimeStart], [chat getContentAsString], @(chat.mStatus),chat.mimeType,@(chat.mPlayDuration),@(chat.mRead)] forKeys:@[@"historyId", @"nickName", @"sendTime", @"msgBody", @"status",KEY_MIMETYPE,@"msglen",KEY_MESSAGE_READ]];
            message = [[HSChatMessage alloc] initWithDict:dict];
            
            [tempArr addObject:message];
            
        }
        
        if (!hasTitle) {
            timeTitle = [chat getDetailsTimeStart];
        }
        
        [_messageDics setObject:tempArr forKey:timeTitle];
        
        lastInterval = chat.mTimeStart;
        
    }
    
    
    NSMutableArray *arr = [self compareEntryByDateStringWith:[_messageDics allKeys]];
    
    showArray = [[NSMutableArray alloc]init];
    
    if (arr.count>0) {
        if (arr.count==1) {
            [showArray insertObject:arr.lastObject atIndex:0];
        }
        else{
            
            NSMutableArray *temp  = [[NSMutableArray alloc]initWithArray:arr];
            
            [showArray insertObject:temp.lastObject atIndex:0];
            
            [temp removeObject:[temp lastObject]];
            
            [showArray insertObject:temp.lastObject atIndex:0];
        }
    }
    //NSLog(@"showArray  showArray = %@",showArray);
    [_chatTableView reloadData];
    
}

-(void)setstaimage :(BOOL)online{
    _ifonline = online;
}

- (void)setTitleName
{
    if(self.chatSession==nil){
        self.titleLabel.text = NSLocalizedString(@"New Message", @"New Message");
        self.remoteName.text= @"";
        [self showTableViewHeaderView];
        self.navigationItem.rightBarButtonItems =nil;
        return;
    }else{
        [self hideTableViewHeaderView];
        self.navigationItem.rightBarButtonItems = self.rightBarItems;
        
        if (_contact == nil) {//haven't contact
            if(self.chatSession.mRemoteDisname.length>0){//has displayName show displayName
                self.remoteName.text = self.chatSession.mRemoteDisname;
            } else {
                //check is same server, hide ip or domain,just display user name
                Account *selfAccount = [portSIPEngine mAccount];
                NSString* dispalyTitle = self.chatSession.mRemoteUri;
                if ([dispalyTitle rangeOfString:@"@"].location != NSNotFound) {
                    NSArray *fromServer=[dispalyTitle componentsSeparatedByString:@"@"];
                    if([fromServer count]==2)
                    {//from and to is same, use userName
                        NSArray *fromServerAddr=[[fromServer objectAtIndex:1] componentsSeparatedByString:@":"];
                        
                        if([fromServerAddr[0] isEqual:selfAccount.userDomain] ||
                           [fromServerAddr[0] isEqual:selfAccount.SIPServer]){//This is same server
                            dispalyTitle= fromServerAddr[0];
                        }
                    }
                }
                
                self.remoteName.text = dispalyTitle;
            }
        }
        else{
            //   self.remoteName.text = _contact.displayName;
            NSString * tempname = _contact.displayName;
            NSArray * contactViewARR = [contactView contacts];
            
            
            NSLog(@"c_remoteParty=====%@",self.chatSession.mRemoteUri);
            
            for (Contact *con in  contactViewARR   ) {
                for (NSDictionary * dic  in  con.IPCallNumbers) {
                    //   NSLog(@"VoIP Call=====%@",[dic objectForKey:NSLocalizedString(@"VoIP Call", @"VoIP Call")]);
                    
                    if ([self.chatSession.mRemoteUri isEqualToString:[dic objectForKey:NSLocalizedString(@"VoIP Call", @"VoIP Call")]]) {
                        tempname =con.displayName;
                        break;
                    }
                }
            }
            
            self.remoteName.text = tempname;
        }
        
        self.titleLabel.text =  self.remoteName.text;
        
#ifdef INPUT_EMAIL_SIGN    //shi fou shuru @
        if ([self.titleLabel.text rangeOfString:@"@"].location !=NSNotFound) {
            
            NSArray *strs = [self.titleLabel.text componentsSeparatedByString:@"@"];
            
            
            self.titleLabel.text = strs[0];
        }
#endif
    }
}

-(void)dealloc
{
    NSArray* cells = self.chatTableView.visibleCells;
    for(UITableViewCell* tvcell in cells){
        if([tvcell isKindOfClass:ChatViewCell.class]){
            NSLog(@"unregister Cell =%p",tvcell);
            [self removeObserver:tvcell forKeyPath:@"playID"];
        }
    }
    NSLog(@"chatview dealloc");
}

-(void)loadmessage{
    
    NSLog(@"new message reloadDataFromDB");
    // [self playSoundEffect:nil];
    [self refreshDataAndReload];
}


-(NSData*)getExistenceImageData{
    if(self.chatSession==nil){
        return [[NSData alloc]init];;
    }
    
    NSString* tempname = self.chatSession.mRemoteUri;
    NSString * name;
    
    if ([tempname rangeOfString:@"@"].location!=NSNotFound) {
        
        NSArray *strs = [tempname componentsSeparatedByString:@"@"];
        
        NSString *first = strs[0];
        
        if (first.length>0) {
            
            name = [NSString stringWithFormat:@"BG_%@",first];
        }
        
    }else
    {
        name = [NSString stringWithFormat:@"BG_%@",self.chatSession.mRemoteUri];
    }
    
    NSData * imageData = [[NSUserDefaults standardUserDefaults]objectForKey:name];
    
    if (imageData.length>1 ){
        return  imageData;
    }else
    {
        return  [[NSData alloc]init];
    }
    
}


-(void)setBackgroundImageview{
    
    _messageBackgroundImageview = [[UIImageView alloc]init];
    
    _messageBackgroundImageview.frame = CGRectMake(0, -64, ScreenWid, ScreenHeight);
    
    _messageBackgroundImageview.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:_messageBackgroundImageview];
    
    [self.view sendSubviewToBack:_messageBackgroundImageview];
    
    NSData * imageData = [self getExistenceImageData];
    
    if (imageData.length>1 ) {
        
        NSLog(@"imageData is existence");
        [_chatTableView reloadData];
        _messageBackgroundImageview.image = nil;
        _messageBackgroundImageview.image  =    [UIImage imageWithData:imageData];
    }
    else
    {
        [_chatTableView reloadData];
    }
}


-(void)selectPhoto{
    
    NSLog(@"selectPhoto");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Setting up chat background", @"Setting up chat background") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take a picture", @"Take a picture"),NSLocalizedString(@"Select from Photo", @"Select from Photo"),NSLocalizedString(@"Delete chat background", @"Delete chat background"),nil];
    
    actionSheet.tag = 6153;
    sendImageBool = NO;
    [actionSheet showInView:self.navigationController.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [_msgBoxTextView resignFirstResponder];
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return ;
    }
    
    if (actionSheet.tag == 6153 ) {
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.allowsEditing = NO;
        picker.editing = YES;
        picker.navigationBar.translucent = NO;
        
        switch (buttonIndex) {
            case 0:
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    picker.delegate=self;
                    picker.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:picker animated:YES completion:^{
                        
                    }];
                }
                else {
                    NSLog(@"不支持相机");
                }
                
                break;
                
                
            case 1:
                
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    picker.delegate = self;
                    picker.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:picker animated:YES completion:^{
                        
                    }];
                }
                
                break;
                
            case 2:
                
                NSString* tempname = self.chatSession.mRemoteUri;
                
                NSString * name;
                
                if ([tempname rangeOfString:@"@"].location!=NSNotFound) {
                    
                    NSArray *strs = [tempname componentsSeparatedByString:@"@"];
                    
                    NSString *first = strs[0];
                    
                    if (first.length>0) {
                        
                        name = [NSString stringWithFormat:@"BG_%@",first];
                    }
                    
                }else
                {
                    
                    name = [NSString stringWithFormat:@"BG_%@",self.chatSession.mRemoteUri];
                }
                
                _messageBackgroundImageview.image = nil;
                
                NSData *tempdata  = [NSData data];
                
                [[NSUserDefaults standardUserDefaults]setObject:tempdata forKey:name];
                
                [_chatTableView reloadData];
                
                break;
                
        }
        
    }
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if(!([self getSenderReceive]>0))
        return;
    
    if (sendImageBool) {
        //发送图片
        
        NSLog(@"发送图片");
        
        NSLog(@"info==================================%@",info);
        
        if (@available(iOS 11.0, *)) {
            NSURL * testurl = info[UIImagePickerControllerImageURL];
            
            NSLog(@"从相册选取的是Url=",testurl);
            
            NSString * type = info[UIImagePickerControllerMediaType];
            
            if ([type isEqualToString:@"public.movie"]) {
                NSURL *fileurl = info[UIImagePickerControllerMediaURL];
                [self mpv_mp4:fileurl sendTo:self.chatSession.mRemoteUri sendToDisplayName:self.chatSession.mRemoteDisname];
                //                [HttpHelper saveImageToSandbox:image sandBoxPath:filePath];
                //                 long messageid =[self sendFileMessage:@"video" subMimeType:@"mp4" sendTo:self.sendTo sendToDisplayName:self.sendToDisplayName content:[fileurl absoluteString]];
                //                [httpHelper uploadFile:[databaseManage selectActiveAccount] mediatype:@"wav" fileurl:fileurl messageid:messageid];
                
            }
            else if ([type isEqualToString:@"public.image"]){
                NSURL *fileurl = info[UIImagePickerControllerImageURL];
                UIImage* image =  info[UIImagePickerControllerOriginalImage];
                
                NSString *fileName = [NSUUID new].UUIDString;
                NSString *extName= @".jpeg";
                NSString *doc =[HttpHelper docFilePath];
                NSString *sandbox =[NSString stringWithFormat:@"%@/%@%@",MEDIAFILE_PAHT,fileName,extName];
                NSString *fullfilePath = [doc stringByAppendingPathComponent:sandbox];
                
                if([HttpHelper saveImageToSandbox:image sandBoxPath:fullfilePath]){
                    NSLog(@"saveImageToSandbox filePath =%@ sucess",fullfilePath);
                }
                NSString* mime = [MIME_MEDIA_IMAGE stringByAppendingString:MIME_MEDIA_IMAGE_JPG];
                NSDictionary* jsonContent = [History construtImageMessage:sandbox loadUrl:@"" mimeType:mime FileSize:0 ImageWidth:0 ImageHeight:0];
                long messageid =[self sendFileMessage:self.chatSession.mRemoteUri sendToDisplayName:self.chatSession.mRemoteDisname JsonContent:jsonContent duration:0];
                [httpHelper uploadFile:[databaseManage selectActiveAccount] mediatype:MIME_MEDIA_IMAGE_JPG fileurl:fileurl messageid:messageid];
            }
            
            
        } else {
            // Fallback on earlier versions
        }
        
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self reloadDataFromDB];
        [self scrollToBottom:YES];
        return;
        
    }
    
    if (image) {
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0);
        
        
        NSString* tempname = self.chatSession.mRemoteUri;
        
        NSString * name;
        
        if ([tempname rangeOfString:@"@"].location!=NSNotFound) {
            
            NSArray *strs = [tempname componentsSeparatedByString:@"@"];
            
            NSString *first = strs[0];
            
            if (first.length>0) {
                
                name = [NSString stringWithFormat:@"BG_%@",first];
            }
            
        }else
        {
            name = [NSString stringWithFormat:@"BG_%@",self.chatSession.mRemoteUri];
        }
        
        NSLog(@"name 2=%@",name);
        
        // [[NSUserDefaults standardUserDefaults]setBool:YES forKey:name];
        
        
        [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:name];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        
        _messageBackgroundImageview.image = nil;
        _messageBackgroundImageview.image = image;
        
    }
    
    
    //    _HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
    //    //[self.view addSubview:_HUD];
    //    [_HUD show:YES];
    
    //  sleep(1);
    
    
    // 延迟2秒执行：
    //    double delayInSeconds = 2.0;
    //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}


#pragma mark -
#pragma mark viewdidload

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    UIColor* bkColorLight;
    UIColor* frontColor;
    UIColor* textColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
        bkColorLight = [UIColor colorNamed:@"mainBKColorLight"];
        frontColor = [UIColor colorNamed:@"mainFrontColor"];
        textColor= [UIColor colorNamed:@"textColor"];
    }
    else{
        bkColor = [UIColor colorWithHexString:@"#f4f3f3"];
        bkColorLight= [UIColor colorWithHexString:@"#e4e3e3"];
        frontColor = UIColor.blackColor;
        textColor= UIColor.blackColor;
    }
    _moreView.backgroundColor = bkColor;
    [self.tabBarController.tabBar setBarTintColor:bkColor];
    UIView *tableBackgroundView = [[UIView alloc]initWithFrame:self.chatTableView.bounds];
    tableBackgroundView.backgroundColor = bkColor;
    
    self.chatTableView.backgroundView = tableBackgroundView;
    self.ppinputView.backgroundColor = bkColorLight;
    self.footView.backgroundColor = bkColor;
    self.view.backgroundColor = bkColor;
    self.addContactView.backgroundColor = bkColorLight;
    [self.msgBoxTextView setBackgroundColor:bkColorLight];
    [self.msgBoxTextView setTextColor: textColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem* audiocall=    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"message_nav_audio_ico"] style:UIBarButtonItemStylePlain target:self action:@selector(onAudioCall:)];
    
    UIBarButtonItem* vadiocall=    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"message_nav_video_ico"] style:UIBarButtonItemStylePlain target:self action:@selector(onVideoCall:)];
    self.rightBarItems = @[vadiocall,audiocall];
    
    _msgBoxTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, 258, 40)];
    _addContactTexteView = [[UITextView alloc] initWithFrame:CGRectMake(13, 12, 294, 35)];
    
    [_footView addSubview:_msgBoxTextView];
    [_addContactView addSubview:_addContactTexteView];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //  [self.view addSubview:self.inputView];
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = MAIN_COLOR;
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
        self.titleLabel .userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectPhoto)];
        
        [ self.titleLabel addGestureRecognizer:tap];
    }
    
    self.navigationItem.titleView = self.titleLabel;
    
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadmessage) name:@"loadmessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _sendButton.enabled = NO;
    
    _messageDics = [NSMutableDictionary dictionary];
    orderSections = [NSMutableArray array];
    
    _dimView = [[UIView alloc] initWithFrame:self.view.frame];
    //  [_dimView setBackgroundColor:[UIColor blackColor]];
    _dimView.alpha = 0.5;
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePopView)];
    [_dimView addGestureRecognizer:tapGesture];
    [self.view addSubview:_dimView];
    [_dimView setHidden:YES];
    
    UIGestureRecognizer *tableTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [_chatTableView addGestureRecognizer:tableTapGesture];
    
    [_chatTableView registerNib:[UINib nibWithNibName:@"ChatViewCell" bundle:nil] forCellReuseIdentifier:@"HSChatCell"];
    _chatTableView.sectionFooterHeight = 0.1;
    _chatTableView.backgroundColor = [UIColor clearColor];
    
    //   _chatTableView.backgroundColor = [UIColor orangeColor];
    
    CGRect moreViewRect = _moreView.frame;
    moreViewRect.origin.x = 0;
    moreViewRect.origin.y = -64;
    [_moreView setFrame:moreViewRect];
    [self.view addSubview:_moreView];
    
    _msgBoxTextView.delegate = self;
    _msgBoxTextView.autoresizingMask = UIViewAutoresizingNone;
    
    CGFloat height = 0.0f;
    CGSize size = CGSizeMake(_msgBoxTextView.textContainer.size.width, MAXFLOAT);
    CGRect rect = [@"W" boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0]}
                                     context:nil];
    height = rect.size.height;
    UIEdgeInsets inset = _msgBoxTextView.textContainerInset;
    inset.top = (_msgBoxTextView.bounds.size.height - height) / 2.0f;
    inset.bottom = inset.top;
    _msgBoxTextView.textContainerInset = inset;
    
    _footViewRect = _footView.frame;
    _msgBoxRect = _msgBoxTextView.frame;
    
    //    _sendToTextField.returnKeyType = UIReturnKeyDone;
    //    _sendToTextField.delegate = self;
    
    _addContactTexteView.returnKeyType = UIReturnKeyDone;
    _addContactTexteView.delegate = self;
    
    _msgBoxTextView.returnKeyType = UIReturnKeySend;
    
    self.placehoder.text = NSLocalizedString(@"Enter message", @"Enter message");
    
    
#ifndef HAVE_VIDEO
    CGPoint userInfoCenter = _userInfoButton.center;
    userInfoCenter.x = (_audioButton.center.x + _userInfoButton.center.x) / 2;
    [_userInfoButton setCenter:userInfoCenter];
    
    CGPoint audioCenter = _audioButton.center;
    audioCenter.x = (_videoButton.center.x + _audioButton.center.x) / 2;
    [_audioButton setCenter:audioCenter];
    [_videoButton removeFromSuperview];
#endif
    
    _sysFont = SYSTEM_FONT;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChange:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headRefresh)];
    header.lastUpdatedTimeLabel.hidden = YES;
    
    _chatTableView.mj_header = header;
    // UCtag
    //#if defined(PORTGO)
    //
    _footView.hidden = YES;
    [self.view addSubview:self.ppinputView];
    //
    //#else
    
    //      _footView.hidden = NO;
    
    
    //#endif
    
    CGFloat height2 = [self.ppinputView heightThatFits];
    CGFloat minY = CGRectGetHeight(self.view.bounds) - height2 - PP_SAFEAREAINSETS(self.view).bottom;
    self.ppinputView.frame = CGRectMake(0, ScreenHeight-50-64, CGRectGetWidth(self.view.bounds), 50);
    
    if  (IS_iPhoneX){
        
        self.ppinputView.frame = CGRectMake(0, ScreenHeight-50-64-34-30, CGRectGetWidth(self.view.bounds), 80);
    }
    
    CGRect tableviewRect = _chatTableView.frame;
    tableviewRect.size.height =   tableviewRect.size.height -50;
    
    _chatTableView.frame = tableviewRect;
    
    [self traitCollectionDidChange:self.traitCollection];
}

-(void)headRefresh{
    
    NSLog(@"header endRefreshing");
    
    NSMutableArray *arr = [self compareEntryByDateStringWith:[_messageDics allKeys]];
    
    if (arr.count == showArray.count) {
        
        [_chatTableView.mj_header endRefreshing];
        return;
    }
    
    NSString *newData = [arr objectAtIndex:arr.count - showArray.count -1];
    
    [showArray insertObject:newData atIndex:0];
    
    [_chatTableView reloadData];
    
    [_chatTableView.mj_header endRefreshing];
    
}



- (void)viewWillAppear:(BOOL)animated
{
    lastInterval = 0;
    currentInterval = 0;
    [self reloadDataFromDB];
    
    _statsView = self.statusView;
    
    [self setTitleName];
    
    [_chatTableView reloadData];
    
    [self scrollToBottom:NO];
    self.ppinputView.frame = CGRectMake(0, ScreenHeight-50-64, CGRectGetWidth(self.view.bounds), 50);
    
    if  (IS_iPhoneX){
        
        self.ppinputView.frame = CGRectMake(0, ScreenHeight-50-64-34 -30, CGRectGetWidth(self.view.bounds), 80);
    }
    
    [self hideKeyboard];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.player stop];
    [super viewWillDisappear:animated];
    _showHeadView = NO;
    if(self.chatSession!=nil){
        [databaseManage updateMessageReadStatusBySessionExceptAudio:self.chatSession.mRowid HasRead:TRUE];
    }
    _addContactTexteView.text = nil;
}


-(void)viewDidAppear:(BOOL)animated
{
    if(self.chatSession==nil){
        [self showTableViewHeaderView];
    }else{
        [self hideTableViewHeaderView];
    }
    
}


//- (void)viewSafeAreaInsetsDidChange {
//    // 补充：顶部的危险区域就是距离刘海10points，（状态栏不隐藏）
//    // 也可以不写，系统默认是UIEdgeInsetsMake(10, 0, 34, 0);
//    [super viewSafeAreaInsetsDidChange];
//    self.additionalSafeAreaInsets = UIEdgeInsetsMake(10, 0, 34, 0);
//}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    
    //NSLog(@"y=============%f",translation.y);
    if (translation.y>0) {
        [_msgBoxTextView resignFirstResponder];
    }
}

- (void)fontChange:(NSNotification*)notification
{
    _sysFont = SYSTEM_FONT;
    [self refreshDataAndReload];
}

- (void)onBack:(id)sender
{
    [self setTextViewText:nil];
    [self hidePopView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onMoreButtonClick:(UIButton*)sender
{
    
    //    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    //
    //    if (_rightButton.selected) {
    //        [self hidePopView];
    //    }
    //    else{
    //        _rightButton.selected = YES;
    //        [UIView animateWithDuration:0.2 animations:^{
    //            _moreView.transform = CGAffineTransformMakeTranslation(0, 64);
    //            [_dimView setHidden:NO];
    //        }];
    //    }
    //
    //    if (_remoteParty) {
    //        _videoButton.enabled = YES;
    //        _audioButton.enabled = YES;
    //        _userInfoButton.enabled = YES;
    //    }
    //    else{
    //        _videoButton.enabled = NO;
    //        _audioButton.enabled = NO;
    //        _userInfoButton.enabled = NO;
    //    }
    //
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        _contact = [contactView getContactByPhoneNumber:_remoteParty];
    //    });
}

- (void)hideKeyboard
{
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    
    [_msgBoxTextView resignFirstResponder];
    
}

- (void)hidePopView
{
    [self hideKeyboard];
    
    _rightButton.selected = NO;
    [UIView animateWithDuration:0.2 animations:^{
        _moreView.transform = CGAffineTransformIdentity;
        [_dimView setHidden:YES];
    }];
}



- (void)viewWillUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    
    if ([_msgBoxTextView isFirstResponder] || [_ppinputView isFirstResponder]) {
        _msgBoxTextView.tag = 1;
        NSDictionary *userInfo = [notification userInfo];
        NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [aValue CGRectValue];
        
        CGFloat keyboardTop = keyboardRect.origin.y;
        
        
        
        _footView.bounds = _ppinputView.bounds;
        
        
        CGRect newTextViewFrame = _footView.bounds;
        
        
        newTextViewFrame.origin.y = keyboardTop - _footView.bounds.size.height - 64;
        
        if (IS_iPhoneX) {
            
            newTextViewFrame.origin.y = keyboardTop - _footView.bounds.size.height - 64 -34;
            
            
        }
        
        
        //        if (newTextViewFrame.origin.y >200){
        //
        //
        //            newTextViewFrame.origin.y = 200.0;
        //
        //        }
        
        
        // Get the duration of the animation.
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        
        CGRect tableviewRect = _chatTableView.frame;
        tableviewRect.size.height = newTextViewFrame.origin.y-30 ;
        
        [UIView animateWithDuration:animationDuration animations:^{
            
            _footView.frame = newTextViewFrame;
            [_chatTableView setFrame:tableviewRect];
        }];
        
        [self scrollToBottom:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    if (_msgBoxTextView.tag == 1) {
        _msgBoxTextView.tag = 0;
        
        NSDictionary *userInfo = [notification userInfo];
        
        _footView.bounds = _ppinputView.bounds;
        
        CGRect newTextViewFrame = _footView.bounds;
        newTextViewFrame.origin.y = self.view.bounds.size.height - _footView.bounds.size.height;
        
        [_ppinputView setface];
        
        
        
        
        // Get the duration of the animation.
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        
        CGRect tableviewRect = _chatTableView.frame;
        tableviewRect.size.height = newTextViewFrame.origin.y -30 ;
        
        
        
        
        [UIView animateWithDuration:animationDuration animations:^{
            
            _footView.frame = newTextViewFrame;
            [_chatTableView setFrame:tableviewRect];
        }];
    }
}

- (void)setChatSession:(HSChatSession *)session{
    if(session!=nil){
        [databaseManage updateMessageReadStatusBySessionExceptAudio:session.mRowid HasRead:true];
        [databaseManage updateSessionUnreadCount:session.mRowid UnreadCount:0];
    }
    _chatSession = session;
}
- (void)hideTableViewHeaderView
{
    [_chatTableView setTableHeaderView:nil];
}

- (void)showTableViewHeaderView
{
    [_chatTableView setTableHeaderView:_addContactView];
    _showHeadView = YES;
}

- (IBAction)onAddButtonClick:(id)sender {
    PeoplePicker *picker = [[PeoplePicker alloc] init];
    
    [picker pickNumber:self];
}

- (IBAction)onVideoCall:(id)sender {
    [shareAppDelegate makeCall:self.chatSession.mRemoteUri videoCall:YES];
    [self hidePopView];
}

- (IBAction)onAudioCall:(id)sender {
    [shareAppDelegate makeCall:self.chatSession.mRemoteUri videoCall:NO];
    [self hidePopView];
}



#pragma mark -
#pragma mark chatview nav 添加联系人

- (IBAction)onUserDetailInfo:(id)sender {
    
    [self hidePopView];
    
    Contact* contact = _contact;
    BOOL showCreatOption = NO;
    if (_contact == nil) {//haven't contact
        NSString *remotName = nil;
        if(self.chatSession.mRemoteDisname != nil){//has displayName show displayName
            remotName = self.chatSession.mRemoteDisname;
        }
        else{
            //check is same server, hide ip or domain,just display user name
            Account *selfAccount = [portSIPEngine mAccount];
            remotName = self.chatSession.mRemoteUri;
            if ([self.chatSession.mRemoteUri rangeOfString:@"@"].location != NSNotFound) {
                NSString* dispalyTitle = self.chatSession.mRemoteUri;
                NSArray *fromServer=[self.chatSession.mRemoteUri componentsSeparatedByString:@"@"];
                if([fromServer count]==2)
                {//from and to is same, use userName
                    NSArray *fromServerAddr=[[fromServer objectAtIndex:1] componentsSeparatedByString:@":"];
                    
                    if([fromServerAddr[0] isEqual:selfAccount.userDomain] ||
                       [fromServerAddr[0] isEqual:selfAccount.SIPServer]){//This is same server
                        dispalyTitle= fromServerAddr[0];
                    }
                }
                remotName = dispalyTitle;
            }else{//haven't domain,show it
                remotName = self.chatSession.mRemoteUri;
            }
        }
        
        AddorEditViewController *addOrEdit = [[AddorEditViewController alloc] init];
        addOrEdit.modalPresentationStyle = UIModalPresentationFullScreen;
        
        if ([remotName rangeOfString:@"@"].location == NSNotFound) {
            
            
            remotName = [NSString stringWithFormat:@"%@@%@",remotName,shareAppDelegate.portSIPHandle.mAccount.userDomain];
        }
        
        addOrEdit.numbPadenterString =remotName;
        
        NSLog(@"remotName======%@",remotName);
        
        addOrEdit.recognizeID = 2888;
        
        [addOrEdit didAddChatContactCallback:^(Contact *chatContact) {
            _contact = chatContact;
            _contactAdded = YES;
        }];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addOrEdit];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
        
    }
    else{
        UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        
        ContactDetailsViewController* contactDetails = [stryBoard instantiateViewControllerWithIdentifier:@"ContactDetails"];
        
        
        contactDetails.frommessagebutton = YES;
        
        contactDetails.contact = contact;
        contactDetails.superControllerID = 1;
        contactDetails.showCreateOption = showCreatOption;
        
        NSLog(@"remoteParty remoteParty =remoteParty =%@",self.chatSession.mRemoteUri);
        
        contactDetails.partystr = self.chatSession.mRemoteUri;
        
        
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:contactDetails animated:YES];
        
        //   self.hidesBottomBarWhenPushed = NO;
    }
    
}

#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    return NO;
}


#pragma mark ABUnknownPersonViewControllerDelegate methods
// Dismisses the picker when users are done creating a contact or adding the displayed person properties to an existing contact.
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


// Does not allow users to perform default actions such as emailing a contact, when they select a contact property.
- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
                           property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

-(void)scrollToBottom:(BOOL)animated
{
    //    NSInteger maxSec = [_messageDics allKeys].count - 1;
    //    if ([_messageDics allKeys].count == 0) {
    //        return;
    //    }
    //    NSString *key = [self compareEntryByDateStringWith:[_messageDics allKeys]][maxSec];
    //    NSArray *values = _messageDics[key];
    //    if([values count] >0){
    //        [_chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([values count] - 1) inSection:maxSec] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    //    }
    
    //NSLog(@"scrollToBottom scrollToBottom scrollToBottom");
    
    if (self.chatTableView.contentSize.height > self.chatTableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height);
        [self.chatTableView setContentOffset:offset animated:YES];
        
        // NSLog(@"scrollToBottom scrollToBottom scrollToBottom22222222222");
    }
    
}

#pragma mark -
#pragma mark

-(long) sendFileMessage:(NSString*)sendTo sendToDisplayName:(NSString*)sendToDisplayName JsonContent:(NSDictionary*)content duration:(int)duration{
    NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
    NSString* mimeText = [MIME_MEDIA_APP stringByAppendingString:MIME_MEDIA_APP_JSON];
    NSString* strContent = [History convertToJsonString:content];
    NSData* dataContent = [strContent dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *nickName = shareAppDelegate.account.accountName;
    
    long messageID  = abs(random())+435;
    
    
    History* history = [[History alloc] initWithName:0
                                       byRemoteParty:sendTo
                                       byDisplayName:sendToDisplayName
                                        byLocalParty:shareAppDelegate.account.userName
                                  byLocalDisplayname:nickName
                                         byTimeStart:start
                                          byTimeStop:start
                                          byMediaype:chatType
                                        byCallStatus:OUTGOING_PROCESSING
                                           byContent:dataContent];
    history.mPlayDuration =duration;
    history.mimeType = mimeText;
    [databaseManage insertChatHistoryNew:self.chatSession.mRowid messageid:messageID withHistory:history mimetype:mimeText playLong:duration];
    
    [self refreshDataAndReload];
    return messageID;
}

-(long) sendMessage:(NSString*)mimetype subMimeType:(NSString*)subMimeType sendTo:(NSString*)sendTo
  sendToDisplayName:(NSString*)sendToDisplayName content:(NSString*)content forward:(BOOL)isFoward{
    NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
    
    NSDictionary* json = [History construtTextMessage:content];
    NSString* jsonContent = [History convertToJsonString:json];
    
    NSData* orignalContent = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSData* dataContent = [jsonContent dataUsingEncoding:NSUTF8StringEncoding];
    NSString* strmimetype = [mimetype stringByAppendingFormat:@"/%@",subMimeType];
    NSString *nickName = shareAppDelegate.account.accountName;
    
    long messageID = [ portSIPEngine sendOutOfDialogMessage:sendTo mimeType:mimetype subMimeType:subMimeType isSMS:NO message:orignalContent messageLength:(int)[orignalContent length]];
    
    History* history = [[History alloc] initWithName:0
                                       byRemoteParty:sendTo
                                       byDisplayName:sendToDisplayName
                                        byLocalParty:shareAppDelegate.account.userName
                                  byLocalDisplayname:nickName
                                         byTimeStart:start
                                          byTimeStop:start
                                          byMediaype:chatType
                                        byCallStatus:OUTGOING_PROCESSING
                                           byContent:dataContent];
    history.mimeType = strmimetype;
    
    HSChatSession* session;
    if(isFoward){
        session = [databaseManage getChatSession:shareAppDelegate.account.userName RemoteUri:sendTo
                                     DisplayName:sendToDisplayName ContactId:@""];
    }else{
        session = self.chatSession;
    }
    [databaseManage insertChatHistoryNew:session.mRowid messageid:messageID withHistory:history mimetype:strmimetype playLong:0];
    [self refreshDataAndReload];
    return messageID;
}

- (IBAction)onSendButtonClick:(id)sender {
    if (portSIPEngine.registerState != REGISTRATION_OK) {
        return;
    }
    
    NSString* msgText = _ppinputView.plainText;
    
    msgText = [msgText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去除前后的空格和回车换行符。
    if (msgText.length <= 0) {
        return;
    }
    
    if(!([self getSenderReceive]>0))
        return;
    
    [self sendMessage:@"text" subMimeType:@"plain" sendTo:self.chatSession.mRemoteUri sendToDisplayName:self.chatSession.mRemoteDisname content:msgText forward:false];
    
    [self setTextViewText:nil];
    
    _sendButton.enabled = NO;
#ifdef DEBUG
    if([msgText isEqualToString:@"65432e"]){
        UrlTest = !UrlTest;
    }
#endif
}

- (int)getSenderReceive{
    if(self.chatSession == nil){
        NSString *sendTo = _addContactTexteView.text;
        
        if(sendTo.length < 1) {
            UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Receiver is empty", @"Receiver is empty")
                                                                message:NSLocalizedString(@"Please enter receiver information OR change a contact.", @"lease enter receiver information OR change a contact.")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
            [saveAlert show];
            return -1;
        }
        
        if ([sendTo rangeOfString:@"@"].location ==NSNotFound) {
            Account *count =     shareAppDelegate.portSIPHandle.mAccount;
            if(count.userDomain.length>0){
                sendTo = [NSString stringWithFormat:@"%@@%@",sendTo,count.userDomain];
            }else{
                sendTo = [NSString stringWithFormat:@"%@@%@",sendTo,count.SIPServer];
            }
        }
        sendTo =[shareAppDelegate getShortRemoteParty:sendTo andCallee:nil];
        _contact = [contactView getContactByPhoneNumber:sendTo];
        NSString* sendToDisplayName;
        if (_contact == nil) {
            sendToDisplayName = [sendTo getUriUsername:sendTo];
        }
        else{
            sendToDisplayName = _contact.displayName;
        }
        
        NSString *localParty = [shareAppDelegate getShortRemoteParty:shareAppDelegate.account.LocalUri andCallee:nil];
        self.chatSession = [databaseManage getChatSession:localParty RemoteUri:sendTo
                                              DisplayName:sendToDisplayName ContactId:_contact==nil?@"":_contact.contdentifier];
    }
    
    [self setTitleName];
    self.title = self.remoteName.text;
    
    if(self.chatSession == nil){
        return -1;
    }else{
        _addContactTexteView.text=@"";
    }
    return self.chatSession.mRowid;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){
        if (textView == _addContactTexteView) {
            [self hideKeyboard];
            [_ppinputView showtextview];
            
            NSString * temparty  =  _addContactTexteView.text;
            _addContactTexteView.text =temparty;
            
            
        } else if (textView == _msgBoxTextView) {
            [self onSendButtonClick:nil];
            //     [_msgBoxTextView resignFirstResponder];
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView == _msgBoxTextView) {
        if ([textView.text length] > 0) {
            self.placehoder.hidden = YES;
            _sendButton.enabled = YES;
        } else {
            _sendButton.enabled = NO;
            self.placehoder.hidden = NO;
        }
    }
}

- (void)setTextViewText:(NSString *)text
{
    _msgBoxTextView.text = text;
}

#pragma mark UITableviewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *key = showArray[indexPath.section];
    NSArray *values = _messageDics[key];
    HSChatMessage *chatMessage = values[indexPath.row];
    
    return [ChatViewCell getCellHeight:chatMessage];
    
}

int TIME_HEAD_HEIGHT = 65;
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return TIME_HEAD_HEIGHT;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView * headview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, TIME_HEAD_HEIGHT)];
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, TIME_HEAD_HEIGHT)];
    
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    NSString *time = [showArray objectAtIndex:section];
    timeLabel.text = [time stringByReplacingOccurrencesOfString:@"," withString:@""]; //排序
    CGSize size = [self getAttributeSizeWithText:timeLabel.text fontSize:14.f];
    
    int  tempW = (int)ceil(size.width+10);
    int  tempH = (int)ceil(size.height+6);
    
    timeLabel.frame = CGRectMake((ScreenWid-tempW)/2, (TIME_HEAD_HEIGHT-tempH)/2+13, tempW , tempH);
    timeLabel.layer.cornerRadius = 5.0;
    timeLabel.clipsToBounds = YES;
    
    NSData * tempdata = [self getExistenceImageData];
    
    if (tempdata.length>1) {
        timeLabel.backgroundColor = [UIColor whiteColor];
        timeLabel.textColor = [UIColor blackColor];
    }else
    {
        timeLabel.backgroundColor = RGB(206, 206, 206);
        timeLabel.textColor = [UIColor whiteColor];
    }
    
    timeLabel.alpha = 0.6;
    [headview addSubview:timeLabel];
    
    
    return headview;
}

-(CGSize)getAttributeSizeWithText:(NSString *)text fontSize:(int)fontSize
{
    CGSize size=[text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
    
    size = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
    
    return size;
}

-(NSMutableArray *)compareEntryByDateStringWith:(NSArray *)originArr {
    NSDateFormatter * fomatter = [[NSDateFormatter alloc] init];
    [fomatter setTimeStyle:NSDateFormatterShortStyle];
    [fomatter setDateStyle:NSDateFormatterShortStyle];
    
    originArr = [originArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDate *date1 = [fomatter dateFromString:obj1];
        NSTimeInterval interval1 = [date1 timeIntervalSince1970];
        
        NSDate *date2 = [fomatter dateFromString:obj2];
        NSTimeInterval interval2 = [date2 timeIntervalSince1970];
        
        if (interval1 > interval2) {
            return NSOrderedDescending;
        }
        else if (interval1 < interval2) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    return [[NSMutableArray alloc]initWithArray:originArr];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if([cell isKindOfClass:ChatViewCell.class]){
        [self addObserver:cell forKeyPath:@"playID" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if([cell isKindOfClass:ChatViewCell.class]){
        [self removeObserver:cell forKeyPath:@"playID"];
    }
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return showArray.count ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = showArray[section];
    return [_messageDics[key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = showArray[indexPath.section];
    NSMutableArray *values = _messageDics[key];
    
    HSChatMessage *chatMessage = values[indexPath.row];
    NSString* messagetype = [chatMessage.jsonContent valueForKey:KEY_MESSAGE_TYPE];
    
    ChatViewCell * cell;
    if ([MESSAGE_TYPE_FILE isEqualToString:messagetype]){
        
        cell  = [tableView dequeueReusableCellWithIdentifier:CHATVIEW_TYPE_FILE];
        if (cell == nil) {
            cell = [[ChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHATVIEW_TYPE_FILE];
        }
    } else if ([MESSAGE_TYPE_IMAGE isEqualToString:messagetype]){//text/plain
        //        static NSString *ID = @"HSChatCell";
        
        cell  = [tableView dequeueReusableCellWithIdentifier:CHATVIEW_TYPE_IMAGE];
        if (cell == nil) {
            cell = [[ChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHATVIEW_TYPE_IMAGE];
        }
    }
    else if ([MESSAGE_TYPE_VIDEO isEqualToString:messagetype]){//text/plain
        //        static NSString *ID = @"HSChatCell";
        
        cell  = [tableView dequeueReusableCellWithIdentifier:CHATVIEW_TYPE_VIDEO];
        if (cell == nil) {
            cell = [[ChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHATVIEW_TYPE_VIDEO];
        }
    }else if ([MESSAGE_TYPE_AUDIO isEqualToString:messagetype]){//text/plain
        //        static NSString *ID = @"HSChatCell";
        
        cell  = [tableView dequeueReusableCellWithIdentifier:CHATVIEW_TYPE_AUDIO];
        if (cell == nil) {
            cell = [[ChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHATVIEW_TYPE_AUDIO];
        }
    }else{//text/plain
        //        static NSString *ID = @"HSChatCell";
        
        cell  = [tableView dequeueReusableCellWithIdentifier:CHATVIEW_TYPE_TEXT];
        if (cell == nil) {
            cell = [[ChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHATVIEW_TYPE_TEXT];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = [contactView numbers2ContactsMapper];
    
    NSString *temp = self.chatSession.mRemoteUri;
    
    if ([temp rangeOfString:@"@"] .location == NSNotFound) {
        
        temp = [NSString stringWithFormat:@"%@@%@",temp,shareAppDelegate.portSIPHandle.mAccount.userDomain ];
    }
    
    Contact *contact = [dic objectForKey:temp];
    
    _contact = contact;
    
    
    cell.mycontact = _contact;
    UIImage * headerimg =[UIImage imageWithData:contact.picture];
    
    if (IS_EVENT_INCOMING(chatMessage.status) ) {
        
        HSChatMessage * lastchat  = [[HSChatMessage alloc]init];
        if (indexPath.row-1 >= 0 ) {
            
            lastchat = values[indexPath.row-1];
        }
        HSChatMessage * nextchat  = [[HSChatMessage alloc]init];
        if (indexPath.row+1 <values.count &&  indexPath.row+1>=0) {
            
            nextchat = values[indexPath.row+1];
        }
        
        if (indexPath.row==0) {
            [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLT_RT_RB];
        }
        else if (indexPath.row ==  values.count-1){
            
            if (IS_EVENT_INCOMING(lastchat.status)){
                [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLB_RT_RB];
            }
            else{
                [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLT_RT_RB];
            }
        }
        else{
            
            if (IS_EVENT_INCOMING(lastchat.status)) {
                
                if (IS_EVENT_INCOMING(nextchat.status)) {
                    [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeRT_RB];
                }
                else
                {
                    [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLB_RT_RB];
                }
            }
            else
            {
                [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLT_RT_RB];
            }
            
        }
        
    }
    else if (IS_EVENT_OUTGOING(chatMessage.status)) {
        
        HSChatMessage * lastchat  = [[HSChatMessage alloc]init];
        if (indexPath.row-1 >= 0 ) {
            lastchat = values[indexPath.row-1];
        }
        
        HSChatMessage * nextchat  = [[HSChatMessage alloc]init];
        
        if (indexPath.row+1 <values.count &&  indexPath.row+1>=0) {
            nextchat = values[indexPath.row+1];
        }
        
        if (indexPath.row==0) {
            [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLT_LB_RT];
        }
        else if (indexPath.row ==  values.count-1){
            
            if (IS_EVENT_OUTGOING(lastchat.status )) {
                [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLT_LB_RB];
            }
            else{
                [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLT_LB_RT];
            }
        }
        else{
            
            if (IS_EVENT_OUTGOING(lastchat.status)) {
                if (IS_EVENT_OUTGOING( nextchat.status)) {
                    [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLT_LB];
                }
                else
                {
                    [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLT_LB_RB];
                }
            }
            else
            {
                if (IS_EVENT_OUTGOING(nextchat.status)) {
                    [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLT_LB_RT];
                }else{
                    [cell setChatMessage:chatMessage headerImage:headerimg cellType:CellCornerTypeLT_LB];
                }
            }
        }
        
    }
    
    HSChatMessage *chatMessage1  = [[HSChatMessage alloc]init];
    if (indexPath.row!=0) {
        chatMessage1 = values[indexPath.row-1];
    }
    
    BOOL  single = NO;
    
    if ( chatMessage1.status  == chatMessage.status) {
        
        single = YES;
    }
    else
    {
        single = NO;
        
    }
    
    [cell setleftimg:indexPath andBOOL:single andArr:values];
    
    tempnickName  = chatMessage.nickName;
    
    cell.onUserClickBlock = ^{
        [self onUserDetailInfo:nil];
    };
    
    cell.onMessageClickBlock=^(HSChatMessage *chatMessage,UIView* sender){
        [self onMessageClick:chatMessage Sender:sender];
    };
    
    
    cell.onMessageLongClickBlock=^(HSChatMessage *chatMessage,SEL action,UIView* sender){
        if(action == @selector(copy:)){
            
        }else if(action == @selector(delete:)){
            [databaseManage deleteChatHistory:chatMessage.historyId];
            [self refreshDataAndReload];
        }else if(action == @selector(forward:)){
            fowardMessage = chatMessage;
            [self pickPerson:YES];
        }else if(action == @selector(download:)){
            NSString* msgType = [chatMessage.jsonContent valueForKey:KEY_MESSAGE_TYPE];
            NSString *loadUrl = [chatMessage.jsonContent valueForKey:KEY_FILE_URL];
            NSString *fileName = [chatMessage.jsonContent valueForKey:KEY_FILE_NAME];
            NSString *mime;
            if ([MESSAGE_TYPE_AUDIO isEqualToString:msgType]) {
                mime = [NSString stringWithFormat:@"%@%@", MIME_MEDIA_AUDIO, MIME_MEDIA_AUDIO_AMR];
            }else if([MESSAGE_TYPE_VIDEO isEqualToString:msgType]) {
                mime = [NSString stringWithFormat:@"%@%@", MIME_MEDIA_VIDEO, MIME_MEDIA_VIDEO_MP4];
            }else if([MESSAGE_TYPE_IMAGE isEqualToString:msgType]) {
                mime = [NSString stringWithFormat:@"%@%@", MIME_MEDIA_IMAGE, MIME_MEDIA_IMAGE_JPG];
            }else if([MESSAGE_TYPE_FILE isEqualToString:msgType]) {
                mime = [NSString stringWithFormat:@"%@%@", CUSTOM_MIME_MEDIA_FILE, fileName];
            }else{
                return ;
            }
            [databaseManage updateChatHistoryStatusByRowid:chatMessage.historyId withStatus:INCOMING_PROCESSING];
            [httpHelper downloadFile:loadUrl filepath:@"" mimetype:mime historyid:chatMessage.historyId];
        }
    };
    
    return cell;
}


#pragma mark UItextViewDelegate
-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
}

- (void)longPressEvent:(UIGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint location = [recognizer locationInView:_chatTableView];
        _mSelectedIndexPath = [_chatTableView indexPathForRowAtPoint:location];
        _mSelectedCell = (ChatViewCell*)[_chatTableView cellForRowAtIndexPath:_mSelectedIndexPath];
        [_mSelectedCell becomeFirstResponder];
        UIMenuItem *itCopy = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@" Copy ", @" Copy ") action:@selector(handleCopyCell:)];
        
        UIMenuItem *itdelete = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"Delete") action:@selector(handledeleteCell:)];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:@[itCopy, itdelete]];
        [menu setMenuVisible:YES animated:YES];
        
        CGRect rect = _mSelectedCell.frame;
        [menu setTargetRect:rect inView:_chatTableView];
    }
    
}

-(void)onMessageClick:(HSChatMessage*)message Sender:(UIView*)sender{
    NSDictionary* dic =  message.jsonContent;
    NSString* messageType = [dic valueForKey:KEY_MESSAGE_TYPE];
    if([MESSAGE_TYPE_TEXT isEqualToString:messageType]){
    }else if([MESSAGE_TYPE_FILE isEqualToString:messageType]){
        NSString* filePath = [dic valueForKey:KEY_FILE_PATH];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* sandbox = [HttpHelper docFilePath];
        filePath = [sandbox stringByAppendingPathComponent:filePath];
        BOOL isDir;
        BOOL existing =[fileManager fileExistsAtPath:filePath isDirectory:&isDir];
        if(existing&&!isDir){
            
            NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
            BOOL canOpenResource = [[UIApplication sharedApplication] canOpenURL:fileUrl];
            if(canOpenResource){
                [[UIApplication sharedApplication] openURL:fileUrl];
            }else{
                [self openDocumentVC:fileUrl];
            }
        }
    }else if([MESSAGE_TYPE_AUDIO isEqualToString:messageType]){
        if(!message.msgRead){
            message.msgRead = TRUE;
        }
        
        NSString* filePath = [dic valueForKey:KEY_FILE_PATH];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* sandbox = [HttpHelper docFilePath];
        filePath = [sandbox stringByAppendingPathComponent:filePath];
        NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
        if([fileManager fileExistsAtPath:fileUrl.path ]){
            [self playExistingURL:fileUrl messageID:message.historyId];
        }
    }
    else if([MESSAGE_TYPE_VIDEO isEqualToString:messageType]){
        NSString* filePath = [dic valueForKey:KEY_FILE_PATH];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* sandbox = [HttpHelper docFilePath];
        filePath = [sandbox stringByAppendingPathComponent:filePath];
        NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
        if([fileManager fileExistsAtPath:fileUrl.path ]){
            [self playVIDEO:fileUrl];
        }
    }
    else if([MESSAGE_TYPE_IMAGE isEqualToString:messageType]){
        NSString* filePath = [dic valueForKey:KEY_FILE_PATH];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* sandbox = [HttpHelper docFilePath];
        filePath = [sandbox stringByAppendingPathComponent:filePath];
        NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
        
        if([fileManager fileExistsAtPath:fileUrl.path ]){
            [self browseImage:fileUrl clickedIV:sender.subviews[0].subviews[0]];
        }else{
        }
    }
}
-(void)onMessageLongClick:(HSChatMessage*)message Sender:(UIView*)sender{
    NSDictionary* dic =  message.jsonContent;
    NSString* messageType = [dic valueForKey:KEY_MESSAGE_TYPE];
    
    if([MESSAGE_TYPE_TEXT isEqualToString:messageType]){
    }else if([MESSAGE_TYPE_FILE isEqualToString:messageType]){
        NSString* filePath = [dic valueForKey:KEY_FILE_PATH];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* sandbox = [HttpHelper docFilePath];
        filePath = [sandbox stringByAppendingPathComponent:filePath];
        BOOL isDir;
        BOOL existing =[fileManager fileExistsAtPath:filePath isDirectory:&isDir];
        if(existing&&!isDir){
            
            NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
            BOOL canOpenResource = [[UIApplication sharedApplication] canOpenURL:fileUrl];
            if(canOpenResource){
                [[UIApplication sharedApplication] openURL:fileUrl];
            }else{
                [self openDocumentVC:fileUrl];
            }
        }
    }else if([MESSAGE_TYPE_AUDIO isEqualToString:messageType]){
        if(!message.msgRead){
            message.msgRead = TRUE;
        }
        
        NSString* filePath = [dic valueForKey:KEY_FILE_PATH];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* sandbox = [HttpHelper docFilePath];
        filePath = [sandbox stringByAppendingPathComponent:filePath];
        NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
        if([fileManager fileExistsAtPath:fileUrl.path ]){
            [self playExistingURL:fileUrl messageID:message.historyId];
        }
    }
    else if([MESSAGE_TYPE_VIDEO isEqualToString:messageType]){
        NSString* filePath = [dic valueForKey:KEY_FILE_PATH];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* sandbox = [HttpHelper docFilePath];
        filePath = [sandbox stringByAppendingPathComponent:filePath];
        NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
        if([fileManager fileExistsAtPath:fileUrl.path ]){
            [self playVIDEO:fileUrl];
        }
    }
    else if([MESSAGE_TYPE_IMAGE isEqualToString:messageType]){
        NSString* filePath = [dic valueForKey:KEY_FILE_PATH];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* sandbox = [HttpHelper docFilePath];
        filePath = [sandbox stringByAppendingPathComponent:filePath];
        NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
        
        if([fileManager fileExistsAtPath:fileUrl.path ]){
            [self browseImage:fileUrl clickedIV:sender.subviews[0].subviews[0]];
        }else{
        }
    }
}
- (void)handleCopyCell:(id)sender{//copy cell text
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _mSelectedCell.chatMessage.msgBody;
}

-(void)handleTransferCell:(id)sender {
    
}

- (void)handledeleteCell:(id)sender{//delete cell
    
    [databaseManage deleteHistory:_mSelectedCell.chatMessage.historyId];
    [_chatTableView beginUpdates];
    //    [_messages removeObjectAtIndex:_mSelectedIndexPath.row];
    NSString *key = [[_messageDics allKeys] objectAtIndex:_mSelectedIndexPath.section];
    NSArray *arr = _messageDics[key];
    NSMutableArray *mutiArr = [arr mutableCopy];
    [mutiArr removeObjectAtIndex:_mSelectedIndexPath.row];
    [_messageDics setObject:mutiArr forKey:key];
    
    [_chatTableView deleteRowsAtIndexPaths:@[_mSelectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (![_chatTableView cellForRowAtIndexPath:_mSelectedIndexPath]) {
        [_chatTableView deleteSections:[NSIndexSet indexSetWithIndex:_mSelectedIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    [_chatTableView endUpdates];
}

-(void)handleMoreCell:(id)sender {
}

-(BOOL) peoplePicker: (PeoplePicker *)picker shouldContinueAfterPickingNumber: (NgnPhoneNumber*)number{
    
    _addContactTexteView.text = number.number;
    [picker dismiss];
    
    return NO;
}

-(BOOL) peoplePicker:(PeoplePicker *)picker shouldContinueAfterPickingIPNumber:(NSDictionary *)ipNumber {
    NSString *key = [ipNumber allKeys][1];
    _addContactTexteView.text = ipNumber[key];
    [picker dismiss];
    
    return NO;
}

-(UILabel *)creatSingleMarkwitihtag:(NSInteger)tag title:(NSString *)title {
    
    CGSize size = CGSizeMake(320, MAXFLOAT);
    CGRect rect = [title boundingRectWithSize:size
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:SYSTEM_FONT}
                                      context:nil];
    
    UILabel *mark = [[UILabel alloc] initWithFrame:CGRectMake(5, 7, rect.size.width + 15, rect.size.height + 5)];
    mark.text = title;
    mark.backgroundColor = [UIColor colorWithRed:245.0/255 green:245.0/255 blue:245.0/255 alpha:1];
    mark.textAlignment = NSTextAlignmentCenter;
    mark.layer.cornerRadius = mark.bounds.size.height / 2;
    mark.layer.borderColor = [UIColor lightGrayColor].CGColor;
    mark.layer.borderWidth = 1.0;
    mark.clipsToBounds = YES;
    return mark;
}

-(BOOL) peoplePicker: (PeoplePicker *)picker shouldContinueAfterPickingContact: (Contact*)pickerContact{
    return YES;
}

#pragma mark

- (void)refreshDataAndReload
{
    [self reloadDataFromDB];
    //   [_chatTableView reloadData];
    [self scrollToBottom:NO];
}

- (BOOL)checkRemoteParty:(NSString *)checkParty
{
    return [self.chatSession.mRemoteUri isEqualToString:checkParty];
}


#pragma mark emjol

- (PPStickerInputView *)ppinputView
{
    if (!_ppinputView) {
        _ppinputView = [[PPStickerInputView alloc] init];
        [_ppinputView setEnableFileMessage:[shareAppDelegate pbxSuuportFileTransfer]];
        _ppinputView.delegate = self;
    }
    return _ppinputView;
}

#pragma mark - PPStickerInputViewDelegate

- (void)stickerInputViewDidClickSendButton:(PPStickerInputView *)inputView
{
    NSString *plainText = inputView.plainText;
    if (!plainText.length || !(([self getSenderReceive]>0))) {
        return;
    }
    
    [self onSendButtonClick:nil];
    [inputView clearText];
}

#pragma mark-
#pragma mark inputviewdelegate


- (void)ChatSendFile{
    if(([self getSenderReceive]>0)){
        NSArray* documentTypes = [NSArray arrayWithObjects:
                                  @"public.content",
                                  @"public.text",
                                  @"public.source-code",
                                  @"public.image",
                                  @"public.audiovisual-content",
                                  @"com.adobe.pdf",
                                  @"com.apple.keynote.key",
                                  @"com.microsoft.word.doc",
                                  @"com.microsoft.excel.xls",
                                  @"com.microsoft.powerpoint.ppt",nil];
        UIDocumentPickerViewController* docPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
        docPicker.delegate = self;  //UIDocumentPickerDelegate
        docPicker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:docPicker animated:true completion:nil];
    }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls NS_AVAILABLE_IOS(11_0){
    for(NSURL* url in urls){
        NSURL *fileurl = url;//info[UIImagePickerControllerImageURL];
        NSString *fileName =url.lastPathComponent;
        
        NSString *doc =[HttpHelper docFilePath];
        NSString *sandbox =[NSString stringWithFormat:@"%@/%@",MEDIAFILE_PAHT,fileName];
        NSString *fullfilePath = [doc stringByAppendingPathComponent:sandbox];
        long lSize = 0;
        
        
        if([HttpHelper saveFileToSandbox:fileurl sandBoxPath:fullfilePath]){
            NSFileManager* manager = [NSFileManager defaultManager];
            lSize = (long)[[manager attributesOfItemAtPath:fullfilePath error:nil] fileSize];
        }
        
        NSString*mime = [self mimeTypeForFileAtPath:sandbox];
        NSDictionary* jsonContent = [History construtFileMessage:fileName FilePath:sandbox loadUrl:@"" mimeType:mime FileSize:lSize];
        long messageid =[self sendFileMessage:self.chatSession.mRemoteUri sendToDisplayName:self.chatSession.mRemoteDisname JsonContent:jsonContent duration:0];
        [httpHelper uploadFile:[databaseManage selectActiveAccount] mediatype:CUSTOM_MIME_MEDIA_FILE fileurl:[[NSURL alloc] initFileURLWithPath:fullfilePath isDirectory:NO relativeToURL:nil] messageid:messageid];
        //    }
    }
    
}
- (NSString *)mimeTypeForFileAtPath:(NSString *)path
{
    if (![[[NSFileManager alloc] init] fileExistsAtPath:path]) {
        return @"application/octet-stream";
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}
// called if the user dismisses the document picker without selecting a document (using the Cancel button)
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    
}

- (void)ChatSendImage{
    
    if(!([self getSenderReceive]>0))
        return;
    
    sendImageBool = YES;
    
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.allowsEditing = NO;
    picker.editing = YES;
    picker.navigationBar.translucent = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [picker setMediaTypes:  [NSArray arrayWithObjects:@"public.image", nil]];
        picker.delegate = self;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:^{
            
        }];
    }
}

- (void)ChatSendCustomCamera{
    
    NSLog(@"ChatSendCustomCamera");
    if(!([self getSenderReceive]>0)){
        return;
    }
    
    YJVideoController *videoC = [[YJVideoController alloc] init];
    videoC.modalPresentationStyle = UIModalPresentationFullScreen;
    videoC.takeBlock = ^(id item) {
        if ([item isKindOfClass:[NSURL class]]) {
            //视频url
            NSURL *videoURL = item;
            testvideoURL = item;
            NSLog(@"videoURL=====%@",videoURL);
            [self mpv_mp4:videoURL sendTo:self.chatSession.mRemoteUri sendToDisplayName:self.chatSession.mRemoteDisname];
        } else {
            if (item) {
                UIImage *image = item;
                
                NSString *fileName = [NSUUID new].UUIDString;
                NSString *extName= @".jpeg";
                NSString *doc =[HttpHelper docFilePath];
                NSString *sandbox =[NSString stringWithFormat:@"%@/%@%@",MEDIAFILE_PAHT,fileName,extName];
                NSString *fullfilePath = [doc stringByAppendingPathComponent:sandbox];
                
                if([HttpHelper saveImageToSandbox:image sandBoxPath:fullfilePath]){
                    NSLog(@"saveImageToSandbox filePath =%@ sucess",fullfilePath);
                }
                
                NSString* mime = [MIME_MEDIA_IMAGE stringByAppendingString:MIME_MEDIA_IMAGE_JPG];
                NSDictionary* jsonContent = [History construtImageMessage:sandbox loadUrl:@"" mimeType:mime FileSize:0 ImageWidth:0 ImageHeight:0];
                long messageid = [self sendFileMessage:self.chatSession.mRemoteUri sendToDisplayName:self.chatSession.mRemoteDisname JsonContent:jsonContent duration:0];
                
                [httpHelper uploadFile:[databaseManage selectActiveAccount] mediatype:MIME_MEDIA_IMAGE_JPG fileurl:[NSURL fileURLWithPath:fullfilePath] messageid:messageid];
            }
            
        }
    };
    videoC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:videoC animated:YES completion:nil];
    
}

-(void)ChatMakeCall:(BOOL)video{
    if(!([self getSenderReceive]>0))
        return;
    
    if (video){
        NSLog(@"ChatMakeCall video");
        [self onVideoCall:nil];
    }else
    {
        NSLog(@"ChatMakeCall ");
        [self onAudioCall:nil];
    }
}

-(void)mpv_mp4:(NSURL*)url sendTo:(NSString*)sendTo sendToDisplayName:(NSString*)sendToDisplayName{
    
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    NSLog(@"%@",compatiblePresets);
    
    NSString *fileName = [NSUUID new].UUIDString;
    NSString *extName= @".MP4";
    NSString *doc =[HttpHelper docFilePath];
    NSString *videoSandbox =[NSString stringWithFormat:@"%@/%@%@",MEDIAFILE_PAHT,fileName,extName];
    NSString *videoFullFilePath = [doc stringByAppendingPathComponent:videoSandbox];
    
    UIImage* image = [UIImage pk_previewImageWithVideoURL:url];
    if(image!=NULL){
        NSString *jpegExt= @".jpeg";
        //        NSString *jpgSandbox =[NSString stringWithFormat:@"%@/%@/%@%@",MEDIAFILE_PAHT,fileName,MEDIA_THUMBNAIL_FILE_PAHT,jpegExt];
        NSString *jpgSandbox =[NSString stringWithFormat:@"%@/%@%@",MEDIAFILE_PAHT,fileName,jpegExt];
        NSString *jpgfullfilePath = [doc stringByAppendingPathComponent:jpgSandbox];
        [HttpHelper saveImageToSandbox:image sandBoxPath:jpgfullfilePath];
    }
    
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        
        NSLog(@"exportPath =output File Path : %@",videoFullFilePath);
        
        exportSession.outputURL = [NSURL fileURLWithPath:videoFullFilePath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         {
            
            switch (exportSession.status) {
                    
                case AVAssetExportSessionStatusUnknown:
                    break;
                    
                case AVAssetExportSessionStatusWaiting:
                    break;
                    
                case AVAssetExportSessionStatusExporting:
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    NSString* mime = [MIME_MEDIA_VIDEO stringByAppendingString:@"mp4"];
                    NSDictionary* jsonContent = [History construtVideoMessage:videoSandbox loadUrl:@"" mimeType:mime FileSize:0 AVDuration:0];
                    long messageid = [self sendFileMessage:sendTo sendToDisplayName:sendToDisplayName JsonContent:jsonContent duration:0];
                    [httpHelper uploadFile:[databaseManage selectActiveAccount] mediatype:MIME_MEDIA_VIDEO_MP4 fileurl:[NSURL fileURLWithPath:videoFullFilePath] messageid:messageid];
                }
                    break;
                    
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"AVAssetExportSessionStatusFailed");
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"AVAssetExportSessionStatusFailed");
                    break;
            }
        }];
    }
}

-(void)browseImage:(NSURL*)filePath clickedIV:(UIImageView*)smallImageview{
    NSMutableArray *browseItemArray = [[NSMutableArray alloc]init];
    MSSBrowseModel *browseItem = [[MSSBrowseModel alloc]init];
    
    NSData * data = [NSData dataWithContentsOfURL:filePath];
    
    browseItem.bigImage = [UIImage imageWithData:data];
    
    browseItem.smallImageView = smallImageview;
    [browseItemArray addObject:browseItem];
    
    MSSBrowseLocalViewController *bvc = [[MSSBrowseLocalViewController alloc]initWithBrowseItemArray:browseItemArray currentIndex:0];
    [bvc showBrowseViewController];
}



-(void)playshortvideo:(NSURL*)shortvideourl{
    _mPMoviePlayerViewController = [[MPMoviePlayerViewController alloc]initWithContentURL:shortvideourl];
    
    _mPMoviePlayerViewController.view.frame = CGRectMake(0, 100, 414, 300);
    _mPMoviePlayerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:_mPMoviePlayerViewController animated:YES completion:nil];
    
    XMPlayerView *playerView = [[XMPlayerView alloc] init];
    playerView.sourceImagesContainerView = self.view;
    playerView.currentImage =[UIImage imageNamed:@"dial_nav_forward_ico@2x"];
    playerView.videoURL = shortvideourl ;
    [playerView show];
    
    
}
- (Boolean)canBeginRecord{
    return ([self getSenderReceive]>0);
}

-(void)beginRecord{
    countDown = MAX_RECORD_SECONDS;
    [self addTimer];
    
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if (session == nil) {
        
        NSLog(@"Error creating session: %@",[sessionError description]);
        
    }else{
        [session setActive:YES error:nil];
        
    }
    
    self.session = session;
    NSString *docPath = [HttpHelper docFilePath];
    NSString* fileName = [NSUUID new].UUIDString;
    NSString* wavExt = @".wav";
    NSString *sandbox =[NSString stringWithFormat:@"%@/%@%@",MEDIAFILE_PAHT,fileName,wavExt];
    NSString *wavFullFilePath = [docPath stringByAppendingPathComponent:sandbox];
    
    self.recordFileUrl = [NSURL fileURLWithPath:wavFullFilePath];
    
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];
    
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:recordSetting error:nil];
    
    if (_recorder) {
        
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];
        
    }else{
        NSLog(@"init Recorder failed");
    }
    
}


-(void)finshRecord{
    
    [self removeTimer];
    
    [_ppinputView stoprecordingview];
    
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    
    int duration = (int)(MAX_RECORD_SECONDS -countDown);
    if(duration>1){
        NSString* sandBox = [NSString stringWithFormat:@"%@/%@",MEDIAFILE_PAHT,[self.recordFileUrl lastPathComponent]];
        
        NSString* mime = [MIME_MEDIA_AUDIO stringByAppendingString:MIME_MEDIA_AUDIO_WAV];
        NSDictionary* jsonContent = [History construtAudioMessage:sandBox loadUrl:@"" mimeType:mime FileSize:0 AVDuration:duration];
        long messageid = [self sendFileMessage:self.chatSession.mRemoteUri sendToDisplayName:self.chatSession.mRemoteDisname JsonContent:jsonContent duration:duration];
        [httpHelper uploadFile:[databaseManage selectActiveAccount] mediatype:MIME_MEDIA_AUDIO_WAV fileurl:self.recordFileUrl messageid:messageid];
        
        [self reloadDataFromDB];
        [self scrollToBottom:YES];
    }else{
        [self.view makeToast:NSLocalizedString(@"Voice Message Too Short", @"Voice Message Too Short") duration:1.0 position:@"center"];
    }
    return;
    
}


-(void)cancelRecord{
    
    [self removeTimer];
    
    [_ppinputView stoprecordingview];
    
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    
    NSLog(@"cancelRecord cancelRecord cancelRecord");
    
}

- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshLabelText) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
    
}


-(void)refreshLabelText{
    
    countDown --;
    
    if (countDown == 0) {
        [self removeTimer];
        [_ppinputView stoprecordingview];
        [self finshRecord];
        
    }
}

-(void)playExistingURL:(NSURL*)ExistingURL messageID:(int)messageID{
    
    [databaseManage updateMessageReadStatusByMessageRowId:messageID HasRead:TRUE];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:ExistingURL error:nil];
    self.player.delegate = self;
    
    if([self.player prepareToPlay]){
        if([self.player play]){
            self.playID = messageID;
            return;
        }
    }
    
    self.playID = -1;
}


-(void)playVIDEO:(NSURL*)url{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    AVPlayer *player = [AVPlayer playerWithURL:url];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    playerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:playerViewController animated:YES completion:nil];
    
    [playerViewController.player play];
}

#pragma mark - player Dlegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    HSChatMessage* message = [self getNextChatMessagePlay:self.playID];
    if(message!=NULL){
        NSString* filePath = [HttpHelper.docFilePath stringByAppendingPathComponent:[message.jsonContent valueForKey:KEY_FILE_PATH]];
        [self playExistingURL:[NSURL URLWithString:filePath] messageID:message.historyId];
    }else{
        self.playID = -1;
    }
}

-(HSChatMessage*)getNextChatMessagePlay:(NSInteger)historyID{
    NSMutableArray *msgArrayArr = [_messageDics allValues];
    for (NSMutableArray* msgArray in msgArrayArr) {
        for(HSChatMessage* message in msgArray){
            if(message.historyId < historyID){
                continue;
            }else{
                NSString*type = [message.jsonContent valueForKey:KEY_MESSAGE_TYPE];
                if([MESSAGE_TYPE_AUDIO isEqualToString:type]&&IS_EVENT_INCOMING_SUCESS(message.status)){
                    if(message.msgRead){
                        return NULL;
                    }else{
                        return message;
                    }
                    
                }
            }
            
        }
    }
    return NULL;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    self.playID = -1;
}

@end

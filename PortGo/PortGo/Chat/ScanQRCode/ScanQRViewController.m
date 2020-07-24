//
//  ScanQRViewController.m
//  PortSIP
//
//  Created by 今言网络 on 2018/3/12.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import "ScanQRViewController.h"
#import "WSLScanView.h"
#import "WSLNativeScanTool.h"
#import "UIColor_Hex.h"
#import "MyQRViewController.h"
#import "AppDelegate.h"
#import "Account.h"

#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define StatusBarAndNavigationBarHeight (iPhoneX ? 88.f : 64.f)

@interface ScanQRViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    
    
    //UIBarButtonItem * ScanQRButton;
    
    Account*     mAccount;
}
@property (nonatomic, strong)  WSLNativeScanTool * scanTool;
@property (nonatomic, strong)  WSLScanView * scanView;

@end

@implementation ScanQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    
     mAccount = shareAppDelegate.portSIPHandle.mAccount;
    
    [self greatnavbar];
    
    
   
    //输出流视图
    UIView *preview  = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    [self.view addSubview:preview];
    
    __weak typeof(self) weakSelf = self;
    
    //构建扫描样式视图
    _scanView = [[WSLScanView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    _scanView.scanRetangleRect = CGRectMake(60, 120, (self.view.frame.size.width - 2 * 60),  (self.view.frame.size.width - 2 * 60));
    _scanView.colorAngle = [UIColor greenColor];
    _scanView.photoframeAngleW = 20;
    _scanView.photoframeAngleH = 20;
    _scanView.photoframeLineW = 2;
    _scanView.isNeedShowRetangle = YES;
    _scanView.colorRetangleLine = [UIColor whiteColor];
    _scanView.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _scanView.animationImage = [UIImage imageNamed:@"scanLine"];
    
    NSString* mystr = [NSString stringWithFormat:@"%@@%@",mAccount.userName,mAccount.SIPServer];
    
    
    
    BOOL   usericondataBOOL = [[NSUserDefaults standardUserDefaults]boolForKey:@"usericondataBOOL"];
    
    UIImage * tempimage = [[UIImage alloc]init];
    
    
    if (usericondataBOOL) {
        
        mAccount.usericondata = [[NSUserDefaults standardUserDefaults]objectForKey:@"usericondata"];
        
        tempimage  = [UIImage imageWithData:mAccount.usericondata];
        
    }
    else
    {
        mAccount.usericondata = nil;
        
        tempimage = [UIImage imageNamed:@"about_logo"];
        
    }
    
    
    
    
    
    _scanView.myQRCodeBlock = ^{


        MyQRViewController * myQRcon  = [[MyQRViewController alloc]init];
        
   
        
        NSLog(@"mystr===%@",mystr);
        
//            CGFloat RED = random()%255;
//            CGFloat GREEN = random()%255;
//            CGFloat BULE = random()%255;
        
        myQRcon.qrImage =  [WSLNativeScanTool createQRCodeImageWithString:mystr andSize:CGSizeMake(250, 250) andBackColor:[UIColor whiteColor] andFrontColor:MAIN_COLOR andCenterImage:tempimage];
        myQRcon.modalPresentationStyle = UIModalPresentationFullScreen;
        myQRcon.qrString = mystr;
        
        myQRcon.titlestr = NSLocalizedString(@"MyQR", @"MyQR");
        
        [weakSelf presentViewController:myQRcon animated:YES completion:nil];
        
    
    };
    _scanView.flashSwitchBlock = ^(BOOL open) {
        [weakSelf.scanTool openFlashSwitch:open];
    };
    [self.view addSubview:_scanView];
    
    
    
    
    
    
    //初始化扫描工具
    _scanTool = [[WSLNativeScanTool alloc] initWithPreview:preview andScanFrame:_scanView.scanRetangleRect];
    
 
    
    _scanTool.scanFinishedBlock = ^(NSString *scanString) {
           //   [weakSelf.scanView stopScanAnimation];
        
        NSLog(@"扫描结果== %@",scanString);
        [weakSelf.scanView finishedHandle];
        
        
        [weakSelf.scanTool sessionStopRunning];
        [weakSelf.scanTool openFlashSwitch:NO];
        
        if(weakSelf.scanDelegate!=nil){
            [weakSelf.scanDelegate scanFinish:scanString];
        }
        
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    _scanTool.monitorLightBlock = ^(float brightness) {
   //     NSLog(@"环境光感 ： %f",brightness);
        if (brightness < 0) {
            // 环境太暗，显示闪光灯开关按钮
            [weakSelf.scanView showFlashSwitch:YES];
        }else if(brightness > 0){
            // 环境亮度可以,且闪光灯处于关闭状态时，隐藏闪光灯开关
            if(!weakSelf.scanTool.flashOpen){
                [weakSelf.scanView showFlashSwitch:NO];
            }
        }
    };
    
    [_scanTool sessionStartRunning];
    [_scanView startScanAnimation];
 
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_scanView startScanAnimation];
    [_scanTool sessionStartRunning];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_scanView stopScanAnimation];
    [_scanView finishedHandle];
    [_scanView showFlashSwitch:NO];
    [_scanTool sessionStopRunning];
}


#pragma mark -- Events Handle
- (void)photoBtnClicked{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController * _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _imagePickerController.allowsEditing = YES;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    }else{
        NSLog(@"不支持访问相册");
    }
}


- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message handler:(void (^) (UIAlertAction *action))handler{
 
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark UIImagePickerControllerDelegate
//该代理方法仅适用于只选取图片时
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    //    NSLog(@"选择完毕----image:%@-----info:%@",image,editingInfo);
    [self dismissViewControllerAnimated:YES completion:nil];
    [_scanTool scanImageQRCode:image];
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColorLight"];
    }
    else{
        bkColor = [UIColor lightGrayColor];
    }
    
}

-(void)greatnavbar{
    
    UIView* navview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWid, 64)];
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColorLight"];
    }
    else{
        bkColor = [UIColor lightGrayColor];
    }
    [navview setBackgroundColor:bkColor];
    
    [self.view addSubview:navview];
    
    UILabel * titlelab = [[UILabel alloc]init];
    
    titlelab.text = NSLocalizedString(@"ScanQR", @"ScanQR");
    
    
    titlelab.font =[UIFont systemFontOfSize:19];
    
    titlelab.frame = CGRectMake((ScreenWid-150)/2, 20, 150, 44);
    
    titlelab.textColor = MAIN_COLOR;
    
    titlelab.textAlignment = NSTextAlignmentCenter;
    
    
    
    [navview addSubview:titlelab];
    
    
    UIButton * leftbutton  = [[UIButton alloc]init];
    
    leftbutton .frame = CGRectMake(0, 20, 60, 44);
    
    [leftbutton setTitle:NSLocalizedString(@"Back", @"Back") forState:UIControlStateNormal];
    
    
    [leftbutton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    
 //   leftbutton.backgroundColor = [UIColor orangeColor];
    
    [leftbutton addTarget:self action:@selector(backaction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [navview addSubview:leftbutton];
    
    
    
    UIButton * rightbutton  = [[UIButton alloc]init];
    
    rightbutton .frame = CGRectMake(ScreenWid-60, 20, 60, 44);
    
    [rightbutton setTitle:NSLocalizedString(@"Photo", @"Photo") forState:UIControlStateNormal];
    
    
   [rightbutton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    
  //  rightbutton.backgroundColor = [UIColor orangeColor];
    
    [rightbutton addTarget:self action:@selector(PhotoAction) forControlEvents:UIControlEventTouchUpInside];
    [navview addSubview:rightbutton];
    
    
    
}






-(void)backaction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



-(void)PhotoAction{
    
    NSLog(@"PhotoAction");
 
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController * _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _imagePickerController.allowsEditing = YES;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    }else{
        NSLog(@"不支持访问相册");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

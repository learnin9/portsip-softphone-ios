//
//  MyQRViewController.m
//  PortSIP
//
//  Created by 今言网络 on 2018/3/12.
//  Copyright © 2018年 PortSIP Solutions, Inc. All rights reserved.
//

#import "MyQRViewController.h"
#import "UIColor_Hex.h"

#import "AddorEditViewController.h"
@interface MyQRViewController ()<UIActionSheetDelegate>
{
    UIImageView *imageView;
 
    
    UILabel*  textlab;
    
}



@end

@implementation MyQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_pushBool) {
        
           [self greatnavbar];
    }else
    {
        
        self.title = NSLocalizedString(@"MyQR", @"MyQR");
        
    }
   
    
    
    self.view.backgroundColor =  RGB(252, 252, 252);
    
    imageView = [[UIImageView alloc]init];
    
    imageView.frame = CGRectMake((ScreenWid-250)/2, 150, 250, 250);
    
    
    [self.view addSubview:imageView];
    
    imageView.image = _qrImage;
    
    
    textlab = [[UILabel alloc]init];
    
    textlab.textAlignment = NSTextAlignmentCenter;
    
    textlab.textColor = [UIColor blackColor];
    
    textlab.text = _qrString;
    
    
    textlab.frame  =CGRectMake(0, 64, ScreenWid, 80);
    
    textlab.numberOfLines = 0;
    
    
     [self.view addSubview:textlab];
    
    textlab.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPre:)];
    
    
    [textlab addGestureRecognizer:longPress];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
    
       [textlab addGestureRecognizer:tap];
    
    
    if ([_titlestr isEqualToString:NSLocalizedString(@"Scan result", @"Scan result")] &&  [_qrString rangeOfString:@"@"].location !=NSNotFound) {
        
         [self greatsheet];
        
    }
    
   
    
    
    
    // Do any additional setup after loading the view.
}


-(void)tap{
    
    if ([_titlestr isEqualToString:NSLocalizedString(@"Scan result", @"Scan result")]){
        
                [self greatsheet];
    }
      
    
    
}

-(void)greatsheet{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:_qrString delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Add a Contact", @"Add a Contact"),NSLocalizedString(@"Add friends", @"Add friends"),nil];
    
    
    actionSheet.tag = 7153;
    
    [actionSheet showInView:self.navigationController.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return ;
    }

    NSLog(@"buttonIndex=====%d",buttonIndex);
    
    if (buttonIndex ==0) {
        
        NSLog(@"Add a Contact");
        
        
        AddorEditViewController *ctr = [[AddorEditViewController alloc] init];
        ctr.modalPresentationStyle = UIModalPresentationFullScreen;
        ctr.recognizeID = 2444;
        ctr.numbPadenterString = _qrString;
        
        UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:ctr];
        navc.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:navc animated:YES completion:^{
            
        }];
        
    }
    
    else if (buttonIndex ==1){
        
          NSLog(@"add friend");
        
        
        
        AddorEditViewController *addOrEdit = [[AddorEditViewController alloc] init];
        addOrEdit.modalPresentationStyle = UIModalPresentationFullScreen;
        addOrEdit.numbPadenterString =_qrString;
        
 
        addOrEdit.recognizeID = 2689;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addOrEdit];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }


}

// 使label能够成为响应事件，为了能接收到事件（能成为第一响应者）
- (BOOL)canBecomeFirstResponder{
    return YES;
}
// 可以控制响应的方法
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(copy:));
}

//针对响应方法的实现，最主要的复制的两句代码
- (void)copy:(id)sender{
    
    //UIPasteboard：该类支持写入和读取数据，类似剪贴板
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string =textlab.text;
}



// 处理长按事件
- (void)longPre:(UILongPressGestureRecognizer *)recognizer{
    [self becomeFirstResponder]; // 用于UIMenuController显示，缺一不可
    
    //UIMenuController：可以通过这个类实现点击内容，或者长按内容时展示出复制等选择的项，每个选项都是一个UIMenuItem对象
//    UIMenuItem *copyLink = [[UIMenuItem alloc] initWithTitle:@"" action:@selector(copy:)];
//    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:copyLink, nil]];
    [[UIMenuController sharedMenuController] setTargetRect:textlab.frame inView:textlab.superview];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}


-(void)greatnavbar{
    
    
    UIView* navview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWid, 64)];
    BOOL isDark =false;
    if (@available(iOS 12.0, *)){
        isDark = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
    }
    
    UIColor* bkColor;
    if(isDark){
        bkColor = UIColor.darkGrayColor;
    }
    else{
        bkColor = [UIColor colorWithHexString:@"#f4f3f3"];
    }
    
    
    [navview setBackgroundColor:bkColor];
    
    [self.view addSubview:navview];
    
    UILabel * titlelab = [[UILabel alloc]init];
    
    titlelab.text = _titlestr;
    
    
    titlelab.font = [UIFont systemFontOfSize:19];
    
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
    

}






-(void)backaction{
    
    UIViewController *vc =  self;
    while (vc.presentingViewController) {
        vc = vc.presentingViewController;
    }
    [vc dismissViewControllerAnimated:YES completion:nil];
    
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

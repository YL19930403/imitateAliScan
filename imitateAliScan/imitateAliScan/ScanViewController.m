//
//  ScanViewController.m
//  imitateAliScan
//
//  Created by 余亮 on 16/2/24.
//  Copyright © 2016年 余亮. All rights reserved.
//

#import "ScanViewController.h"
#import "UIView+YLExtension.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MyCodeViewController.h"

static const CGFloat kBoardW = 100 ;
static const CGFloat kMargin = 30 ;

@interface ScanViewController ()<UIAlertViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>


@property(nonatomic,strong)AVCaptureSession * session ;
@property(nonatomic,weak) UIView * maskView ;
@property(nonatomic,strong)UIView * scanWindow ;
@property(nonatomic,strong)UIImageView * scanNetImageView ;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //这个属性必须打开否则返回的时候会出现黑边
    self.view.clipsToBounds = YES ;
    //1.遮罩
    [self setupMaskView];
    //2.下边栏
    [self setupBottomBar];
    //3. 提示文本
    [self setupTipTitleView];
    //4.顶部导航
    [self setupNavView];
    
    //5.扫描区域
    [self setupScanWindowView];
    
    //6.开始动画
    [self beginScanning];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES ;
    [self resumeAnimation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
}

- (void) setupMaskView
{
    UIView * mask = [[UIView alloc] init];
    _maskView = mask ;
    
    mask.layer.borderWidth = kBoardW ;
    mask.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7].CGColor;
    
    mask.bounds = CGRectMake(0, 0, self.view.width + kBoardW + kMargin, self.view.width + kBoardW + kMargin) ;
    mask.center = CGPointMake(self.view.width * 0.5, self.view.height*0.5) ;
    mask.y = 0 ;
    
    [self.view addSubview:mask];
}


- (void) setupBottomBar
{
    //下边栏
    UIView * bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height*0.9, self.view.width, self.view.height*0.1)];
    bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [self.view addSubview:bottomBar];
    
    //我的二维码
    UIButton * myCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    myCodeBtn.frame = CGRectMake(0, 0, self.view.height*0.1*35/49, self.view.height*0.1);
    myCodeBtn.center = CGPointMake(self.view.width/2, self.view.height*0.1/2) ;
    [myCodeBtn setImage:[UIImage imageNamed:@"qrcode_scan_btn_myqrcode_down"] forState:UIControlStateNormal];
    myCodeBtn.contentMode = UIViewContentModeScaleAspectFit ;
    [myCodeBtn addTarget:self action:@selector(myCodeClick) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) setupTipTitleView
{
    //1.补充遮罩
    UIView * mask = [[UIView alloc] initWithFrame:CGRectMake(0, _maskView.y+_maskView.height, self.view.width, kBoardW)];
    mask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    [self.view addSubview:mask];
    
    //2.操作提示
    
    UILabel * tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.height*0.9-kBoardW*2, self.view.bounds.size.width, kBoardW)];
    tipLabel.text = @"将取景框对准二维码，即可自动扫描";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter ;
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping ;
    tipLabel.numberOfLines = 2 ;
    tipLabel.font=[UIFont systemFontOfSize:12];
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tipLabel];

}

- (void) setupNavView
{
   //1.返回
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 30, 25, 25);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_titlebar_back_nor"] forState:UIControlStateNormal];
    backBtn.contentMode=UIViewContentModeScaleAspectFit;
    [backBtn addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    //2.相册
    UIButton * albumBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.frame = CGRectMake(0, 0, 35, 49);
    albumBtn.center=CGPointMake(self.view.width/2, 20+49/2.0);
    [albumBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_down"] forState:UIControlStateNormal];
    albumBtn.contentMode=UIViewContentModeScaleAspectFit;
    [albumBtn addTarget:self action:@selector(myAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumBtn];
    
    //3.闪光灯
    
    UIButton * flashBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    flashBtn.frame = CGRectMake(self.view.width-55,20, 35, 49);
    [flashBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_flash_down"] forState:UIControlStateNormal];
    flashBtn.contentMode=UIViewContentModeScaleAspectFit;
    [flashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];

    
    
}

- (void) disMiss
{
   [self.navigationController popViewControllerAnimated:YES];
}

- (void) myAlbum
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController * pickerVC = [[UIImagePickerController alloc] init];
        pickerVC.delegate = self ;
        /**
         UIImagePickerControllerSourceTypePhotoLibrary,相册
         UIImagePickerControllerSourceTypeCamera,相机
         UIImagePickerControllerSourceTypeSavedPhotosAlbum,照片库
         */
        pickerVC.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum ;
        
        //动画
        pickerVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal ;
        [self presentViewController:pickerVC animated:YES completion:nil];

    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


- (void) setupScanWindowView
{
    CGFloat scanWindowH = self.view.width - kMargin * 2;
    CGFloat scanWindowW = self.view.width - kMargin * 2;
    _scanWindow = [[UIView alloc] initWithFrame:CGRectMake(kMargin, kBoardW, scanWindowW, scanWindowH)];
    _scanWindow.clipsToBounds = YES ;
    [self.view addSubview:_scanWindow];
    
    _scanNetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_net"]];
    CGFloat buttonWH = 18 ;
    
    UIButton * topleft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWH, buttonWH)];
    [topleft setImage:[UIImage imageNamed:@"scan_1"] forState:UIControlStateNormal];
    [_scanWindow addSubview:topleft];
    
    UIButton *topRight = [[UIButton alloc] initWithFrame:CGRectMake(scanWindowW - buttonWH, 0, buttonWH, buttonWH)];
    [topRight setImage:[UIImage imageNamed:@"scan_2"] forState:UIControlStateNormal];
    [_scanWindow addSubview:topRight];
    
    UIButton *bottomLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, scanWindowH - buttonWH, buttonWH, buttonWH)];
    [bottomLeft setImage:[UIImage imageNamed:@"scan_3"] forState:UIControlStateNormal];
    [_scanWindow addSubview:bottomLeft];
    
    UIButton *bottomRight = [[UIButton alloc] initWithFrame:CGRectMake(topRight.x, bottomLeft.y, buttonWH, buttonWH)];
    [bottomRight setImage:[UIImage imageNamed:@"scan_4"] forState:UIControlStateNormal];
    [_scanWindow addSubview:bottomRight];

}

- (void) openFlash:(UIButton *)button
{
    button.selected = !button.selected ;
    if (button.selected) {
        [self turnTorchOn:YES];
    }else{
        [self turnTorchOn:NO];
    }
}


- (void) beginScanning
{
   //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];

    if(!input)  return ;
    // 创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];
    
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置有效扫描区域
    CGRect scanCrop = [self getScanCrop:_scanWindow.bounds readerViewBounds:self.view.frame];
    output.rectOfInterest = scanCrop ;
    
    //初始化链接对象
    _session = [[AVCaptureSession alloc] init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [_session addInput:input];
    [_session addOutput:output];
    
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [_session startRunning];

    
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:metadataObject.stringValue delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"再次扫描", nil];
        [alert show];
    }
}

#pragma mark-> 获取扫描区域的比例关系
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    
    return CGRectMake(x, y, width, height);
}

#pragma mark -  开关闪光灯
- (void) turnTorchOn:(BOOL) on
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]) {
            [device lockForConfiguration:nil];
            if (on ) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            }else{
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
    
}
         
#pragma mark  -  imagePickerController delegate
  //选择了某一张照片的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
     //1.获取选择的图片
    UIImage * img = info[UIImagePickerControllerOriginalImage];
    //2.初始化一个监测器
    
    CIDetector * detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    [picker dismissViewControllerAnimated:YES completion:^{
        //监测到的结果数组
        NSArray * features = [detector featuresInImage:[CIImage imageWithCGImage:img.CGImage]];
        if (features.count >= 1) {
            CIQRCodeFeature * feature = [features objectAtIndex:0  ];
            NSString * scanedResult = feature.messageString ;
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"saom结果" message:scanedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }else{
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
    
}

#pragma mark - 我的二维码
- (void) myCodeClick
{
    MyCodeViewController * MyCodeVC = [[MyCodeViewController alloc] initWithNibName:@"MyCodeViewController" bundle:nil];
    [self.navigationController pushViewController:MyCodeVC animated:YES];
    
}

#pragma mark - 恢复动画
- (void) resumeAnimation
{
    CAAnimation * anim = [_scanNetImageView.layer animationForKey:@"translationAnimation"];
    if (anim) {
        // 1. 将动画的时间偏移量作为暂停时的时间点
        CFTimeInterval pauseTime = _scanNetImageView.layer.timeOffset ;
        //2.根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
        CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime ;
        
        //3.要把偏移时间清零
        [_scanNetImageView.layer setTimeOffset:0.0];
        
        //4.设置图层的开始动画时间
        [_scanNetImageView.layer  setBeginTime:beginTime];
        
        [_scanNetImageView.layer setSpeed:1.0];
        
    }else{
        CGFloat scanNetImageViewH = 241 ;
        CGFloat scanWindowH =self.view.width - kMargin*2 ;
        CGFloat scanNetImageViewW = _scanWindow.width ;
        
        _scanNetImageView.frame = CGRectMake(0, -scanNetImageViewH, scanNetImageViewW , scanNetImageViewH) ;
        CABasicAnimation * scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(scanWindowH);
        scanNetAnimation.duration = 1.0 ;
        scanNetAnimation.repeatCount = MAXFLOAT ;
        
        [_scanNetImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
        [_scanWindow addSubview:_scanNetImageView];
        
    }
}


#pragma mark  - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self disMiss];
    } else if (buttonIndex == 1) {
        [_session startRunning];
    }
}

@end

























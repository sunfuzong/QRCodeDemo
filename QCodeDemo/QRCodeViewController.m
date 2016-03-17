//
//  QRCodeViewController.m
//  QCodeDemo
//
//  Created by sunfuzong on 16/3/17.
//  Copyright © 2016年 sunfuzong. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ZXingObjC/ZXingObjC/ZXingObjC.h>

#define kBorderW 50.

@interface QRCodeViewController ()<UIAlertViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *scanView;
@property (nonatomic, strong) UIImageView *scanImageView;

@end

@implementation QRCodeViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resumeAnimation];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat sw = [UIScreen mainScreen].bounds.size.width;
    CGFloat sh = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat kBorderH = (sh - (sw - 50*2))/2;
    self.maskView = [[UIView alloc] init];
    self.maskView.frame = CGRectMake(0, kBorderH, sw - 50*2, sw - 50*2);
    self.maskView.center = self.view.center;
    [self.view addSubview:self.maskView];
    
    [self creatView:CGRectMake(0, 0, sw, kBorderH)];
    [self creatView:CGRectMake(0, kBorderH, kBorderW, sh - kBorderH*2)];
    [self creatView:CGRectMake(sw - kBorderW, kBorderH, kBorderW, sh - kBorderH*2)];
    [self creatView:CGRectMake(0, sh - kBorderH, sw, kBorderH)];
    
    [self buildScanView];
    [self buildNavView];
    
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(0,self.maskView.frame.origin.y + self.maskView.frame.size.height + 20, sw, 50)];
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor blueColor];
    labIntroudction.text=@"将条码二维码放入框中就能自动扫描";
    [self.view addSubview:labIntroudction];
    
    [self beginScanning];
}

- (void)creatView:(CGRect)rect {
    CGFloat alpha = 0.6;
    UIColor *backColor = [UIColor grayColor];
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = backColor;
    view.alpha = alpha;
    [self.view addSubview:view];
}

- (void)buildScanView {
    self.scanView = [[UIView alloc] initWithFrame:self.maskView.frame];
    self.scanView.clipsToBounds = YES;
    [self.view addSubview:self.scanView];
    
    self.scanImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_net.png"]];
    
    CGFloat wi = 15.;
    UIImageView *topLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wi, wi)];
    [topLeft setImage:[UIImage imageNamed:@"scan_1"]];
    [self.scanView addSubview:topLeft];
    
    UIImageView *topRight = [[UIImageView alloc] initWithFrame:CGRectMake(self.scanView.frame.size.width - wi, 0, wi, wi)];
    [topRight setImage:[UIImage imageNamed:@"scan_2"]];
    [self.scanView addSubview:topRight];
    
    UIImageView *bottomLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.scanView.frame.size.height - wi, wi, wi)];
    [bottomLeft setImage:[UIImage imageNamed:@"scan_3"]];
    [self.scanView addSubview:bottomLeft];
    
    UIImageView *bottomRight = [[UIImageView alloc] initWithFrame:CGRectMake(topRight.frame.origin.x, bottomLeft.frame.origin.y, wi, wi)];
    [bottomRight setImage:[UIImage imageNamed:@"scan_4"]];
    [self.scanView addSubview:bottomRight];
}

-(void)buildNavView{
    //fanhui
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 30, 25, 25);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_titlebar_back_nor"] forState:UIControlStateNormal];
    backBtn.contentMode=UIViewContentModeScaleAspectFit;
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    //相册
    UIButton * albumBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    albumBtn.frame = CGRectMake(self.view.frame.size.width-55, 20, 35, 49);
    [albumBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_btn_photo_down"] forState:UIControlStateNormal];
    albumBtn.contentMode=UIViewContentModeScaleAspectFit;
    [albumBtn addTarget:self action:@selector(openPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumBtn];
}

- (void)back {
    [self.captureSession stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)beginScanning
{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) return;
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置有效扫描区域
    CGRect scanCrop=[self getScanCrop:self.scanView.bounds readerViewBounds:self.view.frame];
    output.rectOfInterest = scanCrop;
    //初始化链接对象
    self.captureSession = [[AVCaptureSession alloc]init];
    //高质量采集率
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.captureSession addInput:input];
    [self.captureSession addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,         //二维码
                                     AVMetadataObjectTypeCode39Code,     //条形码   韵达和申通
                                     AVMetadataObjectTypeCode128Code,    //CODE128条码  顺丰用的
                                     AVMetadataObjectTypeCode39Mod43Code,
                                     AVMetadataObjectTypeEAN13Code,
                                     AVMetadataObjectTypeEAN8Code,
                                     AVMetadataObjectTypeCode93Code,    //条形码,星号来表示起始符及终止符,如邮政EMS单上的条码
                                     AVMetadataObjectTypeUPCECode]];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [self.captureSession startRunning];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [self.captureSession stopRunning];
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

#pragma mark 恢复动画
- (void)resumeAnimation
{
    CAAnimation *anim = [self.scanImageView.layer animationForKey:@"translationAnimation"];
    if(anim){
        // 1. 将动画的时间偏移量作为暂停时的时间点
        CFTimeInterval pauseTime = self.scanImageView.layer.timeOffset;
        // 2. 根据媒体时间计算出准确的启动动画时间，对之前暂停动画的时间进行修正
        CFTimeInterval beginTime = CACurrentMediaTime() - pauseTime;
        
        // 3. 要把偏移时间清零
        [self.scanImageView.layer setTimeOffset:0.0];
        // 4. 设置图层的开始动画时间
        [self.scanImageView.layer setBeginTime:beginTime];
        
        [self.scanImageView.layer setSpeed:1.0];
        
    }else{
        
        CGFloat scanNetImageViewH = self.scanView.frame.size.height;
        CGFloat scanWindowH = self.scanView.frame.size.height;
        CGFloat scanNetImageViewW = self.scanView.frame.size.width;
        
        self.scanImageView.frame = CGRectMake(0, -scanNetImageViewH, scanNetImageViewW, scanNetImageViewH);
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(scanWindowH);
        scanNetAnimation.duration = 1.0;
        scanNetAnimation.repeatCount = MAXFLOAT;
        [self.scanImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
        [self.scanView addSubview:self.scanImageView];
    }
}

#pragma mark-> 我的相册
-(void)openPhoto:(UIButton *)sender{
    NSLog(@"我的相册");
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        //1.初始化相册拾取器
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        //2.设置代理
        controller.delegate = self;
        //3.设置资源：
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        //4.随便给他一个转场动画
        controller.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:controller animated:YES completion:NULL];
        
    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
#pragma mark-> imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //1.获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self getInfoWithImage:image];
    }];
    
    
    /*
    //2.初始化一个监测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        //监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >=1) {
            //结果对象
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
*/
}

#pragma mark 照片处理

-(void)getInfoWithImage:(UIImage *)img{
    
    UIImage *loadImage= img;
    CGImageRef imageToDecode = loadImage.CGImage;
    
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    
    if (result) {
        
        NSString *contents = result.text;
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:contents delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
    } else {
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:@"解析失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (buttonIndex == 1) {
        [self.captureSession startRunning];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

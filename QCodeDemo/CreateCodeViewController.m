//
//  CreateCodeViewController.m
//  QCodeDemo
//
//  Created by sunfuzong on 16/3/17.
//  Copyright © 2016年 sunfuzong. All rights reserved.
//

#import "CreateCodeViewController.h"

@interface CreateCodeViewController ()
@property (nonatomic, strong) UITextField *codeField;

@property (nonatomic, strong) UIImageView *codeImageView;
@end

@implementation CreateCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.codeField = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, self.view.frame.size.width - 40, 30)];
    [self.codeField setPlaceholder:@"请输入信息"];
    [self.view addSubview:self.codeField];
    
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(20, 30, 25, 25);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"qrcode_scan_titlebar_back_pressed.png"] forState:UIControlStateNormal];
    backBtn.contentMode=UIViewContentModeScaleAspectFit;
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    [but setFrame:CGRectMake(20, 120, 100, 40)];
    [but setTitle:@"CreateQR" forState:UIControlStateNormal];
    [but setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(createQR) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
    
    UIButton *but2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [but2 setFrame:CGRectMake(130, 120, self.view.frame.size.width - 130, 40)];
    [but2 setTitle:@"Create128BarcodeGenerator" forState:UIControlStateNormal];
    [but2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [but2 addTarget:self action:@selector(createBarcodeGenerator) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but2];
    
    self.codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 190, self.view.frame.size.width - 100, 200)];
    [self.codeImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:self.codeImageView];
    
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createQR {
    [self.view endEditing:YES];
    UIImage *image = [self buildQRCode:self.codeField.text withType:@"CIQRCodeGenerator"];
    [self.codeImageView setImage:image];
}
- (void)createBarcodeGenerator {
    [self.view endEditing:YES];
    UIImage *image = [self buildQRCode:self.codeField.text withType:@"CICode128BarcodeGenerator"];
    [self.codeImageView setImage:image];
}
- (UIImage *)buildQRCode:(NSString *)value withType:(NSString *)typeName{
    
    NSData *stringData = [value dataUsingEncoding: NSUTF8StringEncoding];
    
    //生成
//    CICode128BarcodeGenerator 条形码
//    CIQRCodeGenerator  二维码
    CIFilter *qrFilter = [CIFilter filterWithName:typeName];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    if ([typeName isEqualToString:@"CIQRCodeGenerator"]) {
        [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    }
    
    UIColor *onColor = [UIColor blackColor];
    UIColor *offColor = [UIColor clearColor];
    
    //上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",qrFilter.outputImage,
                             @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    
    //绘制
    CGSize size = CGSizeMake(300, 300);
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    return codeImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

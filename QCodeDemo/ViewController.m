//
//  ViewController.m
//  QCodeDemo
//
//  Created by sunfuzong on 16/3/17.
//  Copyright © 2016年 sunfuzong. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeViewController.h"
#import "CreateCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
    [but setFrame:CGRectMake(0, 0, 200, 50)];
    but.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
    [but setTitle:@"QRCode" forState:UIControlStateNormal];
    [but setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(goQRCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
    
    UIButton *but2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [but2 setFrame:CGRectMake(0, 0, 200, 50)];
    but2.center = CGPointMake(self.view.center.x, self.view.center.y + 30);;
    [but2 setTitle:@"CreateCode" forState:UIControlStateNormal];
    [but2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [but2 addTarget:self action:@selector(goCreateCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but2];
    
}
- (void)goQRCode {
    QRCodeViewController *vc = [[QRCodeViewController alloc] init];
    vc.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)goCreateCode {
    CreateCodeViewController *vc = [[CreateCodeViewController alloc] init];
    vc.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

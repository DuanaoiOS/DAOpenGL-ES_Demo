//
//  ViewController.m
//  OpenGL ES_Demo
//
//  Created by DuanaoiOS on 2017/10/25.
//  Copyright © 2017年 DATree. All rights reserved.
//

#import "ViewController.h"
#import "DAGLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupGLView];
}

- (void)setupGLView {
    DAGLView *glView = [[DAGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:glView];
}

@end

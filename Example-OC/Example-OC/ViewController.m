//
//  ViewController.m
//  Example-OC
//
//  Created by xaoxuu on 2018/6/30.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

#import "ViewController.h"
#import "Example_OC-Swift.h"
#import <WebKit/WebKit.h>

@interface ViewController ()

@property (strong, nonatomic) DebuggerWindow *debugger;

@property (strong, nonatomic) WKWebView *web;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(note:) name:@"web" object:nil];
    
    self.web = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.web.hidden = YES;
    [self.view addSubview:self.web];
    
    [self.web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://cn.bing.com"]]];
    
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.debugger = [[DebuggerWindow alloc] init];
    
}

- (void)note:(NSNotification *)note{
    NSNumber *ret = note.object;
    self.web.hidden = ret.boolValue;
}

@end

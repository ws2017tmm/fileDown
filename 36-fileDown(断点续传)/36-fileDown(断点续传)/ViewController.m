//
//  ViewController.m
//  36-fileDown(断点续传)
//
//  Created by XSUNT45 on 16/1/27.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UILabel *lable;

- (IBAction)clickStartBtn:(UIButton *)button;

@property (assign, nonatomic) long long currentLength;

@property (assign, nonatomic) long long totalLength;

@property (strong, nonatomic) NSURLConnection *connection;

@property (strong, nonatomic) NSFileHandle *handle;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.slider.userInteractionEnabled = NO;
    
}

- (IBAction)clickStartBtn:(UIButton *)button {
    button.selected = !button.selected;
    
    if (button.selected) {//开始下载
        //url
        NSURL *url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/2a/25677/QQ_V4.0.5.1446465388.dmg"];
//        NSURL *url = [NSURL URLWithString:@"http://imgsrc.baidu.com/forum/w%3D580/sign=7fc5b239b9a1cd1105b672288912c8b0/51b0f603738da977be0bd022b351f8198618e3b7.jpg"];
        
        //请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        //设置请求头
        NSString *currentProgress = [NSString stringWithFormat:@"bytes=%lld-",self.currentLength];
        [request setValue:currentProgress forHTTPHeaderField:@"Range"];
        
        //发送请求
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }else {//取消下载
        [self.connection cancel];
        self.connection = nil;
    }
}

#pragma mark - NSURLConnectionDataDelegate代理方法
//接受到服务器的响应时调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //如果下载过，但是没有完成，就不要在重新下载
    if (self.currentLength) return;
    
    //文件总大小
    self.totalLength = response.expectedContentLength;
    
    //文件的写入路径
    NSString *cachesPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"download"];
    
    //创建一个文件夹来存放下载的数据
    NSFileManager *mgr = [NSFileManager defaultManager];
    if (![mgr fileExistsAtPath:cachesPath]) {
        [mgr createDirectoryAtPath:cachesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //在沙盒中创建一个空的文件
    cachesPath = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
    [mgr createFileAtPath:cachesPath contents:nil attributes:nil];
    //创建文件句柄对象
    self.handle = [NSFileHandle fileHandleForWritingAtPath:cachesPath];
    
}

//接受到服务器的数据时调用
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    //移动到文件的最后面
    [self.handle seekToEndOfFile];
    
    //写文件
    [self.handle writeData:data];
    
    //当前下载好了的文件大小
    self.currentLength += data.length;
    
    //进度条当前的值
    self.slider.value = (double)self.currentLength / self.totalLength;
    
    self.lable.text = [NSString stringWithFormat:@"%.2f%%",self.slider.value*100];
    
}

//服务器的数据传输完毕时调研
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    self.totalLength = 0;
    self.currentLength = 0;
    
    //关闭文件
    [self.handle closeFile];
    self.handle = nil;
}

//文件下载失败调用
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"error = %@",error);
}

@end

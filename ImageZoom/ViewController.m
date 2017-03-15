//
//  ViewController.m
//  ImageZoom
//
//  Created by apple on 17/2/28.
//  Copyright © 2017年 KXX. All rights reserved.
//

#import "ViewController.h"



#define ScreenWW [UIScreen mainScreen].bounds.size.width
#define ScreenHH [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UIScrollViewDelegate>
{
    UIImageView * theImage;
    UIScrollView *  theScroll;
    CGFloat maxScale;
    CGFloat minScale;
}
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, assign) CGFloat currentScale;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.
    UIScrollView * scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, ScreenWW, ScreenHH);
    scrollView.delegate = self;
    scrollView.maximumZoomScale = 2.0;
    scrollView.minimumZoomScale = 0.7;
//    scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    

    CGFloat  currentImgScale = 1.0; //当前图片 缩放比例
    //2.img
    UIImage *img =  [UIImage imageNamed:@"bg2.jpg"];
    CGFloat imgW = img.size.width;
    CGFloat imgH = img.size.height ;
    CGFloat imgViewX = (ScreenWW - imgW*currentImgScale)/2.0;
    CGFloat imgViewY = (ScreenHH - imgH*currentImgScale)/2.0;
    UIImageView * imgView = [[UIImageView alloc] initWithImage:img];
    imgView.frame = CGRectMake(imgViewX, imgViewY, imgW, imgH);
    if (imgW > ScreenWW ) {
        CGFloat  scale = ScreenWW/imgW *0.9;
        
        imgView.frame = CGRectMake((ScreenWW - imgW*scale)/2.0, (ScreenHH - imgH*scale)/2, imgW*scale, imgH*scale);
    }
    if (imgH > ScreenHH) {
        CGFloat  scale = ScreenHH/imgH *0.9;
        imgView.frame = CGRectMake((ScreenWW - imgW*scale)/2.0, (ScreenHH - imgH*scale)/2, imgW*scale, imgH*scale);
    }
    
    imgView.userInteractionEnabled = YES;
    [scrollView addSubview:imgView];
    self.imageView = imgView;
   
    

    //3.双击手势
    UITapGestureRecognizer *doubelGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleGesture:)];
    doubelGesture.numberOfTapsRequired = 2;
    [imgView addGestureRecognizer:doubelGesture];
    
    
    //4.按钮
    UIButton * statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    statusBtn.frame = CGRectMake(0, 0, 30, 30);
    [statusBtn setTitle:@"度" forState:UIControlStateNormal];
    statusBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    statusBtn.layer.cornerRadius = 5;
    statusBtn.layer.borderColor = [UIColor grayColor].CGColor;
    statusBtn.layer.borderWidth = 1;
    [statusBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [statusBtn addTarget:self action:@selector(statusBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:statusBtn];
    
    
}
- (void)statusBtnClick
{
    [self saveImageToPhotos:self.imageView.image];
}
//实现该方法
- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    //因为需要知道该操作的完成情况，即保存成功与否，所以此处需要一个回调方法image:didFinishSavingWithError:contextInfo:
}
//回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [self showViewController:alert sender:nil];
}
#pragma mark -DoubleGesture Action
-(void)doubleGesture:(UIGestureRecognizer *)ges
{
    //1.获取手势的 的点击位置
    CGPoint location = [ges locationInView:self.imageView];
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        CGSize scrollViewSize = self.scrollView.bounds.size;
        CGFloat width = scrollViewSize.width / self.scrollView.maximumZoomScale;
        CGFloat height = scrollViewSize.height / self.scrollView.maximumZoomScale;
        CGFloat x = location.x - (width / 2.0f);
        CGFloat y = location.y - (height / 2.0f);
        CGRect rectToZoomTo = CGRectMake(x, y, width , height );
        [self.scrollView zoomToRect:rectToZoomTo animated:YES];
    }else if ((self.scrollView.zoomScale > self.scrollView.minimumZoomScale) && (self.scrollView.zoomScale <= self.scrollView.maximumZoomScale)){
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
}
#pragma mark -- UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return  self.imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    [UIView animateWithDuration:0.1 animations:^{
         _imageView.frame = [self centeredFrameForScrollView:scrollView andUIView:self.imageView];
    } completion:^(BOOL finished) {
        
    }];
   
}

#pragma mark --- 重置图片frame 使其居中
- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
    CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
   
   
    //1.水平 居中
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    
    //2.竖直居中
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }

    
    return frameToCenter;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

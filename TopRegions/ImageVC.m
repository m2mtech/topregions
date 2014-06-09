//
//  ImageVC.m
//  TopRegions
//
//  Created by Martin Mandl on 06.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "ImageVC.h"
#import "ImageCache.h"

@interface ImageVC () <UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ImageVC

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    _scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)fitImage:(UIImage *)image
{
    self.scrollView.zoomScale = 1.0;
    [self.imageView sizeToFit];
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self.spinner stopAnimating];
    [self setZoomScaleToFillScreen];
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    [self fitImage:image];
}

- (void)setZoomScaleToFillScreen
{
    double wScale = self.scrollView.bounds.size.width / self.imageView.image.size.width;
    double hScale = (self.scrollView.bounds.size.height
                     - self.navigationController.navigationBar.frame.size.height
                     - self.tabBarController.tabBar.frame.size.height
                     - MIN([UIApplication sharedApplication].statusBarFrame.size.height,
                           [UIApplication sharedApplication].statusBarFrame.size.width)
                     ) / self.imageView.image.size.height;
    if (wScale > hScale) self.scrollView.zoomScale = wScale;
    else self.scrollView.zoomScale = hScale;
}

- (void)fetchImage
{
    self.image = nil;
    if (!self.imageURL) return;
    
    [self.spinner startAnimating];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:self.imageURL
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    if (!error) {
                                                        if ([response.URL isEqual:self.imageURL]) {
                                                            NSData *imageData = [NSData dataWithContentsOfURL:location];
                                                            UIImage *image = [UIImage imageWithData:imageData];
                                                            [ImageCache cacheImageData:imageData forURL:self.imageURL];
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                self.image = image;
                                                            });
                                                        }
                                                    }
                                                }];
    [task resume];
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    
    UIImage *cachedImage = [ImageCache cachedImageForURL:_imageURL];
    if (cachedImage) {
        self.image = cachedImage;
    } else {
        [self fetchImage];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

- (void)viewDidLayoutSubviews
{
    if (self.imageView.image) [self fitImage:self.imageView.image];    
}

#pragma mark - scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

# pragma mark - split view controller delegate

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    UIViewController *master = aViewController;
    if ([master isKindOfClass:[UITabBarController class]]) {
        master = ((UITabBarController *)master).selectedViewController;
    }
    if ([master isKindOfClass:[UINavigationController class]]) {
        master = ((UINavigationController *)master).topViewController;
    }
    if (master) {
        barButtonItem.title = master.title;
    } else {
        barButtonItem.title = @"Top Places";
    }
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

@end

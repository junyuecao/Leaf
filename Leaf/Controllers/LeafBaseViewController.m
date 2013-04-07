//
//  LeafBaseViewController.m
//  Leaf
//
//  Created by roger on 13-4-7.
//  Copyright (c) 2013年 Mobimtech. All rights reserved.
//

#import "LeafBaseViewController.h"
#import "LeafHelper.h"

#define kScaleFactor 0.02f
#define kAlphaFactor 0.1f
#define kLeafEpisnon 0.5f

@interface LeafBaseViewController ()

@end

@implementation LeafBaseViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    UIView *container = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:container];
    _container = container;
    _container.backgroundColor = kLeafBackgroundColor;
    [container release];
    
    UIView *mask = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:mask];
    mask.alpha = 0.1f;
    mask.hidden = YES;
    _mask = mask;
    _mask.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
    [mask release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - KVO Stuff

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        UIView *contentView = (UIView *)object;
        CGFloat originX = contentView.frame.origin.x;
        CGFloat originY = contentView.frame.origin.y;
        
        CGFloat factor = 0;
        if (originX < kLeafEpisnon) {
            factor =  1 - originY/CGHeight(contentView.frame);
        }
        else if(originY < kLeafEpisnon){
            factor =  1 - originX/CGWidth(contentView.frame);
        }
       
        CGFloat scale = 1.0f - (kScaleFactor * factor);
        CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        _container.transform = transform;
        _mask.alpha = kAlphaFactor + factor;
    }
    else if([keyPath isEqualToString:@"hasMask"]){
        LeafBaseViewController *vc = (LeafBaseViewController *)object;
        _mask.hidden = !vc.hasMask;
    }
}

#pragma mark -
#pragma mark - Pan Gesture Stuff

- (void)enablePanGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        _panOriginX = self.view.frame.origin.x;
        _panVelocity = CGPointMake(0.0f, 0.0f);
        
        if([gesture velocityInView:self.view.superview].x > 0) {
            _panDirection = LeafPanDirectionRight;
        } else {
            _panDirection = LeafPanDirectionLeft;
        }
        
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint velocity = [gesture velocityInView:self.view.superview];
        if((velocity.x*_panVelocity.x + velocity.y*_panVelocity.y) < 0) {
            _panDirection = (_panDirection == LeafPanDirectionRight) ? LeafPanDirectionLeft : LeafPanDirectionRight;
        }
        
        _panVelocity = velocity;
        CGPoint translation = [gesture translationInView:self.view.superview];
        CGRect frame = self.view.frame;
        frame.origin.x = _panOriginX + translation.x;
        
        if(frame.origin.x > 0)
        {
            if (_state == LeafPanStateNone) {
                _state = LeafPanStateShowingLeft;
            }
            if (_state == LeafPanStateShowingLeft) {
                self.view.frame = frame;
            }
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        LeafPanCompletion  completion =  LeafPanCompletionNone;
        
        if (_state == LeafPanStateShowingLeft && _panDirection == LeafPanDirectionRight) {
            completion = LeafPanCompletionLeft;
        }
        else if(_state == LeafPanStateShowingLeft && _panDirection == LeafPanDirectionLeft)
        {
            completion = LeafPanCompletionNone;
        }
        
        if (completion == LeafPanCompletionLeft) {
            __block CGRect frame = self.view.frame;
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 frame.origin.x = CGWidth(self.view.frame);
                                 self.view.frame = frame;
                             }
                             completion:^(BOOL finished) {
                                 self.hasMask = NO;
                                 [self.view removeFromSuperview];
                                 [self release];
                             }];

        }
        else if(completion == LeafPanDirectionNone){
            if (self.view.frame.origin.x > 0) {
                __block CGRect frame = self.view.frame;
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     frame.origin.x = 0.0f;
                                     self.view.frame = frame;
                                 }
                                 completion:^(BOOL finished) {
                                     
                                 }];
            }
        }
    }
}



#pragma mark -
#pragma mark - ViewController Presentation

- (void)presentViewController:(LeafBaseViewController *)controller option:(LeafAnimationOption)option completion:(LeafBlock)block
{
    if (!controller) {
        NSLog(@"controller is nil.");
        return;
    }
    
    [controller.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [controller addObserver:self forKeyPath:@"hasMask" options:NSKeyValueObservingOptionNew context:NULL];
    if (option == LeafAnimationOptionHorizontal) {
        CGRect rect = controller.view.frame;
        rect.origin.x = CGWidth(self.view.bounds);
        controller.view.frame = rect;
        [self.view addSubview:controller.view];
        controller.hasMask = YES;
        
        __block CGRect frame = controller.view.frame;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             frame.origin.x = 0.0f;
                             controller.view.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             if (block) {
                                 block();
                             }
                         }];
    }
}

- (void)dismissViewControllerWithOption:(LeafAnimationOption)option completion:(LeafBlock)block
{
    __block CGRect frame = self.view.frame;
    
    if (option == LeafAnimationOptionHorizontal) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             frame.origin.x = CGWidth(self.view.frame);
                             self.view.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             if (block) {
                                block(); 
                             }
                             self.hasMask = NO;
                             [self.view removeFromSuperview];
                             [self release];
                         }];
    }
}

@end

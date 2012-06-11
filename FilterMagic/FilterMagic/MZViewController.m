//
//  MZViewController.m
//  FilterMagic
//
//  Created by Mason Glaves on 5/18/12.
//  Copyright (c) 2012 Masonsoft. All rights reserved.
//

#import "MZViewController.h"
#import "GPUImage.h"

@interface MZViewController ()

@end

@implementation MZViewController {
    IBOutlet UIImageView* imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    imageView.image = [UIImage imageNamed:@"grid.png"];
    
    [self touchesMoved:touches withEvent:event];
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    __block UIImage* image = [UIImage imageNamed:@"grid.png"];
    
    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch* touch, BOOL *stop) {
        GPUImageBulgeDistortionFilter *bump = [[GPUImageBulgeDistortionFilter alloc] init];
        CGPoint hit = [touch locationInView:imageView];    
        CGPoint center = CGPointMake(hit.x / imageView.frame.size.width, hit.y / imageView.frame.size.height);        
        [bump setCenter:center];
        [bump setScale:-0.2f];
        [bump setRadius:0.15f];
        image = [bump imageByFilteringImage:image];    
    }];
    
    imageView.image = image;    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end

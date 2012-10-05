//
//  LLViewController.m
//  CasuaLlama
//
//  Created by Mason on 8/19/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import "LLViewController.h"
#import "LLTableViewCell.h"
#import "LLPDFView.h"

@interface LLViewController ()

@property (nonatomic, strong) NSArray* data;
@property (nonatomic, weak) IBOutlet UITableView* table;
@property (nonatomic, weak) IBOutlet UIWebView* web;
@property (nonatomic, weak) IBOutlet LLPDFView* pdf;

@property (nonatomic, strong) NSArray* pageData;
@property (nonatomic, strong) NSMutableArray* pages;
@property (nonatomic, strong) UIPageViewController* book;

@end

@implementation LLViewController

LL_INIT_VIEW_CONTROLLER

- (void) setup {
    self.app = [LLAppDelegate instance];
    CGRect frame = self.app.window.frame;
    frame.origin.y = 0;
    self.app.window.frame = frame;

    [self configure];
}
- (void) configure {}

- (NSArray*) autoload:(NSString*)type {
    id data = nil;
    
    NSString* ident = [self ident];
    if (ident && ident.length) {
        NSURL* documents = self.app.documents;
        
        NSString* file = [ident stringByAppendingPathExtension:type];        
        NSURL* path = [documents URLByAppendingPathComponent:file];        
        data = [NSArray arrayWithContentsOfURL:path];
        if (!data) {
            data = [NSArray arrayWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:file withExtension:@"plist"]];
            [data writeToURL:path atomically:YES];
        }
    }
    return data;
}

- (void) configureViews:(UIInterfaceOrientation)orientation {
    CGSize size = self.view.bounds.size;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        size.width /= 2.0f;
    }

    self.web.scrollView.scrollEnabled = NO;
    self.web.scrollView.contentSize = size;

    self.pdf.scrollEnabled = NO;
    self.pdf.contentSize = size;
}

- (UIViewController*) page:(int)page {
    return [self.pages objectAtIndex:page];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.web.delegate = self;
    
    self.data = [self autoload:@"data"];
            
    if (self.data && self.table.dataSource == nil) {
        self.table.dataSource = self;
    }
    
    if (self.table.delegate == nil) {
        self.table.delegate = self;
    }
    
    self.pageData = [self autoload:@"pages"];
    
    if (self.pageData.count) {
        self.pages = [NSMutableArray arrayWithCapacity:self.pageData.count];

        BOOL landscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
        
        self.book = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                  options:@{UIPageViewControllerOptionSpineLocationKey : landscape ? @(UIPageViewControllerSpineLocationMid) : @(UIPageViewControllerSpineLocationMin) }];
        self.book.dataSource = self;
        self.book.delegate = self;
        self.book.doubleSided = YES;
        [self addChildViewController:self.book];
        self.book.view.frame = self.view.bounds;
        [self.view addSubview:self.book.view];
        [self.book didMoveToParentViewController:self];
        self.view.gestureRecognizers = self.book.gestureRecognizers;
        [self reloadPages:self.interfaceOrientation];
    }
}

- (void) loadContent:(NSString*)content ofType:(NSString*)type {
    if ([@"pdf" isEqualToString:type]) {
        NSArray* split = [content componentsSeparatedByString:@"|"];
        NSString* pdf = [split objectAtIndex:0];
        NSURL* url;
        if ([pdf hasSuffix:@"pdf"]) {
            url = [NSURL URLWithString:pdf];
        } else {
            url = [[NSBundle bundleForClass:[self class]] URLForResource:pdf withExtension:@"pdf"];
        }
        
        NSUInteger page = split.count > 1 ? [[split lastObject] intValue] : 0;
        [self.pdf loadPDF:url atPage:page];
        [self.view bringSubviewToFront:self.pdf];
    } else if ([@"url" isEqualToString:type]) {
        [self.web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:content]]];
        [self.view bringSubviewToFront:self.web];
    } else {
        [self.web loadHTMLString:content baseURL:nil];
        [self.view bringSubviewToFront:self.web];
    }
}

- (UIViewController*) blank:(UIColor*)color {
    LLViewController* blank = [[LLViewController alloc] init];
    blank.view.backgroundColor = color;
    return blank;
}

- (void) reloadPages:(UIInterfaceOrientation)orientation {
    BOOL blanks = UIInterfaceOrientationIsPortrait(orientation);    
    int index = self.book.viewControllers.count ? [self.pages indexOfObject:[self.book.viewControllers objectAtIndex:0]] : 0;
    if (index == NSNotFound) {
        index = 0;
    }
    if (index % 2 == 1) {
        index--;
    }
    if (self.pages.count > self.pageData.count && !blanks) {
        index *= 0.5f;
    } else if (self.pages.count == self.pageData.count && blanks) {
        index *= 2.0f;
    }
    
    [self.pages removeAllObjects];
    [self.pageData enumerateObjectsUsingBlock:^(NSDictionary* def, NSUInteger idx, BOOL *stop) {
        NSString* view = [def objectForKey:@"view"];
        if (!view) {
            view = @"page";
        }
        LLViewController* page = [self.storyboard instantiateViewControllerWithIdentifier:view];
        [page loadView];
        [page configureViews:orientation];
        [page loadContent:[def objectForKey:@"content"] ofType:[def objectForKey:@"type"]];
        [self.pages addObject:page];
        if (blanks) {
            //xxx transparent reverse page?
            [self.pages addObject:[self blank:UIColor.blueColor]];
        }
    }];
    
    if (index + 1 == self.pages.count) {
        index--;
    }
    
    [self.book setViewControllers:blanks ? @[[self page:index]] : @[[self page:index], [self page:index + 1]]
                        direction:UIPageViewControllerNavigationDirectionForward
                         animated:YES completion:nil];
}

- (NSString*) ident {
    NSString* ident = self.oid;
    
    if (ident == nil) {
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"^LL(.*)ViewController$" options:0 error:NULL];
        NSString* className = NSStringFromClass([self class]);
        NSTextCheckingResult* result = [regex firstMatchInString:className options:0 range:NSMakeRange(0, [className length])];
        if (result && result.numberOfRanges > 1) {
            ident = [className substringWithRange:[result rangeAtIndex:1]];
        }        
    }
        
    return [ident lowercaseString];
}

- (NSArray*)      sections                         { return [self data]; }
- (NSDictionary*) section:(NSUInteger)section      { return [self.sections objectAtIndex:section]; }
- (NSString*)     sectionTitle:(NSUInteger)section { return [[self.sections objectAtIndex:section] objectForKey:@"title"]; }
- (NSArray*)      rows:(NSUInteger)section         { return [[self section:section] objectForKey:@"rows"]; }
- (NSDictionary*) row:(NSIndexPath*)index          { return [[self rows:index.section] objectAtIndex:index.row]; }

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView { return [self.sections count]; }

- (NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)index { return [self sectionTitle:index]; }
- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)index   { return [self rows:index].count;   }

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)index {
    NSDictionary* row = [self row:index];
    
    NSString* reuse = [row objectForKey:@"type"];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    if (cell == nil) {
        NSString* name = [row objectForKey:@"class"];
        Class class = name ? name : [LLTableViewCell class];
        cell = [[class alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
    }
    
    [cell setValuesForKeysWithDictionary:row];
            
    return cell;
}

- (UIPageViewControllerSpineLocation) pageViewController:(UIPageViewController*)book spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
        
    [self reloadPages:orientation];
        
    return landscape ? UIPageViewControllerSpineLocationMid : UIPageViewControllerSpineLocationMin;
}

- (UIViewController*) pageViewController:(UIPageViewController*)book viewControllerBeforeViewController:(UIViewController*)page {
    int index = [self.pages indexOfObject:page];
    return index == 0 || index == NSNotFound ? nil : [self page:index - 1];
}

- (UIViewController*) pageViewController:(UIPageViewController*)book viewControllerAfterViewController:(UIViewController*)page {
    int index = [self.pages indexOfObject:page];
    return index == self.pages.count - 1 || index == NSNotFound ? nil : [self page:index + 1];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    id dest = segue.destinationViewController;
    if ([sender respondsToSelector:@selector(oid)] && [dest respondsToSelector:@selector(setOid:)]) {
        [dest setOid:[sender oid]];
    }
}

- (BOOL) webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked:
            [self.app open:request.URL];
            return NO;
            
        default:
            return YES;
    }
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError*)error {
    elog(error);
    [self.app alert:nil message:[error localizedDescription]];
}


- (IBAction) feedback {
    [TestFlight openFeedbackView];
}

- (void) sendFeedback:(NSString*)feedback {
    [TestFlight submitFeedback:feedback];
}

- (void) fade:(NSString*)to duration:(NSTimeInterval)duration {
    UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:to];
        
    [UIView transitionFromView:self.view toView:vc.view duration:duration options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        [self.app.nav setViewControllers:@[ vc ] animated:NO];
    }];
}


@end

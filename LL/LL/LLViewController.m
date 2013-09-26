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
#import "UIView+LL.h"
#import "NSObject+LL.h"
#import "NSString+LL.h"

@interface LLViewController ()

@property (nonatomic, strong) NSArray* tableData;
@property (nonatomic, weak) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSArray* pageData;
@property (nonatomic, strong) NSMutableArray* pages;
@property (nonatomic, strong) UIPageViewController* bookView;

@property (nonatomic, weak) IBOutlet UIWebView* webView;
@property (nonatomic, weak) IBOutlet LLPDFView* pdfView;

@end

@implementation LLViewController {
    UIImageView* background;
}

LL_INIT_VIEW_CONTROLLER

- (void) setup {
    self.app = [LLAppDelegate instance];
    CGRect frame = self.app.window.frame;
    frame.origin.y = 0;
    self.app.window.frame = frame;

    background = [[UIImageView alloc] init];
    background.frame = self.view.frame;  

    [self configure];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    background.frame = self.view.frame;    
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

    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.contentSize = size;

    self.pdfView.scrollEnabled = NO;
    self.pdfView.contentSize = size;
}

- (UIViewController*) page:(int)page {
    return [self.pages objectAtIndex:page];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.webView.delegate = self;
    
    self.tableData = [self autoload:@"data"]; //xxx autoload shoulld now load json
            
    if (self.tableData && self.tableView.dataSource == nil) {
        self.tableView.dataSource = self;
    }
    
    if (self.tableView.delegate == nil) {
        self.tableView.delegate = self;
    }
    
    self.pageData = [self autoload:@"pages"];
    
    if (self.pageData.count) {
        self.pages = [NSMutableArray arrayWithCapacity:self.pageData.count];

        BOOL landscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
        
        self.bookView = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                                                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                  options:@{UIPageViewControllerOptionSpineLocationKey : landscape ? @(UIPageViewControllerSpineLocationMid) : @(UIPageViewControllerSpineLocationMin) }];
        self.bookView.dataSource = self;
        self.bookView.delegate = self;
        self.bookView.doubleSided = YES;
        [self addChildViewController:self.bookView];
        self.bookView.view.frame = self.view.bounds;
        [self.view addSubview:self.bookView.view];
        [self.bookView didMoveToParentViewController:self];
        self.view.gestureRecognizers = self.bookView.gestureRecognizers;
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
        [self.pdfView loadPDF:url atPage:page];
        [self.view bringSubviewToFront:self.pdfView];
    } else if ([@"url" isEqualToString:type]) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:content]]];
        [self.view bringSubviewToFront:self.webView];
    } else {
        [self.webView loadHTMLString:content baseURL:nil];
        [self.view bringSubviewToFront:self.webView];
    }
}

- (UIViewController*) blank:(UIColor*)color {
    LLViewController* blank = [[LLViewController alloc] init];
    blank.view.backgroundColor = color;
    return blank;
}

- (void) reloadPages:(UIInterfaceOrientation)orientation {
    BOOL blanks = UIInterfaceOrientationIsPortrait(orientation);    
    int index = self.bookView.viewControllers.count ? [self.pages indexOfObject:[self.bookView.viewControllers objectAtIndex:0]] : 0;
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
    
    [self.bookView setViewControllers:blanks ? @[[self page:index]] : @[[self page:index], [self page:index + 1]]
                        direction:UIPageViewControllerNavigationDirectionForward
                         animated:YES completion:nil];
}

- (NSString*) ident {
    NSString* ident = self.LLID;
    
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

- (NSArray*)      sections                         { return [self tableData]; }
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

//xxx
- (void) setBackground:(id)bg {
    if ([bg isKindOfClass:UIImage.class]) {
        background.image = bg;
        [self.view insertSubview:background atIndex:0];
    } else if ([bg isKindOfClass:UIColor.class]) {
        self.view.backgroundColor = bg;
    } else if (bg) {
        self.background = [bg str].obj;
    } else {
        self.view.backgroundColor = UIColor.clearColor;
        [background removeFromSuperview];
    }
}

- (void) setNav:(id)val {
    if ([val isKindOfClass:NSDictionary.class]) {
        NSDictionary* nav = (NSDictionary*)val;
        
        NSString* bg = [nav valueForPath:@[@"background", @"bg"]];
        id bgobj = [bg obj];
        if ([bgobj isKindOfClass:UIColor.class]) {
            [self.app.nav.navigationBar setBackgroundColor:bgobj];
        } else if ([bgobj isKindOfClass:UIImage.class]) {
            [self.app.nav.navigationBar setBackgroundImage:bgobj forBarMetrics:UIBarMetricsDefault];
        }
        
        NSString* tint = [nav valueForPath:@"tint"];
        if (tint) {
            [self.app.nav.navigationBar setBackgroundColor:[tint obj]];
        }
        
        NSArray* items = [nav valueForPath:@"items"];
        [items enumerateObjectsUsingBlock:^(NSDictionary* item, NSUInteger idx, BOOL *stop) {
            NSString* position = [item valueForPath:@"position"];
            NSString* image = [item valueForPath:@"image"];
            id actions = [item valueForPath:@[@"action", @"actions"]];
            //xxx should add some kind of action hash?
            if ([actions isKindOfClass:NSArray.class]) {
                //add
            } else {
                //set
            }
                          
            //xxx set nav item
        }];
    } else {
        [self.app.nav setNavigationBarHidden:[val str].boolValue]; //xxx animated?
    }
}

- (void) setTable:(NSDictionary*)data {
// xxx?
//    "table"   : { "view"     : "name or default (or missing)",
//        "sections" : [{ "title" : "string or null/false (or missing)", "rows"  : [objs]}]},
/* sections: [
 { "title"  : "Public Projects",
 "rows"   : {
 "source" : "#{projects.public}",
 "cell"   : "dark cell"
 },
 "action" : {
 "type" : "push",
 "view" : "people"
 }
 }]
 
 vs

 { "title"  : "Public Projects",
   "data"   : "#{projects.public}",
   "cell"   : "dark cell",
   "action" : {
     "type" : "push",
     "view" : "people"
   }
 
 */
}
- (void) setText:(NSString*)text {
//    "text"    : { "text" : "url to file or text" },
}
- (void) setImage:(NSString*)path {
//    "image"   : { "path" : "url or bundle name" },
}
- (void) setWeb:(NSString*)path {
//    "web"     : { "path" : "url or inline" },
}
- (void) setPDF:(NSString*)path {
//    "pdf"     : { "path" : "url or bundle name", "page" : "page number or missing" },
}
- (void) setBook:(NSString*)path {
// xxx?    "book"    : { "view" : "name or default (or missing)", "pages" : [objs] },
}
- (void) setGallery:(NSString*)path {
// xxx?    "gallery" : { "view" : "name or default (or missing)", "items" : [objs] }
}
- (void) setMap:(NSString*)path {
//    "map"     : { },
}






@end

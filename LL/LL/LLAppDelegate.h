//
//  LLAppDelegate.h
//  CasuaLlama
//
//  Created by Mason on 8/18/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

//TODO:
//nav
//set props
//set web
//set text
//map
//table
//gallery
//pages?
//special set prop for complex selectors
//flow
//networking
//transitions

/*
 data = {
 
 "text"    : { "text" : "url to file or text" },
 "image"   : { "path" : "url or bundle name" },
 "web"     : { "path" : "url or inline" },
 "pdf"     : { "path" : "url or bundle name", "page" : "page number or missing" },
 "map"     : { },
 
 "table"   : { "view"     : "name or default (or missing)",
 "sections" : [{ "title" : "string or null/false (or missing)", "rows"  : [objs]}]},
 
 "book"    : { "view" : "name or default (or missing)", "pages" : [objs] },
 "gallery" : { "view" : "name or default (or missing)", "items" : [objs] }
 
 }
 */


@interface LLAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

+ (LLAppDelegate*) instance;

- (NSString*) deviceID;

- (NSURL*) documents;

- (void) alert:(NSString*)action message:(NSString*)message;
- (void) raise:(NSError*)error;
- (void) open:(NSURL*)url;

- (UIStoryboard*) storyboard;
- (UIViewController*) root;
- (UINavigationController*) nav;
- (UIApplication*) application;

- (void) notify;

@property (nonatomic, strong) IBOutlet UIWindow* window;
@property (nonatomic, strong) NSUserDefaults* settings;

@end

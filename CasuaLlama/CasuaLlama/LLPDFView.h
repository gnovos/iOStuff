
@interface LLPDFView : UIScrollView <UIScrollViewDelegate>

- (void) loadPDF:(NSURL*)url atPage:(NSUInteger)page;

@property (nonatomic, assign) NSUInteger page;

@end

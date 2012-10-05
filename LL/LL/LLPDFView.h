
#import "LLView.h"

@interface LLPDFView : LLView

- (void) loadPDF:(NSURL*)url atPage:(NSUInteger)page;

@property (nonatomic, assign) NSUInteger page;

@end

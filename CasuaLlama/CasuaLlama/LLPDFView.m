#import "LLPDFView.h"

@interface LLPDFView ()
@end

@implementation LLPDFView {
    CGPDFDocumentRef pdf;
}

- (void)dealloc {
    CGPDFDocumentRelease(pdf);
}

LL_INIT_VIEW

- (void) setup {
    self.delegate = self;
}

- (void) loadPDF:(NSURL*)url atPage:(NSUInteger)page {
    pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    self.page = page;
}

- (void) setPage:(NSUInteger)number {
    _page = number;
    [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect {
    CGPDFPageRef pdfpage = CGPDFDocumentGetPage(pdf, self.page);
    
    CGRect size = CGPDFPageGetBoxRect(pdfpage, kCGPDFMediaBox);
    CGFloat scale = rect.size.width / size.size.width;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0); //xxx change color?
    CGContextFillRect(context, rect);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextScaleCTM(context, scale, scale);
    CGContextDrawPDFPage(context, pdfpage);
    CGContextRestoreGState(context);    
}



@end

//
//  LLWaveformView.h
//  Plightnin
//
//  Created by Mason on 10/3/12.
//  Copyright (c) 2012 CasuaLlama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LLWaveformView : UIImageView
    
- (id) initWithUrl:(NSURL*)url;
- (NSData *) renderPNGAudioPictogramLogForAssett:(AVURLAsset *)songAsset;

@end

/**
 * iosaudiorecorder
 *
 * Created by Robert Fromont
 * Copyright (c) 2016 NZILBB.
 */

#import "NzilbbIosaudiorecorderModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import <AVFoundation/AVFoundation.h>

@interface NzilbbIosaudiorecorderModule ()

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation NzilbbIosaudiorecorderModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"c83581fb-f9b4-4a23-b768-2a2be52ec10a";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"nzilbb.iosaudiorecorder";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs


// args: int audioSource (ignored), int sampleRateInHz, int numberOfChannels, int audioFormat (ignored)
-(void)start:(NSArray *)args
{
    NSLog(@"[INFO] iosaudiorecorder:start: %@ ", args);
    NSLog(@"[INFO] iosaudiorecorder:start 1: %@ ", [args objectAtIndex:1]);
    NSLog(@"[INFO] iosaudiorecorder:start 2: %@ ", [args objectAtIndex:2]);
    NSInteger sampleRateInHz = [TiUtils intValue:[args objectAtIndex:1]];
    NSInteger numberOfChannels = [TiUtils intValue:[args objectAtIndex:2]];
    NSLog(@"[INFO] iosaudiorecorder:start: got args");
    NSLog(@"[INFO] iosaudiorecorder:start: %d Hz", sampleRateInHz);
    NSLog(@"[INFO] iosaudiorecorder:start: %d channels", numberOfChannels);
    
    NSDictionary *recordingSettings = @{AVFormatIDKey : @(kAudioFormatLinearPCM),
                                        AVNumberOfChannelsKey : @(numberOfChannels),
                                        AVSampleRateKey : @(sampleRateInHz),
                                        AVLinearPCMBitDepthKey : @(16),
                                        AVLinearPCMIsBigEndianKey : @NO,
                                        //AVLinearPCMIsNonInterleaved : @YES,
                                        AVLinearPCMIsFloatKey : @NO,
                                        AVEncoderAudioQualityKey : @(AVAudioQualityMax)
                                        };
    
    // TODO a new temprary file should be used for each recording
    //NSString *fileName = [NSString stringWithFormat:@"%@.wav", [[NSProcessInfo processInfo] globallyUniqueString]];
    //NSLog(@"[INFO] iosaudiorecorder:temp file name: %@", fileName);
    //_filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    _filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"rec.wav"];
    NSLog(@"[INFO] iosaudiorecorder:temp file path: %@", _filePath);
    NSLog(@"[INFO] iosaudiorecorder:temp file path: %d", _filePath);
    NSURL *soundFileURL = [NSURL fileURLWithPath:_filePath];
    NSLog(@"[INFO] iosaudiorecorder:URL: %@", soundFileURL);
    
    if (_audioRecorder != nil)
    {
        if (_audioRecorder.recording)
        {
            [_audioRecorder stop];
        }
        [_audioRecorder dealloc];
    }
    
    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    
    _audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:soundFileURL
                      settings:recordingSettings
                      error:&error];
    
    if (error)
    {
        NSLog(@"[INFO] iosaudiorecorder: error: %@", [error localizedDescription]);
    } else {
        [_audioRecorder prepareToRecord];
        [_audioRecorder record];
        NSLog(@"[INFO] iosaudiorecorder:Recording...");
    }
}

-(id)getRecording:(id)args
{
    NSLog(@"[INFO] iosaudiorecorder:getRecording");
    return NUMBOOL(_audioRecorder.recording);
}

-(id)stop:(id)args
{
    NSLog(@"[INFO] iosaudiorecorder:stopping");
    [_audioRecorder stop];
    _filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"rec.wav"];
    NSLog(@"[INFO] iosaudiorecorder:stopped: %@", _filePath);
    // TODO return unique path generated above
    //return _filePath;
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"rec.wav"];
}

@end

#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>

static const NSInteger VideoWidth = 1920;
static const NSInteger VideoHeight = 1080;
static const int32_t FramesPerSecond = 24;

static void Die(NSString *message) {
    fprintf(stderr, "%s\n", message.UTF8String);
    exit(1);
}

static NSColor *HexColor(uint32_t hex, CGFloat alpha) {
    return [NSColor colorWithCalibratedRed:((hex >> 16) & 0xff) / 255.0
                                     green:((hex >> 8) & 0xff) / 255.0
                                      blue:(hex & 0xff) / 255.0
                                     alpha:alpha];
}

static NSRect AspectFillRect(CGSize imageSize, NSRect rect) {
    CGFloat scale = MAX(rect.size.width / imageSize.width, rect.size.height / imageSize.height);
    CGFloat drawWidth = imageSize.width * scale;
    CGFloat drawHeight = imageSize.height * scale;
    return NSMakeRect(NSMidX(rect) - drawWidth / 2.0, NSMidY(rect) - drawHeight / 2.0, drawWidth, drawHeight);
}

static CGSize PixelSizeForImage(NSImage *image) {
    CGImageRef cgImage = [image CGImageForProposedRect:NULL context:nil hints:nil];
    if (!cgImage) {
        return image.size;
    }
    return CGSizeMake(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));
}

static void DrawText(NSString *text, NSRect rect, CGFloat size, NSString *fontName, NSColor *color, CGFloat lineSpacing) {
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = lineSpacing;
    paragraph.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{
        NSFontAttributeName: [NSFont fontWithName:fontName size:size] ?: [NSFont systemFontOfSize:size],
        NSForegroundColorAttributeName: color,
        NSParagraphStyleAttributeName: paragraph
    };
    [text drawInRect:rect withAttributes:attributes];
}

static void FillRoundedRect(NSRect rect, CGFloat radius, NSColor *color) {
    [color setFill];
    [[NSBezierPath bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius] fill];
}

static NSRect TopRect(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    return NSMakeRect(x, VideoHeight - y - height, width, height);
}

static void StrokeRoundedRect(NSRect rect, CGFloat radius, NSColor *color, CGFloat lineWidth) {
    [color setStroke];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius];
    path.lineWidth = lineWidth;
    [path stroke];
}

static NSArray<NSDictionary *> *Scenes(void) {
    return @[
        @{
            @"screenshot": @"docs/screenshots/00-pakfit-screen-contact-sheet.png",
            @"title": @"PakFit",
            @"subtitle": @"Pakistani health, fitness, workout, and nutrition coach",
            @"bullets": @[@"Desi meal planning", @"Daily calories, burn, and history", @"Android and iOS release gates"],
            @"weight": @1.0
        },
        @{
            @"screenshot": @"docs/screenshots/01-home-profile-plan.png",
            @"title": @"Personalized Plan",
            @"subtitle": @"Built around real Pakistani routines",
            @"bullets": @[@"Age, weight, goal, routine, diet, equipment", @"Roti, rice, daal, sabzi, chai, Ramadan, budget meals", @"Workout guidance for home, gym, and office schedules"],
            @"weight": @1.25
        },
        @{
            @"screenshot": @"docs/screenshots/06-food-logging-records.png",
            @"title": @"Daily Food Tracker",
            @"subtitle": @"Meal-by-meal and hourly calorie tracking",
            @"bullets": @[@"Pakistani foods, desserts, drinks, and custom recipes", @"Intake, burn, net calories, and newest-first history", @"Manual food item and category support"],
            @"weight": @1.25
        },
        @{
            @"screenshot": @"docs/screenshots/02-health-markers-bmi-reports.png",
            @"title": @"Health Markers",
            @"subtitle": @"Educational trends, not diagnosis",
            @"bullets": @[@"BMI, cholesterol, uric acid, blood sugar, HbA1c", @"Hemoglobin, diabetes status, and blood pressure", @"Clear clinician-review boundaries"],
            @"weight": @1.25
        },
        @{
            @"screenshot": @"docs/screenshots/03-clinical-intelligence.png",
            @"title": @"Clinical Safety Flows",
            @"subtitle": @"Cautious guidance for higher-risk users",
            @"bullets": @[@"Pregnancy, kidney, blood pressure, diabetes medication", @"PCOS, anemia, vitamin D, and cardiovascular risk", @"Plan adjustments stay conservative and review focused"],
            @"weight": @1.20
        },
        @{
            @"screenshot": @"docs/screenshots/04-mental-wellness-crisis.png",
            @"title": @"Mental Wellness",
            @"subtitle": @"Screening support with crisis boundaries",
            @"bullets": @[@"PHQ-9 and GAD-7 style wellness tracking", @"Pakistan-aware support messaging", @"No diagnosis, no prescription, strong safety language"],
            @"weight": @1.0
        },
        @{
            @"screenshot": @"docs/screenshots/05-analysis-dashboard.png",
            @"title": @"Analysis Dashboard",
            @"subtitle": @"Records become progress and action",
            @"bullets": @[@"Charts, bars, progress, trends, todos", @"Daily, weekly, and monthly summaries", @"History that helps users understand what changed"],
            @"weight": @1.25
        },
        @{
            @"screenshot": @"docs/screenshots/00-pakfit-screen-contact-sheet.png",
            @"title": @"Production-Ready Direction",
            @"subtitle": @"Local-first, privacy-aware, and release-gated",
            @"bullets": @[@"Automated Android and iOS checks", @"Clinical copy review ready", @"Device QA and store distribution ready"],
            @"weight": @0.85
        }
    ];
}

static void DrawFrame(CGContextRef cgContext, NSDictionary *scene, NSImage *image, double progress) {
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:cgContext flipped:NO];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:graphicsContext];

    [HexColor(0x071412, 1.0) setFill];
    NSRectFill(NSMakeRect(0, 0, VideoWidth, VideoHeight));

    [image drawInRect:AspectFillRect(PixelSizeForImage(image), NSMakeRect(0, 0, VideoWidth, VideoHeight))
             fromRect:NSZeroRect
            operation:NSCompositingOperationSourceOver
             fraction:0.16];

    [HexColor(0x123D32, 0.75) setFill];
    NSRectFill(NSMakeRect(0, 0, 520 + progress * 160, VideoHeight));
    [HexColor(0x173C48, 0.52) setFill];
    NSRectFill(NSMakeRect(VideoWidth - 620, 0, 620, VideoHeight));

    FillRoundedRect(TopRect(110, 78, 320, 46), 18, HexColor(0x20A66A, 1.0));
    DrawText(@"PakFit demo", TopRect(134, 86, 260, 30), 24, @"Helvetica-Bold", HexColor(0xffffff, 1.0), 3);

    DrawText(scene[@"title"], TopRect(110, 176, 790, 96), 66, @"Helvetica-Bold", HexColor(0xffffff, 1.0), 4);
    DrawText(scene[@"subtitle"], TopRect(114, 286, 790, 90), 31, @"Helvetica", HexColor(0xDDF7EA, 1.0), 6);

    CGFloat bulletY = 430;
    for (NSString *bullet in scene[@"bullets"]) {
        [HexColor(0xF4B24D, 1.0) setFill];
        [[NSBezierPath bezierPathWithOvalInRect:TopRect(126, bulletY + 12, 16, 16)] fill];
        DrawText(bullet, TopRect(166, bulletY, 760, 78), 30, @"Helvetica", HexColor(0xD7E5DE, 1.0), 8);
        bulletY += 108;
    }

    NSRect phoneOuter = TopRect(1112, 70, 476, 940);
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = NSMakeSize(0, -18);
    shadow.shadowBlurRadius = 38;
    shadow.shadowColor = HexColor(0x000000, 0.42);
    [NSGraphicsContext saveGraphicsState];
    [shadow set];
    FillRoundedRect(phoneOuter, 50, HexColor(0x08100E, 1.0));
    [NSGraphicsContext restoreGraphicsState];

    NSRect screenRect = NSInsetRect(phoneOuter, 24, 28);
    [NSGraphicsContext saveGraphicsState];
    [[NSBezierPath bezierPathWithRoundedRect:screenRect xRadius:34 yRadius:34] addClip];
    [image drawInRect:AspectFillRect(PixelSizeForImage(image), screenRect)
             fromRect:NSZeroRect
            operation:NSCompositingOperationSourceOver
             fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    StrokeRoundedRect(screenRect, 34, HexColor(0xE7FFF2, 0.32), 2);

    NSRect track = TopRect(110, 980, 790, 10);
    FillRoundedRect(track, 5, HexColor(0xffffff, 0.16));
    FillRoundedRect(NSMakeRect(track.origin.x, track.origin.y, track.size.width * progress, track.size.height), 5, HexColor(0x20A66A, 1.0));

    [NSGraphicsContext restoreGraphicsState];
}

static CVPixelBufferRef CreatePixelBuffer(CVPixelBufferPoolRef pool, NSDictionary *scene, NSImage *image, double progress) {
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferPoolCreatePixelBuffer(NULL, pool, &pixelBuffer);
    if (!pixelBuffer) {
        Die(@"Could not create pixel buffer");
    }

    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress,
                                                 VideoWidth,
                                                 VideoHeight,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    if (!context) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        CVPixelBufferRelease(pixelBuffer);
        Die(@"Could not create drawing context");
    }

    DrawFrame(context, scene, image, progress);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return pixelBuffer;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSURL *rootURL = [NSURL fileURLWithPath:[[NSFileManager defaultManager] currentDirectoryPath]];
        NSURL *outputDir = argc > 1
            ? [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]]]
            : [rootURL URLByAppendingPathComponent:@"outputs/PakFit"];
        [[NSFileManager defaultManager] createDirectoryAtURL:outputDir withIntermediateDirectories:YES attributes:nil error:nil];

        NSURL *m4aURL = [outputDir URLByAppendingPathComponent:@"PakFit-v0.52.0-customer-demo-voiceover.m4a"];
        NSURL *aiffURL = [outputDir URLByAppendingPathComponent:@"PakFit-v0.52.0-customer-demo-voiceover.aiff"];
        NSURL *audioURL = [[NSFileManager defaultManager] fileExistsAtPath:aiffURL.path] ? aiffURL : m4aURL;
        if (![[NSFileManager defaultManager] fileExistsAtPath:audioURL.path]) {
            Die([NSString stringWithFormat:@"Missing voiceover audio: %@", audioURL.path]);
        }

        NSURL *videoOnlyURL = [outputDir URLByAppendingPathComponent:@"PakFit-v0.52.0-customer-demo-videoonly.mp4"];
        NSURL *finalURL = [outputDir URLByAppendingPathComponent:@"PakFit-v0.52.0-customer-demo.mp4"];
        [[NSFileManager defaultManager] removeItemAtURL:videoOnlyURL error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:finalURL error:nil];

        NSArray<NSDictionary *> *scenes = Scenes();
        NSMutableArray<NSImage *> *images = [NSMutableArray array];
        for (NSDictionary *scene in scenes) {
            NSURL *imageURL = [rootURL URLByAppendingPathComponent:scene[@"screenshot"]];
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
            if (!image) {
                Die([NSString stringWithFormat:@"Could not load image: %@", imageURL.path]);
            }
            [images addObject:image];
        }

        AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:audioURL options:nil];
        double audioSeconds = MAX(CMTimeGetSeconds(audioAsset.duration), 30.0);
        double totalSeconds = audioSeconds + 1.2;
        double totalWeight = 0.0;
        for (NSDictionary *scene in scenes) {
            totalWeight += [scene[@"weight"] doubleValue];
        }

        NSMutableArray<NSDictionary *> *ranges = [NSMutableArray array];
        double cursor = 0.0;
        for (NSDictionary *scene in scenes) {
            double duration = totalSeconds * [scene[@"weight"] doubleValue] / totalWeight;
            [ranges addObject:@{@"start": @(cursor), @"end": @(cursor + duration)}];
            cursor += duration;
        }
        NSMutableDictionary *lastRange = [[ranges lastObject] mutableCopy];
        lastRange[@"end"] = @(totalSeconds);
        ranges[ranges.count - 1] = lastRange;

        NSError *error = nil;
        AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:videoOnlyURL fileType:AVFileTypeMPEG4 error:&error];
        if (!writer) {
            Die([NSString stringWithFormat:@"Could not create writer: %@", error.localizedDescription]);
        }

        NSDictionary *videoSettings = @{
            AVVideoCodecKey: AVVideoCodecTypeH264,
            AVVideoWidthKey: @(VideoWidth),
            AVVideoHeightKey: @(VideoHeight),
            AVVideoCompressionPropertiesKey: @{
                AVVideoAverageBitRateKey: @5000000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            }
        };
        AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        input.expectsMediaDataInRealTime = NO;

        NSDictionary *attributes = @{
            (NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB),
            (NSString *)kCVPixelBufferWidthKey: @(VideoWidth),
            (NSString *)kCVPixelBufferHeightKey: @(VideoHeight)
        };
        AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:input sourcePixelBufferAttributes:attributes];
        if (![writer canAddInput:input]) {
            Die(@"Could not add writer input");
        }
        [writer addInput:input];

        if (![writer startWriting]) {
            Die([NSString stringWithFormat:@"Could not start writer: %@", writer.error.localizedDescription]);
        }
        [writer startSessionAtSourceTime:kCMTimeZero];

        NSInteger totalFrames = (NSInteger)ceil(totalSeconds * FramesPerSecond);
        for (NSInteger frame = 0; frame < totalFrames; frame++) {
            @autoreleasepool {
                double second = (double)frame / FramesPerSecond;
                NSInteger sceneIndex = ranges.count - 1;
                for (NSInteger index = 0; index < (NSInteger)ranges.count; index++) {
                    if (second >= [ranges[index][@"start"] doubleValue] && second < [ranges[index][@"end"] doubleValue]) {
                        sceneIndex = index;
                        break;
                    }
                }
                double progress = MIN(1.0, second / MAX(totalSeconds, 1.0));
                while (!input.readyForMoreMediaData) {
                    [NSThread sleepForTimeInterval:0.005];
                }
                CVPixelBufferRef buffer = CreatePixelBuffer(adaptor.pixelBufferPool, scenes[sceneIndex], images[sceneIndex], progress);
                CMTime presentationTime = CMTimeMake(frame, FramesPerSecond);
                if (![adaptor appendPixelBuffer:buffer withPresentationTime:presentationTime]) {
                    CVPixelBufferRelease(buffer);
                    Die([NSString stringWithFormat:@"Could not append frame %ld: %@", (long)frame, writer.error.localizedDescription]);
                }
                CVPixelBufferRelease(buffer);
            }
        }

        [input markAsFinished];
        dispatch_semaphore_t writerSemaphore = dispatch_semaphore_create(0);
        [writer finishWritingWithCompletionHandler:^{
            dispatch_semaphore_signal(writerSemaphore);
        }];
        dispatch_semaphore_wait(writerSemaphore, DISPATCH_TIME_FOREVER);
        if (writer.status != AVAssetWriterStatusCompleted) {
            Die([NSString stringWithFormat:@"Video writer failed: %@", writer.error.localizedDescription]);
        }

        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoOnlyURL options:nil];
        AVMutableComposition *composition = [AVMutableComposition composition];
        AVAssetTrack *sourceVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        if (!sourceVideoTrack || !videoTrack) {
            Die(@"Could not prepare video composition");
        }
        if (![videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:sourceVideoTrack atTime:kCMTimeZero error:&error]) {
            Die([NSString stringWithFormat:@"Could not insert video: %@", error.localizedDescription]);
        }

        AVAssetTrack *sourceAudioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        if (sourceAudioTrack && audioTrack) {
            CMTime audioDuration = CMTimeMinimum(audioAsset.duration, videoAsset.duration);
            if (![audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioDuration) ofTrack:sourceAudioTrack atTime:kCMTimeZero error:&error]) {
                Die([NSString stringWithFormat:@"Could not insert audio: %@", error.localizedDescription]);
            }
        }

        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
        if (!exporter) {
            Die(@"Could not create exporter");
        }
        exporter.outputURL = finalURL;
        exporter.outputFileType = AVFileTypeMPEG4;
        exporter.shouldOptimizeForNetworkUse = YES;

        dispatch_semaphore_t exportSemaphore = dispatch_semaphore_create(0);
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_semaphore_signal(exportSemaphore);
        }];
        dispatch_semaphore_wait(exportSemaphore, DISPATCH_TIME_FOREVER);
        if (exporter.status != AVAssetExportSessionStatusCompleted) {
            Die([NSString stringWithFormat:@"Export failed: %@", exporter.error.localizedDescription]);
        }

        printf("%s\n", finalURL.path.UTF8String);
    }
    return 0;
}

//
//  PPStickerDataManager.m
//  PPStickerKeyboard
//
//  Created by Vernon on 2018/1/17.
//  Copyright © 2018年 Vernon. All rights reserved.
//

#import "PPStickerDataManager.h"
#import "PPSticker.h"
#import "PPUtil.h"

@interface PPStickerMatchingResult : NSObject
@property (nonatomic, assign) NSRange range;                    // 匹配到的表情包文本的range
@property (nonatomic, strong) UIImage *emojiImage;              // 如果能在本地找到emoji的图片，则此值不为空
@property (nonatomic, strong) NSString *showingDescription;     // 表情的实际文本(形如：[哈哈])，不为空
@end

@implementation PPStickerMatchingResult
@end

@interface PPStickerDataManager ()
@property (nonatomic, strong, readwrite) NSArray<PPSticker *> *allStickers;
@end

@implementation PPStickerDataManager

+ (instancetype)sharedInstance
{
    static PPStickerDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PPStickerDataManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initStickers];
    }
    return self;
}

- (NSString *)emojiDecode:(unsigned int)codePoint{
    
    //unsigned int codePoint = 128522;///*…*/;
    unichar characters[2];
    NSUInteger numCharacters = 0;
    if (CFStringGetSurrogatePairForLongCharacter(codePoint, characters)) {
        numCharacters = 2;
    } else {
        characters[0] = codePoint;
        numCharacters = 1;
    }
    return [[NSString alloc]initWithCharacters:characters length:numCharacters];
}

- (void)initStickers
{
    NSString *path = [NSBundle.mainBundle pathForResource:@"InnerStickersInfo" ofType:@"plist"];
    if (!path) {
        return;
    }

    NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
    NSMutableArray<PPSticker *> *stickers = [[NSMutableArray alloc] init];
//    for (NSDictionary *stickerDict in array) {
    NSDictionary *stickerDict = array[1];
        PPSticker *sticker = [[PPSticker alloc] init];
        sticker.coverImageName = stickerDict[@"cover_pic"];
        Boolean type = [stickerDict[@"unicode_type"] boolValue];
        NSArray *emojiArr = stickerDict[@"emoticons"];
        NSMutableArray<PPEmoji *> *emojis = [[NSMutableArray alloc] init];
        for (NSDictionary *emojiDict in emojiArr) {
            PPEmoji *emoji = [[PPEmoji alloc] init];
            emoji.utf32Type = type;//是否UNIcode表情字符
            emoji.imageName = emojiDict[@"image"];
            emoji.emojiDescription = emojiDict[@"desc"];
//            if(type){//unicode表情字符，将表情编码转换为表情字符
//                emoji.emojiDescription = [self emojiDecode:[emoji.emojiDescription intValue]];
//            }
            [emojis addObject:emoji];
        }
        sticker.emojis = emojis;
        [stickers addObject:sticker];
//        break;
        //目前阶段，只处理第一个通用的UNICODE
        //后续的，自定义表情同步android处理
//    }
    self.allStickers = stickers;
}

#pragma mark - public method

- (void)replaceEmojiForAttributedString:(NSMutableAttributedString *)attributedString font:(UIFont *)font
{
    if (!attributedString || !attributedString.length || !font) {
        return;
    }

    NSArray<PPStickerMatchingResult *> *matchingResults = [self matchingEmojiForString:attributedString.string];

    if (matchingResults && matchingResults.count) {
        NSUInteger offset = 0;
        for (PPStickerMatchingResult *result in matchingResults) {
            if (result.emojiImage) {
                CGFloat emojiHeight = font.lineHeight;
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = result.emojiImage;
                
                emojiHeight = 22;
                
                attachment.bounds = CGRectMake(0, font.descender, emojiHeight, emojiHeight);
                
              //  NSLog(@"emojiHeight===%f",emojiHeight);
                
                
                NSMutableAttributedString *emojiAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                
                
                
                [emojiAttributedString pp_setTextBackedString:[PPTextBackedString stringWithString:result.showingDescription] range:NSMakeRange(0, emojiAttributedString.length)];
                if (!emojiAttributedString) {
                    continue;
                }
                NSRange actualRange = NSMakeRange(result.range.location - offset, result.showingDescription.length);
                [attributedString replaceCharactersInRange:actualRange withAttributedString:emojiAttributedString];
                offset += result.showingDescription.length - emojiAttributedString.length;
                
              //  NSLog(@"offset=========%f",offset);
            }
        }
    }
}
-(void)getAlterString:(NSMutableAttributedString*)attributedString font:(UIFont *)font{
    if (!attributedString || attributedString.length==0 || font==nil){
        return;
    }
    NSString *description= [self getDescString:attributedString.string];
    [attributedString replaceCharactersInRange:NSMakeRange(0, attributedString.length) withString:description];
    [self replaceEmojiForAttributedString:attributedString font:font];
}

-(NSString*)getDescString:(NSString*)content{
    int MaxLen = 28;
    NSUInteger len = MaxLen;
    if (!content || !content.length) {
        return content;
    }
    if(content.length>MaxLen){
        if(content.length>MaxLen*2){//截断，后面的没必要去判断，浪费资源。主要是判断maxlen这个位置是否是包含在表情字符串中间，所以maxlen*2以后的没必要去匹配，浪费资源
            content = [content substringToIndex:MaxLen*2];
        }
        NSArray<PPStickerMatchingResult *> *matchingResults = [self matchingEmojiForString:content];
        if (matchingResults && matchingResults.count) {
            for (PPStickerMatchingResult *result in matchingResults) {
                if(result.range.location <MaxLen&&(result.range.length+result.range.location)>MaxLen){
                    len = result.range.location;
                    break;
                }
            }
        }
        content = [content substringToIndex:len];
        [content stringByAppendingString:@"..."];
    }else{
    }
    return content;

}

#pragma mark - private method

- (NSArray<PPStickerMatchingResult *> *)matchingEmojiForString:(NSString *)string
{
    if (!string.length) {
        return nil;
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[:.+?\\]" options:0 error:NULL];
    NSArray<NSTextCheckingResult *> *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if (results && results.count) {
        NSMutableArray *emojiMatchingResults = [[NSMutableArray alloc] init];
        for (NSTextCheckingResult *result in results) {
            NSString *showingDescription = [string substringWithRange:result.range];
            NSString *emojiSubString = [showingDescription substringFromIndex:2];       // 去掉[
            emojiSubString = [emojiSubString substringWithRange:NSMakeRange(0, emojiSubString.length - 1)];    // 去掉]
            PPEmoji *emoji = [self emojiWithEmojiDescription:emojiSubString];
            if (emoji) {
                PPStickerMatchingResult *emojiMatchingResult = [[PPStickerMatchingResult alloc] init];
                emojiMatchingResult.range = result.range;
                emojiMatchingResult.showingDescription = showingDescription;
                emojiMatchingResult.emojiImage = [UIImage imageNamed:[@"Sticker.bundle" stringByAppendingPathComponent:emoji.imageName]];
                [emojiMatchingResults addObject:emojiMatchingResult];
            }
        }
        return emojiMatchingResults;
    }
    return nil;
}

- (PPEmoji *)emojiWithEmojiDescription:(NSString *)emojiDescription
{
    for (PPSticker *sticker in self.allStickers) {
        for (PPEmoji *emoji in sticker.emojis) {
            if ([emoji.emojiDescription isEqualToString:emojiDescription]) {
                return emoji;
            }
        }
    }
    return nil;
}

@end

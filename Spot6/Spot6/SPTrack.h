#import <Foundation/Foundation.h>

@interface SPTrack : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, copy) NSString *albumName;
@property (nonatomic, copy) NSString *spotifyURL;
@property (nonatomic, copy) NSString *previewURL;

@end

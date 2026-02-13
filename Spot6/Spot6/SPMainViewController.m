#import "SPMainViewController.h"

#import "SPSpotifyClient.h"
#import "SPTrack.h"
#import "SPWebFallbackViewController.h"
#import "SPYouTubeFallbackClient.h"

@interface SPMainViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) SPSpotifyClient *spotifyClient;
@property (nonatomic, strong) SPYouTubeFallbackClient *youTubeClient;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayerController;

@end

@implementation SPMainViewController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"Spot6";
        self.tracks = [NSArray array];
        self.spotifyClient = [[SPSpotifyClient alloc] init];
        self.youTubeClient = [[SPYouTubeFallbackClient alloc] init];
        self.spotifyClient.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"spotify_access_token"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.placeholder = @"Search Spotify tracks";
    self.searchBar.delegate = self;
    self.searchBar.barStyle = UIBarStyleBlack;
    [self.view addSubview:self.searchBar];

    CGFloat tableY = CGRectGetMaxY(self.searchBar.frame);
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableY, self.view.bounds.size.width, self.view.bounds.size.height - tableY - 44) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.06f green:0.06f blue:0.06f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithRed:0.16f green:0.16f blue:0.16f alpha:1.0f];
    [self.view addSubview:self.tableView];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tableView.frame), self.view.bounds.size.width, 44)];
    self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.statusLabel.textColor = [UIColor lightTextColor];
    self.statusLabel.backgroundColor = [UIColor colorWithRed:0.10f green:0.10f blue:0.10f alpha:1.0f];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:13.0f];
    self.statusLabel.text = @"Spotify search + YouTube fallback";
    [self.view addSubview:self.statusLabel];

    UIBarButtonItem *tokenButton = [[UIBarButtonItem alloc] initWithTitle:@"Token"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(promptForToken)];
    self.navigationItem.rightBarButtonItem = tokenButton;
}

- (void)promptForToken
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Spotify Access Token"
                                                    message:@"Paste a Spotify Web API bearer token. Leave empty for unauthenticated mode."
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Save", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text = self.spotifyClient.accessToken;

    [alert show];

    __weak SPMainViewController *weakSelf = self;
    [alert setCompletionBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSString *token = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            weakSelf.spotifyClient.accessToken = token;
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"spotify_access_token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchForQuery:searchBar.text];
}

- (void)searchForQuery:(NSString *)query
{
    self.statusLabel.text = @"Searching Spotify…";

    __weak SPMainViewController *weakSelf = self;
    [self.spotifyClient searchTracksForQuery:query completion:^(NSArray *tracks, NSError *error) {
        if (error) {
            weakSelf.statusLabel.text = @"Spotify failed. Opening YouTube fallback…";
            [weakSelf presentYouTubeFallbackForQuery:query];
            return;
        }

        if (tracks.count == 0) {
            weakSelf.statusLabel.text = @"No Spotify tracks. Opening YouTube fallback…";
            [weakSelf presentYouTubeFallbackForQuery:query];
            return;
        }

        weakSelf.tracks = tracks;
        [weakSelf.tableView reloadData];
        weakSelf.statusLabel.text = [NSString stringWithFormat:@"%lu tracks from Spotify", (unsigned long)tracks.count];
    }];
}

- (void)presentYouTubeFallbackForQuery:(NSString *)query
{
    NSURL *url = [self.youTubeClient searchURLForTrackQuery:query];
    SPWebFallbackViewController *webVC = [[SPWebFallbackViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tracks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"TrackCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    SPTrack *track = [self.tracks objectAtIndex:indexPath.row];
    cell.textLabel.text = track.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ • %@", track.artistName ? track.artistName : @"Unknown artist", track.albumName ? track.albumName : @"Unknown album"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SPTrack *track = [self.tracks objectAtIndex:indexPath.row];
    if (track.previewURL.length > 0) {
        self.moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:track.previewURL]];
        [self presentMoviePlayerViewControllerAnimated:self.moviePlayerController];
        self.statusLabel.text = [NSString stringWithFormat:@"Playing preview: %@", track.name];
        return;
    }

    if (track.spotifyURL.length > 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:track.spotifyURL]];
        self.statusLabel.text = @"Opened track in Spotify";
        return;
    }

    self.statusLabel.text = @"No preview. Opening YouTube fallback…";
    [self presentYouTubeFallbackForQuery:[NSString stringWithFormat:@"%@ %@", track.name, track.artistName]];
}

@end

@interface UIAlertView (SPBlocks)

- (void)setCompletionBlock:(void (^)(NSInteger buttonIndex))completionBlock;

@end

#import <objc/runtime.h>

static char SPAlertCompletionKey;

@implementation UIAlertView (SPBlocks)

- (void)setCompletionBlock:(void (^)(NSInteger buttonIndex))completionBlock
{
    objc_setAssociatedObject(self, &SPAlertCompletionKey, completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.delegate = (id<UIAlertViewDelegate>)self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    void (^completionBlock)(NSInteger buttonIndex) = objc_getAssociatedObject(self, &SPAlertCompletionKey);
    if (completionBlock) {
        completionBlock(buttonIndex);
    }
}

@end

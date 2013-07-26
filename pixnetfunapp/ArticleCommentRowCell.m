//
//  ArticleCommentRowCell.m
//  pixnetfunapp
//
//  Created by Chiou Green on 13/7/25.
//  Copyright (c) 2013年 greenchiu. All rights reserved.
//

#import "ArticleCommentRowCell.h"
@interface ArticleCommentRowCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@end


@implementation ArticleCommentRowCell

- (void)dealloc {
    self.titleLabel = nil;
    self.timeLabel = nil;
    self.commentLabel = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 161, 21)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14.f];
        self.titleLabel.text = @"{title}";
        [self addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(189, 5, 115, 21)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.font = [UIFont systemFontOfSize:12.f];
        self.timeLabel.text = @"{time}";
        self.timeLabel.textAlignment = 1;
        [self addSubview:self.timeLabel];
        
        self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 26, 280, 21)];
        self.commentLabel.backgroundColor = [UIColor clearColor];
        self.commentLabel.font = [UIFont systemFontOfSize:16.f];
        self.commentLabel.text = @"{time}";
        self.commentLabel.numberOfLines = 0;
        [self addSubview:self.commentLabel];
        
    }
    return self;
}

- (void)loadData:(NSDictionary *)data {
    self.titleLabel.text = [NSString stringWithFormat:@"%@:", data[@"author"]];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[data[@"time"] integerValue]];
    self.timeLabel.text = [formatter stringFromDate:date];
    CGRect frame = self.commentLabel.frame;
    frame.size.height = [data[@"height"] floatValue];
    self.commentLabel.frame = frame;
    self.commentLabel.text = data[@"comment"];
}

@end

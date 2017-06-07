//
//  ChatTableViewCell.m
//  BmobDataDemo
//
//  Created by Bmob on 14-7-21.
//  Copyright (c) 2014年 bmob. All rights reserved.
//

#import "ChatTableViewCell.h"

@implementation ChatTableViewCell

@synthesize titleLabel   = _titleLabel;
@synthesize contentLabel = _contentLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}


-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel                 = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font            = [UIFont systemFontOfSize:13];
        _titleLabel.textColor       = RGB(136, 136, 136);
        _titleLabel.textAlignment   = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}


-(UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel                 = [[UILabel alloc] init];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font            = [UIFont systemFontOfSize:15];
        _contentLabel.textColor       = [UIColor blackColor];
        _contentLabel.textAlignment   = NSTextAlignmentLeft;
        _contentLabel.numberOfLines   = 0;
        [self.contentView addSubview:_contentLabel];
    }
    
    return _contentLabel;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.frame   = CGRectMake(20, 5, 280, 14);
    self.contentLabel.frame = CGRectMake(20, 20, 280, self.frame.size.height-20);
}

@end

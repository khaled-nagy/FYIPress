class Comment {
  final String id;
  final String name;
  final String createdAt;
  final String comment;
  final String mediaUrl;
  final String when;
  bool reported;
  final List<Comment> replies;

  Comment(
      {this.id,
      this.name,
      this.createdAt,
      this.comment,
      this.mediaUrl,
      this.when,
      this.replies,
      this.reported});

  factory Comment.fromMap(Map map) {
    List<Comment> replies;

    if (map['replies'] != null && map['replies'] != 0) {
      replies = [];
      map['replies'].forEach((k, v) {
        replies.add(Comment.fromMap(v));
      });
    }

    return Comment(
      id: map['comment_id'] ?? map['reply_id'] ?? '',
      name: map['name'] ?? '',
      comment: map['comment'] ?? map['reply'] ?? '',
      createdAt: map['time'] ?? '',
      mediaUrl: map['media'] ?? '',
      when: map['when'] ?? '',
      replies: replies,
      reported: map['user_reported_comment'] == 1,
    );
  }
}

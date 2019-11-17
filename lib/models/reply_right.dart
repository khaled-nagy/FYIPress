class ReplyRight {
  final String title;
  final String reply;
  final String id;
  final String time;
  final String name;
  final String userImage;
  final String replyImage;
  final String when;

  ReplyRight(
      {this.title,
      this.reply,
      this.id,
      this.time,
      this.name,
      this.userImage,
      this.replyImage,
      this.when});

  factory ReplyRight.fromMap(Map map) {
    return ReplyRight(
      title: map['reply_title'],
      reply: map['reply'],
      id: map['id'],
      time: map['time'],
      name: map['name'],
      userImage: map['user_image'],
      replyImage: map['reply_image'],
      when: map['when'],
    );
  }
}

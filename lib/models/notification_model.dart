class NotificationItem {
  final String data;
  final String? description;
  final int id;
  final String notify;

  NotificationItem({
    required this.data,
    this.description,
    required this.id,
    required this.notify
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      data: json['data'],
      description: json['description'],
      id: json['id'],
      notify: json['notify'],
    );
  }
}

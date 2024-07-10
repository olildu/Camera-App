class CommonFunctions{
  String calculateTimeAgo(String isoDateString) {
    DateTime dateTime = DateTime.parse(isoDateString);
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      int hours = difference.inHours;
      if (hours == 0) {
        int minutes = difference.inMinutes;
        return '$minutes minutes ago';
      } else {
        return '$hours hours ago';
      }
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
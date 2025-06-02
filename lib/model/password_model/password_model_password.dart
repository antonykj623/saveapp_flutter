class PasswordEntry {
  String title;
  String username;
  String password;
  String website;
  String remarks;

  PasswordEntry({
    required this.title,
    required this.username,
    this.password = '',
    this.website = '',
    this.remarks = '',
  });
}
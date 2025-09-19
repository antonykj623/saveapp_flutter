class Plan {
  final String name;         // Display name
  final String serverName;   // Name to send to server
  final String opcode;       // Short code
  final String spKey;        // Special key
  final String image;        // Image path or asset

  Plan({
    required this.name,
    required this.serverName,
    required this.opcode,
    required this.spKey,
    required this.image,
  });
}
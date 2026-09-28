enum SshAuthType { password, privateKey }

class Connection {
  String name;
  String uri;

  bool useSsh;
  String sshHost;
  int sshPort;
  String sshUsername;
  SshAuthType sshAuthType;
  String sshPassword;
  String sshPrivateKey;
  String sshPassphrase;

  Connection(
    this.name,
    this.uri, {
    this.useSsh = false,
    this.sshHost = '',
    this.sshPort = 22,
    this.sshUsername = '',
    this.sshAuthType = SshAuthType.password,
    this.sshPassword = '',
    this.sshPrivateKey = '',
    this.sshPassphrase = '',
  });

  Connection.fromJson(Map<String, dynamic> json)
      : name = json["name"] ?? '',
        uri = json["uri"] ?? '',
        useSsh = json["useSsh"] ?? false,
        sshHost = json["sshHost"] ?? '',
        sshPort = json["sshPort"] ?? 22,
        sshUsername = json["sshUsername"] ?? '',
        sshAuthType = json["sshAuthType"] == "privateKey"
            ? SshAuthType.privateKey
            : SshAuthType.password,
        sshPassword = json["sshPassword"] ?? '',
        sshPrivateKey = json["sshPrivateKey"] ?? '',
        sshPassphrase = json["sshPassphrase"] ?? '';

  Map<String, dynamic> toJson() => {
        'name': name,
        'uri': uri,
        'useSsh': useSsh,
        'sshHost': sshHost,
        'sshPort': sshPort,
        'sshUsername': sshUsername,
        'sshAuthType': sshAuthType.name,
        'sshPassword': sshPassword,
        'sshPrivateKey': sshPrivateKey,
        'sshPassphrase': sshPassphrase,
      };

  String getConnectionString() => uri;

  String getMaskedConnectionString() {
    final pattern = RegExp(r"(mongodb(?:\+srv)?://[^:]+:)([^@]+)(@)");
    return uri.replaceAllMapped(pattern, (match) {
      return "${match.group(1)}*****${match.group(3)}";
    });
  }
}

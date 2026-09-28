enum SshAuthType { password, privateKey }

class SshConfig {
  String host;
  int port;
  String username;
  SshAuthType authType;
  String password;
  String privateKey;
  String passphrase;

  SshConfig({
    this.host = '',
    this.port = 22,
    this.username = '',
    this.authType = SshAuthType.password,
    this.password = '',
    this.privateKey = '',
    this.passphrase = '',
  });

  factory SshConfig.fromJson(Map<String, dynamic> json) {
    return SshConfig(
      host: json["host"] ?? '',
      port: json["port"] ?? 22,
      username: json["username"] ?? '',
      authType: json["authType"] == "privateKey"
          ? SshAuthType.privateKey
          : SshAuthType.password,
      password: json["password"] ?? '',
      privateKey: json["privateKey"] ?? '',
      passphrase: json["passphrase"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'host': host,
        'port': port,
        'username': username,
        'authType': authType.name,
        'password': password,
        'privateKey': privateKey,
        'passphrase': passphrase,
      };
}

class Connection {
  String name;
  String uri;
  SshConfig? sshConfig;

  Connection(
    this.name,
    this.uri, {
    this.sshConfig,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      json["name"] ?? '',
      json["uri"] ?? '',
      sshConfig: json["sshConfig"] != null
          ? SshConfig.fromJson(Map<String, dynamic>.from(json["sshConfig"]))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'uri': uri,
        if (sshConfig != null) 'sshConfig': sshConfig!.toJson(),
      };

  String getConnectionString() => uri;

  String getMaskedConnectionString() {
    final pattern = RegExp(r"(mongodb(?:\+srv)?://[^:]+:)([^@]+)(@)");
    return uri.replaceAllMapped(pattern, (match) {
      return "${match.group(1)}*****${match.group(3)}";
    });
  }
}

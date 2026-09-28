enum SshAuthType { password, privateKey }

class SshConfig {
  bool enabled;
  String host;
  int port;
  String username;
  SshAuthType authType;
  String password;
  String privateKey;
  String passphrase;

  SshConfig({
    this.enabled = false,
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
      enabled: json["enabled"] ?? json["useSsh"] ?? false,
      host: json["host"] ?? json["sshHost"] ?? '',
      port: json["port"] ?? json["sshPort"] ?? 22,
      username: json["username"] ?? json["sshUsername"] ?? '',
      authType: (json["authType"] ?? json["sshAuthType"]) == "privateKey"
          ? SshAuthType.privateKey
          : SshAuthType.password,
      password: json["password"] ?? json["sshPassword"] ?? '',
      privateKey: json["privateKey"] ?? json["sshPrivateKey"] ?? '',
      passphrase: json["passphrase"] ?? json["sshPassphrase"] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
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
    SshConfig? sshCfg;
    if (json["sshConfig"] != null) {
      sshCfg = SshConfig.fromJson(Map<String, dynamic>.from(json["sshConfig"]));
    } else if (json["useSsh"] == true ||
        (json["sshHost"] != null && (json["sshHost"] as String).isNotEmpty)) {
      sshCfg = SshConfig.fromJson(json);
    }

    return Connection(
      json["name"] ?? '',
      json["uri"] ?? '',
      sshConfig: sshCfg,
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

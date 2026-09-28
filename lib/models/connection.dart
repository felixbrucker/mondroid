sealed class SshAuth {
  const SshAuth();

  factory SshAuth.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'privateKey') {
      return SshPrivateKeyAuth(
        privateKey: json['privateKey'] ?? '',
        passphrase: json['passphrase'] ?? '',
      );
    }
    return SshPasswordAuth(
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson();
}

class SshPasswordAuth extends SshAuth {
  final String password;

  const SshPasswordAuth({this.password = ''});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'password',
        'password': password,
      };
}

class SshPrivateKeyAuth extends SshAuth {
  final String privateKey;
  final String passphrase;

  const SshPrivateKeyAuth({
    this.privateKey = '',
    this.passphrase = '',
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'privateKey',
        'privateKey': privateKey,
        'passphrase': passphrase,
      };
}

class SshConfig {
  String host;
  int port;
  String username;
  SshAuth auth;

  SshConfig({
    this.host = '',
    this.port = 22,
    this.username = '',
    this.auth = const SshPasswordAuth(),
  });

  factory SshConfig.fromJson(Map<String, dynamic> json) {
    return SshConfig(
      host: json["host"] ?? '',
      port: json["port"] ?? 22,
      username: json["username"] ?? '',
      auth: SshAuth.fromJson(Map<String, dynamic>.from(json["auth"] ?? {})),
    );
  }

  Map<String, dynamic> toJson() => {
        'host': host,
        'port': port,
        'username': username,
        'auth': auth.toJson(),
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

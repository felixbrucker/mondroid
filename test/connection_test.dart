import 'package:flutter_test/flutter_test.dart';
import 'package:mondroid/models/connection.dart';

void main() {
  group('Connection model tests', () {
    test('Connection without SSH defaults', () {
      final conn = Connection('Test Mongo', 'mongodb://localhost:27017/db');

      expect(conn.name, 'Test Mongo');
      expect(conn.uri, 'mongodb://localhost:27017/db');
      expect(conn.sshConfig, null);
    });

    test('Connection with password SSH serialization and deserialization', () {
      final conn = Connection(
        'SSH Mongo Password',
        'mongodb://user:pass@127.0.0.1:27017/mydb',
        sshConfig: SshConfig(
          enabled: true,
          host: '192.168.1.100',
          port: 2222,
          username: 'sshuser',
          authType: SshAuthType.password,
          password: 'sshpassword',
        ),
      );

      final json = conn.toJson();
      expect(json['name'], 'SSH Mongo Password');
      expect(json['sshConfig'], isNotNull);
      expect(json['sshConfig']['enabled'], true);
      expect(json['sshConfig']['host'], '192.168.1.100');
      expect(json['sshConfig']['port'], 2222);
      expect(json['sshConfig']['username'], 'sshuser');
      expect(json['sshConfig']['authType'], 'password');
      expect(json['sshConfig']['password'], 'sshpassword');

      final deserialized = Connection.fromJson(json);
      expect(deserialized.name, 'SSH Mongo Password');
      expect(deserialized.sshConfig, isNotNull);
      expect(deserialized.sshConfig!.enabled, true);
      expect(deserialized.sshConfig!.host, '192.168.1.100');
      expect(deserialized.sshConfig!.port, 2222);
      expect(deserialized.sshConfig!.username, 'sshuser');
      expect(deserialized.sshConfig!.authType, SshAuthType.password);
      expect(deserialized.sshConfig!.password, 'sshpassword');
    });

    test('Connection with private key SSH serialization and deserialization', () {
      final conn = Connection(
        'SSH Mongo Key',
        'mongodb://127.0.0.1:27017/mydb',
        sshConfig: SshConfig(
          enabled: true,
          host: 'example.com',
          port: 22,
          username: 'root',
          authType: SshAuthType.privateKey,
          privateKey: '-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----',
          passphrase: 'keypassphrase',
        ),
      );

      final json = conn.toJson();
      expect(json['sshConfig']['authType'], 'privateKey');
      expect(json['sshConfig']['privateKey'], contains('BEGIN OPENSSH PRIVATE KEY'));
      expect(json['sshConfig']['passphrase'], 'keypassphrase');

      final deserialized = Connection.fromJson(json);
      expect(deserialized.sshConfig!.authType, SshAuthType.privateKey);
      expect(deserialized.sshConfig!.privateKey, contains('BEGIN OPENSSH PRIVATE KEY'));
      expect(deserialized.sshConfig!.passphrase, 'keypassphrase');
    });

    test('Backwards compatibility for JSON with flat SSH fields or no SSH fields', () {
      final oldFlatJson = {
        'name': 'Flat SSH Connection',
        'uri': 'mongodb://localhost:27017/test',
        'useSsh': true,
        'sshHost': '10.0.0.1',
        'sshPort': 22,
        'sshUsername': 'admin',
        'sshAuthType': 'password',
        'sshPassword': 'secretpassword',
      };

      final conn = Connection.fromJson(oldFlatJson);
      expect(conn.name, 'Flat SSH Connection');
      expect(conn.sshConfig, isNotNull);
      expect(conn.sshConfig!.enabled, true);
      expect(conn.sshConfig!.host, '10.0.0.1');
      expect(conn.sshConfig!.username, 'admin');

      final noSshJson = {
        'name': 'Old Connection',
        'uri': 'mongodb://localhost:27017/test',
      };
      final connNoSsh = Connection.fromJson(noSshJson);
      expect(connNoSsh.sshConfig, null);
    });

    test('Mask connection string password', () {
      final conn = Connection(
        'Test',
        'mongodb://dbuser:dbpass123@cluster.mongodb.net/test',
      );

      expect(conn.getMaskedConnectionString(),
          'mongodb://dbuser:*****@cluster.mongodb.net/test');
    });
  });
}

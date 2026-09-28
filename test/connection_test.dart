import 'package:flutter_test/flutter_test.dart';
import 'package:mondroid/models/connection.dart';

void main() {
  group('Connection model tests', () {
    test('Connection without SSH defaults', () {
      final conn = Connection('Test Mongo', 'mongodb://localhost:27017/db');

      expect(conn.name, 'Test Mongo');
      expect(conn.uri, 'mongodb://localhost:27017/db');
      expect(conn.useSsh, false);
      expect(conn.sshHost, '');
      expect(conn.sshPort, 22);
      expect(conn.sshUsername, '');
      expect(conn.sshAuthType, SshAuthType.password);
      expect(conn.sshPassword, '');
      expect(conn.sshPrivateKey, '');
      expect(conn.sshPassphrase, '');
    });

    test('Connection with password SSH serialization and deserialization', () {
      final conn = Connection(
        'SSH Mongo Password',
        'mongodb://user:pass@127.0.0.1:27017/mydb',
        useSsh: true,
        sshHost: '192.168.1.100',
        sshPort: 2222,
        sshUsername: 'sshuser',
        sshAuthType: SshAuthType.password,
        sshPassword: 'sshpassword',
      );

      final json = conn.toJson();
      expect(json['name'], 'SSH Mongo Password');
      expect(json['useSsh'], true);
      expect(json['sshHost'], '192.168.1.100');
      expect(json['sshPort'], 2222);
      expect(json['sshUsername'], 'sshuser');
      expect(json['sshAuthType'], 'password');
      expect(json['sshPassword'], 'sshpassword');

      final deserialized = Connection.fromJson(json);
      expect(deserialized.name, 'SSH Mongo Password');
      expect(deserialized.useSsh, true);
      expect(deserialized.sshHost, '192.168.1.100');
      expect(deserialized.sshPort, 2222);
      expect(deserialized.sshUsername, 'sshuser');
      expect(deserialized.sshAuthType, SshAuthType.password);
      expect(deserialized.sshPassword, 'sshpassword');
    });

    test('Connection with private key SSH serialization and deserialization', () {
      final conn = Connection(
        'SSH Mongo Key',
        'mongodb://127.0.0.1:27017/mydb',
        useSsh: true,
        sshHost: 'example.com',
        sshPort: 22,
        sshUsername: 'root',
        sshAuthType: SshAuthType.privateKey,
        sshPrivateKey: '-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----',
        sshPassphrase: 'keypassphrase',
      );

      final json = conn.toJson();
      expect(json['sshAuthType'], 'privateKey');
      expect(json['sshPrivateKey'], contains('BEGIN OPENSSH PRIVATE KEY'));
      expect(json['sshPassphrase'], 'keypassphrase');

      final deserialized = Connection.fromJson(json);
      expect(deserialized.sshAuthType, SshAuthType.privateKey);
      expect(deserialized.sshPrivateKey, contains('BEGIN OPENSSH PRIVATE KEY'));
      expect(deserialized.sshPassphrase, 'keypassphrase');
    });

    test('Backwards compatibility for JSON without SSH fields', () {
      final oldJson = {
        'name': 'Old Connection',
        'uri': 'mongodb://localhost:27017/test',
      };

      final conn = Connection.fromJson(oldJson);
      expect(conn.name, 'Old Connection');
      expect(conn.uri, 'mongodb://localhost:27017/test');
      expect(conn.useSsh, false);
      expect(conn.sshPort, 22);
      expect(conn.sshAuthType, SshAuthType.password);
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

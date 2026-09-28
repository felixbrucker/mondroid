import 'package:flutter/material.dart';

import '../services/settingsservice.dart';

import 'package:mondroid/models/connection.dart';

class ConnectionForm extends StatefulWidget {
  final bool isAdd;
  final TextEditingController nameController;
  final TextEditingController uriController;
  final bool useSsh;
  final TextEditingController sshHostController;
  final TextEditingController sshPortController;
  final TextEditingController sshUsernameController;
  final SshAuthType sshAuthType;
  final TextEditingController sshPasswordController;
  final TextEditingController sshPrivateKeyController;
  final TextEditingController sshPassphraseController;
  final ValueChanged<bool> onUseSshChanged;
  final ValueChanged<SshAuthType> onSshAuthTypeChanged;
  final VoidCallback onSubmit;
  final VoidCallback onHelp;

  const ConnectionForm({
    super.key,
    required this.isAdd,
    required this.nameController,
    required this.uriController,
    required this.useSsh,
    required this.sshHostController,
    required this.sshPortController,
    required this.sshUsernameController,
    required this.sshAuthType,
    required this.sshPasswordController,
    required this.sshPrivateKeyController,
    required this.sshPassphraseController,
    required this.onUseSshChanged,
    required this.onSshAuthTypeChanged,
    required this.onSubmit,
    required this.onHelp,
  });

  @override
  State<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<ConnectionForm> {
  late bool _useSsh;
  late SshAuthType _sshAuthType;

  @override
  void initState() {
    super.initState();
    _useSsh = widget.useSsh;
    _sshAuthType = widget.sshAuthType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                widget.isAdd ? 'Add Connection' : 'Edit Connection',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              onPressed: widget.onHelp,
              icon: const Icon(Icons.help_outline, size: 22),
              tooltip: 'Help',
            ),
          ],
        ),

        const SizedBox(height: 12),

        TextField(
          controller: widget.nameController,
          textInputAction: TextInputAction.next,
          smartQuotesType: SettingsService().smartQuotes
              ? SmartQuotesType.disabled
              : SmartQuotesType.enabled,
          smartDashesType: SettingsService().smartDashes
              ? SmartDashesType.disabled
              : SmartDashesType.enabled,
          decoration: const InputDecoration(
            hintText: "Name",
            helperText: 'Will be used as title.',
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: widget.uriController,
          textInputAction: TextInputAction.next,
          smartQuotesType: SettingsService().smartQuotes
              ? SmartQuotesType.disabled
              : SmartQuotesType.enabled,
          smartDashesType: SettingsService().smartDashes
              ? SmartDashesType.disabled
              : SmartDashesType.enabled,
          decoration: const InputDecoration(
            hintText: "Uri",
            helperText: 'Uri with database name.',
          ),
        ),

        const SizedBox(height: 12),

        SwitchListTile(
          title: const Text('SSH Tunnel'),
          subtitle: const Text('Connect via SSH host'),
          value: _useSsh,
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            setState(() {
              _useSsh = value;
            });
            widget.onUseSshChanged(value);
          },
        ),

        if (_useSsh) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: widget.sshHostController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: "SSH Host",
                    helperText: 'Host / IP',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: widget.sshPortController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: "Port",
                    helperText: '22',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.sshUsernameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: "SSH Username",
              helperText: 'SSH user name',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<SshAuthType>(
            initialValue: _sshAuthType,
            decoration: const InputDecoration(
              hintText: "Authentication Method",
              helperText: 'Select auth method',
            ),
            items: const [
              DropdownMenuItem(
                value: SshAuthType.password,
                child: Text('Password'),
              ),
              DropdownMenuItem(
                value: SshAuthType.privateKey,
                child: Text('Public Key'),
              ),
            ],
            onChanged: (SshAuthType? value) {
              if (value != null) {
                setState(() {
                  _sshAuthType = value;
                });
                widget.onSshAuthTypeChanged(value);
              }
            },
          ),
          const SizedBox(height: 12),
          if (_sshAuthType == SshAuthType.password) ...[
            TextField(
              controller: widget.sshPasswordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: "SSH Password",
                helperText: 'Password for SSH user',
              ),
            ),
          ] else ...[
            TextField(
              controller: widget.sshPrivateKeyController,
              maxLines: 4,
              textInputAction: TextInputAction.next,
              smartQuotesType: SmartQuotesType.disabled,
              smartDashesType: SmartDashesType.disabled,
              decoration: const InputDecoration(
                hintText: "Private Key (PEM format)",
                helperText: 'Paste OpenSSH or PEM private key',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: widget.sshPassphraseController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: "Passphrase (optional)",
                helperText: 'Key passphrase if encrypted',
              ),
            ),
          ],
        ],

        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: widget.onSubmit,
          child: Text(widget.isAdd ? 'Add' : 'Edit'),
        ),
      ],
    );
  }
}

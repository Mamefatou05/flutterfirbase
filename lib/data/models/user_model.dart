import 'enums.dart';

class AppUser {  // Renommé de User à AppUser
  final String id;
    final String nomComplet;
  final String numeroTelephone;
  final String email;
  final double balance;
  final Role role;
  final String? qrCodeUrl;


  AppUser({
    required this.id,
    required this.nomComplet,
    required this.numeroTelephone,
    required this.email,
    required this.balance,
    required this.role,
    String? qrCodeUrl,
  }) : qrCodeUrl = qrCodeUrl ?? numeroTelephone;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomComplet': nomComplet,
      'numeroTelephone': numeroTelephone,
      'email': email,
      'balance': balance,
      'role': role.toString().split('.').last,
      'qrCodeUrl': qrCodeUrl,

    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      nomComplet: json['nomComplet'],
      numeroTelephone: json['numeroTelephone'],
      email: json['email'],
      balance: json['balance'].toDouble(),
      role: Role.values.firstWhere(
            (e) => e.toString() == 'Role.${json['role']}',
      ),
      qrCodeUrl: json['qrCodeUrl'],

    );
  }
}

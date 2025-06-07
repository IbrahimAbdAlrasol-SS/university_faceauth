import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String universityId;
  final String name;
  final String email;
  final String? phone;
  final String? department;
  final String? college;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.universityId,
    required this.name,
    required this.email,
    this.phone,
    this.department,
    this.college,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      universityId: json['university_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      department: json['department']?.toString(),
      college: json['college']?.toString(),
      profileImage: json['profile_image']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university_id': universityId,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'college': college,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? universityId,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? college,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      universityId: universityId ?? this.universityId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      college: college ?? this.college,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        universityId,
        name,
        email,
        phone,
        department,
        college,
        profileImage,
        createdAt,
        updatedAt,
      ];

  // Helper getters
  String get displayName => name.isNotEmpty ? name : 'المستخدم';
  
  String get initials {
    if (name.isEmpty) return 'M';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name[0];
  }

  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get hasDepartment => department != null && department!.isNotEmpty;
  bool get hasCollege => college != null && college!.isNotEmpty;
  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;
}
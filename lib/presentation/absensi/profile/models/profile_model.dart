// File: lib/presentation/absensi/profile/models/profile_models.dart


import 'package:absensi_maps/presentation/absensi/profile/models/user_base.dart';





// ====================================================================
// MODEL UNTUK DETAIL BATCH YANG BERSARANG DI PROFIL
// ====================================================================
class ProfileBatchDetail {
  final int id;
  final String batchKe;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileBatchDetail({
    required this.id,
    required this.batchKe,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileBatchDetail.fromJson(Map<String, dynamic> json) {
    // Gunakan _tryParseDateTime dari user_base_model.dart (yang diimpor)
    return ProfileBatchDetail(
      id: json['id'] as int,
      batchKe: json['batch_ke'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batch_ke': batchKe,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// ====================================================================
// MODEL UNTUK DETAIL TRAINING YANG BERSARANG DI PROFIL
// ====================================================================
class ProfileTrainingDetail {
  final int id;
  final String title;
  final String? description;
  final int? participantCount;
  final String? standard;
  final String? duration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileTrainingDetail({
    required this.id,
    required this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileTrainingDetail.fromJson(Map<String, dynamic> json) {
    // Gunakan _tryParseDateTime dari user_base_model.dart (yang diimpor)
    return ProfileTrainingDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      participantCount: json['participant_count'] as int?,
      standard: json['standard'] as String?,
      duration: json['duration'] as String?,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'participant_count': participantCount,
      'standard': standard,
      'duration': duration,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// ====================================================================
// MODEL PENGGUNA YANG DIPERLUAS UNTUK PROFIL LENGKAP
// (Ini mewakili objek 'data' dari GET /api/profile)
// ====================================================================
class ProfileUser extends User { // Memperluas kelas User dasar
  final String? batchKe;
  final String? trainingTitle;
  final ProfileBatchDetail? batch;
  final ProfileTrainingDetail? training;
  final String? jenisKelamin;
  final String? profilePhoto;

  const ProfileUser({
    required super.id,
    required super.name,
    required super.email,
    super.emailVerifiedAt,
    required super.createdAt,
    required super.updatedAt,
    this.batchKe,
    this.trainingTitle,
    this.batch,
    this.training,
    this.jenisKelamin,
    this.profilePhoto,
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    // Panggil fromJson dari kelas dasar (User) untuk mengambil properti dasar
    final User baseUser = User.fromJson(json);
    return ProfileUser(
      id: baseUser.id,
      name: baseUser.name,
      email: baseUser.email,
      emailVerifiedAt: baseUser.emailVerifiedAt,
      createdAt: baseUser.createdAt,
      updatedAt: baseUser.updatedAt,
      batchKe: json['batch_ke'] as String?,
      trainingTitle: json['training_title'] as String?,
      batch: json['batch'] != null
          ? ProfileBatchDetail.fromJson(json['batch'] as Map<String, dynamic>)
          : null,
      training: json['training'] != null
          ? ProfileTrainingDetail.fromJson(json['training'] as Map<String, dynamic>)
          : null,
      jenisKelamin: json['jenis_kelamin'] as String?,
      profilePhoto: json['profile_photo'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> baseJson = super.toJson();
    return {
      ...baseJson,
      'batch_ke': batchKe,
      'training_title': trainingTitle,
      'batch': batch?.toJson(),
      'training': training?.toJson(),
      'jenis_kelamin': jenisKelamin,
      'profile_photo': profilePhoto,
    };
  }
}


// Model untuk keseluruhan respons GET /api/profile
class ProfileResponse {
  final String message;
  final ProfileUser data; // Menggunakan ProfileUser yang diperluas

  const ProfileResponse({required this.message, required this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      message: json['message'] as String,
      data: ProfileUser.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}

// Model untuk keseluruhan respons PUT /api/profile (Edit Profile berhasil)
class EditProfileResponse {
  final String message;
  final ProfileUser data; // Menggunakan ProfileUser yang diperluas

  const EditProfileResponse({required this.message, required this.data});

  factory EditProfileResponse.fromJson(Map<String, dynamic> json) {
    return EditProfileResponse(
      message: json['message'] as String,
      data: ProfileUser.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.toJson(),
    };
  }
}
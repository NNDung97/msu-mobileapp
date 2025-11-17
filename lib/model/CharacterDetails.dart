// lib/model/character_details.dart

class CharacterCommon {
  final String name;
  final int level;
  final GameWorld world;
  final Job job;
  final String nesolet;
  final String exp;
  final String totalExp;
  final String expr;
  final String gender;
  final int popularity;
  final int honorExp;

  CharacterCommon({
    required this.name,
    required this.level,
    required this.world,
    required this.job,
    required this.nesolet,
    required this.exp,
    required this.totalExp,
    required this.expr,
    required this.gender,
    required this.popularity,
    required this.honorExp,
  });

  factory CharacterCommon.fromJson(Map<String, dynamic> json) {
    return CharacterCommon(
      name: json['name'] ?? '',
      level: json['level'] ?? 0,
      world: GameWorld.fromJson(json['world'] ?? {}),
      job: Job.fromJson(json['job'] ?? {}),
      nesolet: json['nesolet'] ?? '',
      exp: json['exp'] ?? '',
      totalExp: json['totalExp'] ?? '',
      expr: json['expr'] ?? '',
      gender: json['gender']?.toString() ?? '',
      popularity: json['popularity'] ?? 0,
      honorExp: json['honorExp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'level': level,
        'world': world.toJson(),
        'job': job.toJson(),
        'nesolet': nesolet,
        'exp': exp,
        'totalExp': totalExp,
        'expr': expr,
        'gender': gender,
        'popularity': popularity,
        'honorExp': honorExp,
      };
}

class GameWorld {
  final int code;
  final String name;

  GameWorld({
    required this.code,
    required this.name,
  });

  factory GameWorld.fromJson(Map<String, dynamic> json) {
    return GameWorld(
      code: json['code'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
      };
}

class Job {
  final int classCode;
  final String className;
  final int jobCode;
  final String jobName;

  Job({
    required this.classCode,
    required this.className,
    required this.jobCode,
    required this.jobName,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      classCode: json['classCode'] ?? 0,
      className: json['className'] ?? '',
      jobCode: json['jobCode'] ?? 0,
      jobName: json['jobName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'classCode': classCode,
        'className': className,
        'jobCode': jobCode,
        'jobName': jobName,
      };
}
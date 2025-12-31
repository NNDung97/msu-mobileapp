import 'characters.dart';

class LoginResult {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String walletAddress;
  final List<Character> characters;

  LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.walletAddress,
    required this.characters,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final characterList =
        (json['characters']?['data']?['characters'] as List? ?? [])
            .map((e) => Character.fromJson(e))
            .toList();

    return LoginResult(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      userId: json['user']['_id'],
      walletAddress: json['user']['walletAddress'],
      characters: characterList,
    );
  }
}

class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String bio;
  final String nickname; // Adicionando o campo nickname
  final String? backgroundUrl; // Adicionando o campo backgroundUrl
  List<String> photos; // Lista de URLs das fotos (crumbs)

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    required this.nickname, // Inicializa o nickname
    required this.backgroundUrl, // Inicializa o backgroundUrl
    required this.photos, // Inicializa a lista de fotos
  });

  // Construtor para criar um objeto UserProfileModel a partir de um documento do Firestore
  factory UserProfileModel.fromMap(
      Map<String, dynamic> data, String documentId) {
    return UserProfileModel(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      bio: data['bio'] ?? '',
      nickname: data['nickname'] ?? '', // Conversão para nickname
      backgroundUrl:
          data['backgroundUrl'] ?? '', // Conversão para backgroundUrl
      photos: List<String>.from(
          data['photos'] ?? []), // Conversão para lista de fotos
    );
  }
}

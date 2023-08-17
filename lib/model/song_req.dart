class SongRequest {
  final String id;
  final String djId;
  final String songName;
  final String message;
  final bool isAccepted; // Indicates whether the request is accepted or not

  SongRequest({
    required this.id,
    required this.djId,
    required this.songName,
    required this.message,
    required this.isAccepted,
  });
}

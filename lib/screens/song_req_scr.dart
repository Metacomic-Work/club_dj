import 'package:flutter/material.dart';

import '../services/song_req.dart'; 

class SongRequestScreen extends StatefulWidget {
  final String djId;

  SongRequestScreen({required this.djId});

  @override
  _SongRequestScreenState createState() => _SongRequestScreenState();
}

class _SongRequestScreenState extends State<SongRequestScreen> {
  final SongRequestService _requestService = SongRequestService();
  late TextEditingController _songNameController;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _songNameController = TextEditingController();
    _messageController = TextEditingController();
  }

  Future<void> _sendRequest() async {
    final String songName = _songNameController.text.trim();
    final String message = _messageController.text.trim();

    if (songName.isNotEmpty) {
      await _requestService.sendSongRequest(widget.djId, songName, message);
      // Show confirmation or handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Song Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _songNameController,
              decoration: InputDecoration(labelText: 'Song Name'),
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Message'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendRequest,
              child: Text('Send Request'),
            ),
          ],
        ),
      ),
    );
  }
}

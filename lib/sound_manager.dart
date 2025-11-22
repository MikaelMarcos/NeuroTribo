import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  // Instância do player
  static final AudioPlayer _player = AudioPlayer();

  // Tocar som de clique suave (navegação)
  static Future<void> playClick() async {
    await _stopAndPlay('audio/click.mp3', volume: 0.5); // Volume mais baixo
  }

  // Tocar som de check (marcar tarefa)
  static Future<void> playCheck() async {
    await _stopAndPlay('audio/check.mp3', volume: 0.6);
  }

  // Tocar som de sucesso (concluir dia/desafio)
  static Future<void> playSuccess() async {
    await _stopAndPlay('audio/success.mp3', volume: 1.0);
  }

  // Função auxiliar para parar o som anterior e tocar o novo (evita sobreposição ruim)
  static Future<void> _stopAndPlay(String path, {double volume = 1.0}) async {
    try {
      await _player.stop(); // Para o som anterior se houver
      await _player.setVolume(volume);
      await _player.setSource(AssetSource(path));
      await _player.resume();
    } catch (e) {
      // Ignora erros de áudio para não travar o app
      print("Erro ao tocar som: $e");
    }
  }
}
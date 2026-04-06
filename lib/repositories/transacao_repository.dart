// ===========================
// 📁 repositories/transacao_repository.dart
// ===========================
import '../models/transacao.dart';

abstract class TransacaoRepository {
  Future<List<Transacao>> listar();
  Future<void> salvar(Transacao t);
  Future<void> deletar(String id);
}


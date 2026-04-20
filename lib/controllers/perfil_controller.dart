// ─────────────────────────────────────────────
// perfil_controller.dart
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'dart:io';
import '../services/perfil_service.dart';
import '../model/perfil_model.dart';


class PerfilController extends ChangeNotifier {
  PerfilController({PerfilService? service})
      : _service = service ?? PerfilService();

  final PerfilService _service;

  // ── Estado ────────────────────────────────────────────
  PerfilModel? _perfil;
  PerfilModel? get perfil => _perfil;

  bool _carregando = false;
  bool get carregando => _carregando;

  bool _salvando = false;
  bool get salvando => _salvando;

  bool _buscandoCep = false;
  bool get buscandoCep => _buscandoCep;

  bool _alterandoSenha = false;
  bool get alterandoSenha => _alterandoSenha;

  bool _subindoFoto = false;
  bool get subindoFoto => _subindoFoto;

  String? _erro;
  String? get erro => _erro;

  String? _sucesso;
  String? get sucesso => _sucesso;

  // ── Token de autenticação (injete após login) ─────────
  String? authToken;

  // ═══════════════════════════════════════════════════════
  //  CARREGAR
  // ═══════════════════════════════════════════════════════

  Future<void> carregarPerfil(String userId) async {
    _set(carregando: true, limparMensagens: true);
    try {
      _perfil = await _service.buscarPerfil(userId, authToken: authToken);
    } catch (e) {
      _erro = _mensagem(e);
    } finally {
      _set(carregando: false);
    }
  }

  // ═══════════════════════════════════════════════════════
  //  SALVAR PERFIL
  // ═══════════════════════════════════════════════════════

  Future<bool> salvarPerfil(PerfilModel atualizado) async {
    _set(salvando: true, limparMensagens: true);
    try {
      _perfil = await _service.atualizarPerfil(
        atualizado.copyWith(atualizadoEm: DateTime.now()),
        authToken: authToken,
      );
      _sucesso = 'Perfil atualizado com sucesso!';
      return true;
    } catch (e) {
      _erro = _mensagem(e);
      return false;
    } finally {
      _set(salvando: false);
    }
  }

  // ═══════════════════════════════════════════════════════
  //  BUSCAR CEP
  // ═══════════════════════════════════════════════════════

  /// Retorna o [EnderecoModel] preenchido pelo ViaCEP.
  /// Em caso de erro retorna null e popula [erro].
  Future<EnderecoModel?> buscarCep(String cep) async {
    _set(buscandoCep: true, limparMensagens: true);
    try {
      final endereco = await _service.buscarCep(cep);
      _sucesso = 'Endereço encontrado!';
      return endereco;
    } catch (e) {
      _erro = _mensagem(e);
      return null;
    } finally {
      _set(buscandoCep: false);
    }
  }

  // ═══════════════════════════════════════════════════════
  //  ALTERAR SENHA
  // ═══════════════════════════════════════════════════════

  Future<bool> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
    required String confirmacao,
  }) async {
    _limparMensagens();

    if (senhaAtual.isEmpty) {
      _erro = 'Digite a senha atual.';
      notifyListeners();
      return false;
    }
    if (novaSenha.length < 8) {
      _erro = 'A nova senha deve ter pelo menos 8 caracteres.';
      notifyListeners();
      return false;
    }
    if (novaSenha != confirmacao) {
      _erro = 'As senhas não coincidem.';
      notifyListeners();
      return false;
    }

    _set(alterandoSenha: true);
    try {
      await _service.alterarSenha(
        userId: _perfil!.id,
        senhaAtual: senhaAtual,
        novaSenha: novaSenha,
        authToken: authToken,
      );
      _sucesso = 'Senha alterada com sucesso!';
      return true;
    } catch (e) {
      _erro = _mensagem(e);
      return false;
    } finally {
      _set(alterandoSenha: false);
    }
  }

  // ═══════════════════════════════════════════════════════
  //  FOTO
  // ═══════════════════════════════════════════════════════

  Future<bool> uploadFoto(File file) async {
    if (_perfil == null) return false;
    _set(subindoFoto: true, limparMensagens: true);
    try {
      final url = await _service.uploadFoto(_perfil!.id, file);
      _perfil = _perfil!.copyWith(fotoUrl: url);
      await _service.atualizarPerfil(_perfil!, authToken: authToken);
      _sucesso = 'Foto atualizada!';
      return true;
    } catch (e) {
      _erro = _mensagem(e);
      return false;
    } finally {
      _set(subindoFoto: false);
    }
  }

  // ═══════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════

  void limparMensagens() {
    _limparMensagens();
    notifyListeners();
  }

  void _limparMensagens() {
    _erro = null;
    _sucesso = null;
  }

  void _set({
    bool? carregando,
    bool? salvando,
    bool? buscandoCep,
    bool? alterandoSenha,
    bool? subindoFoto,
    bool limparMensagens = false,
  }) {
    if (limparMensagens) _limparMensagens();
    if (carregando != null) _carregando = carregando;
    if (salvando != null) _salvando = salvando;
    if (buscandoCep != null) _buscandoCep = buscandoCep;
    if (alterandoSenha != null) _alterandoSenha = alterandoSenha;
    if (subindoFoto != null) _subindoFoto = subindoFoto;
    notifyListeners();
  }

  String _mensagem(Object e) =>
      e.toString().replaceFirst('Exception: ', '');
}
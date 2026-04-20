// ─────────────────────────────────────────────
// perfil_service.dart
// ─────────────────────────────────────────────

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../model/perfil_model.dart';

class PerfilService {
  final _col = FirebaseFirestore.instance.collection('tab_perfil');
  final _storage = FirebaseStorage.instance;

  // ═══════════════════════════════════════════════════════
  //  PERFIL
  // ═══════════════════════════════════════════════════════

  /// Busca o perfil do usuário no Firestore.
  Future<PerfilModel> buscarPerfil(String userId, {String? authToken}) async {
    var doc = await _col.doc(userId).get();
    
    // Se não existir na tab_perfil, tenta buscar na tab_usuario (onde o login cria o doc)
    if (!doc.exists) {
      final userDoc = await FirebaseFirestore.instance.collection('tab_usuario').doc(userId).get();
      if (userDoc.exists) {
        // Cria o registro na tab_perfil a partir da tab_usuario
        final userData = userDoc.data()!;
        final novoPerfil = {
          'nome': userData['nome'] ?? '',
          'sobrenome': userData['sobrenome'] ?? '',
          'email': userData['email'] ?? '',
          'perfil': userData['perfil'] ?? 'COLABORADOR',
          'criadoEm': FieldValue.serverTimestamp(),
        };
        await _col.doc(userId).set(novoPerfil);
        doc = await _col.doc(userId).get();
      } else {
        throw Exception('Perfil não encontrado no Firestore.');
      }
    }

    final data = doc.data()!;
    // O PerfilModel.fromJson espera um ID, mas no Firestore o ID é o nome do documento.
    final map = Map<String, dynamic>.from(data);
    map['id'] = doc.id;
    
    return PerfilModel.fromJson(map);
  }

  /// Atualiza o perfil no Firestore.
  Future<PerfilModel> atualizarPerfil(PerfilModel perfil, {String? authToken}) async {
    final data = perfil.toJson();
    // Removemos o ID do corpo do documento para não duplicar, já que ele é o nome do documento
    data.remove('id');
    
    await _col.doc(perfil.id).update(data);
    
    return perfil;
  }

  // ═══════════════════════════════════════════════════════
  //  SENHA (Firebase Auth)
  // ═══════════════════════════════════════════════════════

  /// Altera a senha do usuário. 
  /// Nota: No Firebase, a alteração de senha costuma ser via auth.
  Future<void> alterarSenha({
    required String userId,
    required String senhaAtual,
    required String novaSenha,
    String? authToken,
  }) async {
    // Para simplificar e manter o fluxo, lançamos erro se tentar usar API REST inexistente.
    // O correto seria usar FirebaseAuth.instance.currentUser?.updatePassword(novaSenha).
    throw Exception('A alteração de senha deve ser feita via Firebase Authentication.');
  }

  // ═══════════════════════════════════════════════════════
  //  UPLOAD DE FOTO
  // ═══════════════════════════════════════════════════════

  Future<String> uploadFoto(String userId, File file) async {
    final ref = _storage.ref().child('perfis').child('$userId.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  // ═══════════════════════════════════════════════════════
  //  VIA CEP
  // ═══════════════════════════════════════════════════════

  /// Consulta o ViaCEP e retorna um [EnderecoModel] parcial.
  Future<EnderecoModel> buscarCep(String cep) async {
    final raw = cep.replaceAll(RegExp(r'\D'), '');
    if (raw.length != 8) throw Exception('CEP inválido');

    final uri = Uri.parse('https://viacep.com.br/ws/$raw/json/');
    final resp = await http.get(uri);

    if (resp.statusCode != 200) throw Exception('Falha na consulta do CEP');

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (data.containsKey('erro')) throw Exception('CEP não encontrado');

    return EnderecoModel.fromViaCep(data);
  }
}

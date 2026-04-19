// lib/features/desconto/service/desconto_service.dart

import '../model/desconto_model.dart';

abstract class IDescontoService {
  Future<List<DescontoModel>> buscarTodos();
  Future<DescontoModel> buscarPorId(String id);
  Future<DescontoModel> criar(DescontoModel desconto);
  Future<DescontoModel> atualizar(DescontoModel desconto);
  Future<void> excluir(String id);
  Future<List<DescontoModel>> filtrarPorStatus(DescontoStatus? status);
  Future<DescontoResumo> obterResumo();
}

class DescontoService implements IDescontoService {
  static const _delay = Duration(milliseconds: 500);

  final List<DescontoModel> _mockData = [
    DescontoModel(
      id: '1',
      numeroDocumento: 'DUP-2024-00341',
      tipoDocumento: TipoDocumento.duplicata,
      dataEmissao: DateTime(2024, 10, 1),
      dataVencimento: DateTime(2024, 11, 30),
      valorNominal: 45000.00,
      taxaJuros: 1.8,
      taxaIof: 0.38,
      taxaDesconto: 2.1,
      nomeCliente: 'Mercado Rede Ltda',
      iniciaisCliente: 'MR',
      status: DescontoStatus.ativo,
    ),
    DescontoModel(
      id: '2',
      numeroDocumento: 'CHQ-2024-00128',
      tipoDocumento: TipoDocumento.cheque,
      dataEmissao: DateTime(2024, 10, 10),
      dataVencimento: DateTime(2024, 12, 10),
      valorNominal: 18500.00,
      taxaJuros: 1.5,
      taxaIof: 0.38,
      taxaDesconto: 1.9,
      nomeCliente: 'Coop. Sul Agrícola',
      iniciaisCliente: 'CS',
      status: DescontoStatus.ativo,
    ),
    DescontoModel(
      id: '3',
      numeroDocumento: 'NPR-2024-00055',
      tipoDocumento: TipoDocumento.notaPromissoria,
      dataEmissao: DateTime(2024, 9, 15),
      dataVencimento: DateTime(2024, 11, 5),
      valorNominal: 72000.00,
      taxaJuros: 2.0,
      taxaIof: 0.38,
      taxaDesconto: 2.4,
      nomeCliente: 'Grupo Lesta S/A',
      iniciaisCliente: 'GL',
      status: DescontoStatus.expirando,
    ),
    DescontoModel(
      id: '4',
      numeroDocumento: 'DUP-2024-00399',
      tipoDocumento: TipoDocumento.duplicata,
      dataEmissao: DateTime(2024, 11, 1),
      dataVencimento: DateTime(2025, 1, 15),
      valorNominal: 31200.00,
      taxaJuros: 1.6,
      taxaIof: 0.38,
      taxaDesconto: 1.95,
      nomeCliente: 'Varejo Express ME',
      iniciaisCliente: 'VX',
      status: DescontoStatus.agendado,
    ),
    DescontoModel(
      id: '5',
      numeroDocumento: 'CCE-2024-00012',
      tipoDocumento: TipoDocumento.cce,
      dataEmissao: DateTime(2024, 8, 20),
      dataVencimento: DateTime(2024, 9, 30),
      valorNominal: 95000.00,
      taxaJuros: 2.2,
      taxaIof: 0.38,
      taxaDesconto: 2.6,
      nomeCliente: 'Agro Paranaense SA',
      iniciaisCliente: 'AP',
      status: DescontoStatus.expirado,
    ),
  ];

  @override
  Future<List<DescontoModel>> buscarTodos() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_mockData);
  }

  @override
  Future<DescontoModel> buscarPorId(String id) async {
    await Future.delayed(_delay);
    return _mockData.firstWhere(
          (d) => d.id == id,
      orElse: () => throw DescontoNaoEncontradoException(id),
    );
  }

  @override
  Future<DescontoModel> criar(DescontoModel desconto) async {
    await Future.delayed(_delay);
    final novo = desconto.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _mockData.add(novo);
    return novo;
  }

  @override
  Future<DescontoModel> atualizar(DescontoModel desconto) async {
    await Future.delayed(_delay);
    final i = _mockData.indexWhere((d) => d.id == desconto.id);
    if (i == -1) throw DescontoNaoEncontradoException(desconto.id);
    _mockData[i] = desconto;
    return desconto;
  }

  @override
  Future<void> excluir(String id) async {
    await Future.delayed(_delay);
    final i = _mockData.indexWhere((d) => d.id == id);
    if (i == -1) throw DescontoNaoEncontradoException(id);
    _mockData.removeAt(i);
  }

  @override
  Future<List<DescontoModel>> filtrarPorStatus(DescontoStatus? status) async {
    final todos = await buscarTodos();
    if (status == null) return todos;
    return todos.where((d) => d.status == status).toList();
  }

  @override
  Future<DescontoResumo> obterResumo() async {
    final todos = await buscarTodos();
    return DescontoResumo(
      total:        todos.length,
      ativos:       todos.where((d) => d.status == DescontoStatus.ativo).length,
      expirando:    todos.where((d) => d.status == DescontoStatus.expirando).length,
      totalLiquido: todos.fold(0, (s, d) => s + d.valorLiquido),
      totalNominal: todos.fold(0, (s, d) => s + d.valorNominal),
    );
  }
}

class DescontoNaoEncontradoException implements Exception {
  final String id;
  const DescontoNaoEncontradoException(this.id);
  @override
  String toString() => 'DescontoNaoEncontradoException: id "$id" não encontrado.';
}
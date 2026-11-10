import 'package:flutter/material.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../auth/presentation/controllers/auth_session_controller.dart';
import '../../domain/entities/responsible.dart';
import '../../domain/repositories/responsible_repository.dart';

class ResponsibleListPage extends StatefulWidget {
  final ResponsibleRepository repository;
  final AuthSessionController? authController;

  const ResponsibleListPage({
    super.key,
    required this.repository,
    this.authController,
  });

  @override
  State<ResponsibleListPage> createState() => _ResponsibleListPageState();
}

class _ResponsibleListPageState extends State<ResponsibleListPage> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Responsible> _responsibles = [];

  @override
  void initState() {
    super.initState();
    _loadResponsibles();
  }

  Future<void> _loadResponsibles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.repository.getResponsibles();
      setState(() {
        _responsibles = result.content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const LoadingStateView(message: 'Carregando responsáveis contábeis...');
    } else if (_errorMessage != null) {
      content = ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadResponsibles,
      );
    } else if (_responsibles.isEmpty) {
      content = EmptyStateView(
        icon: Icons.people_outline,
        title: 'Nenhum responsável cadastrado',
        message: 'Cadastre os contadores e analistas que serão responsáveis pelas obrigações.',
        actionLabel: 'Novo Responsável',
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulário de cadastro em desenvolvimento.')),
          );
        },
      );
    } else {
      content = RefreshIndicator(
        onRefresh: _loadResponsibles,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _responsibles.length,
          itemBuilder: (context, index) {
            final responsible = _responsibles[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: responsible.active
                      ? const Color(0xFFDBEAFE)
                      : const Color(0xFFF1F5F9),
                  child: Text(
                    responsible.name.isNotEmpty
                        ? responsible.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: responsible.active
                          ? const Color(0xFF1E3A8A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                title: Text(
                  responsible.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(responsible.email),
                trailing: Chip(
                  label: Text(
                    responsible.active ? 'Ativo' : 'Inativo',
                    style: TextStyle(
                      color: responsible.active
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: responsible.active
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF1F5F9),
                  side: BorderSide.none,
                ),
              ),
            );
          },
        ),
      );
    }

    return AppScaffold(
      title: 'Responsáveis',
      currentNavIndex: 2,
      authController: widget.authController,
      body: content,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulário de cadastro de responsáveis em breve.')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Responsável'),
      ),
    );
  }
}

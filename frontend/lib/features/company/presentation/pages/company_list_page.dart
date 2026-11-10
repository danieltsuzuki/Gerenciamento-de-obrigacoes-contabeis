import 'package:flutter/material.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/loading_state_view.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';

class CompanyListPage extends StatefulWidget {
  final CompanyRepository repository;

  const CompanyListPage({
    super.key,
    required this.repository,
  });

  @override
  State<CompanyListPage> createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Company> _companies = [];

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.repository.getCompanies();
      setState(() {
        _companies = result;
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
      content = const LoadingStateView(message: 'Carregando empresas cadastradas...');
    } else if (_errorMessage != null) {
      content = ErrorStateView(
        message: _errorMessage!,
        onRetry: _loadCompanies,
      );
    } else if (_companies.isEmpty) {
      content = EmptyStateView(
        icon: Icons.business_outlined,
        title: 'Nenhuma empresa encontrada',
        message: 'Cadastre sua primeira empresa para gerenciar suas obrigações fiscais.',
        actionLabel: 'Nova Empresa',
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulário de cadastro em desenvolvimento.')),
          );
        },
      );
    } else {
      content = RefreshIndicator(
        onRefresh: _loadCompanies,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _companies.length,
          itemBuilder: (context, index) {
            final company = _companies[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: company.active
                      ? const Color(0xFFDBEAFE)
                      : const Color(0xFFF1F5F9),
                  child: Icon(
                    Icons.business,
                    color: company.active
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                title: Text(
                  company.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('CNPJ: ${company.cnpj}'),
                trailing: Chip(
                  label: Text(
                    company.active ? 'Ativa' : 'Inativa',
                    style: TextStyle(
                      color: company.active
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: company.active
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
      title: 'Empresas',
      currentNavIndex: 1,
      body: content,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulário de cadastro de empresas em breve.')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Empresa'),
      ),
    );
  }
}

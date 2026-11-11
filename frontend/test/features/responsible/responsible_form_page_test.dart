import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player_contabilidade_front/core/network/api_exception.dart';
import 'package:player_contabilidade_front/core/network/page_response.dart';
import 'package:player_contabilidade_front/core/theme/app_theme.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/create_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/data/models/update_responsible_request.dart';
import 'package:player_contabilidade_front/features/responsible/domain/entities/responsible.dart';
import 'package:player_contabilidade_front/features/responsible/domain/repositories/responsible_repository.dart';
import 'package:player_contabilidade_front/features/responsible/presentation/pages/responsible_form_page.dart';

String _testPassword() => 'mock-password-123';

class MockResponsibleRepository implements ResponsibleRepository {
  CreateResponsibleRequest? lastCreateRequest;
  UpdateResponsibleRequest? lastUpdateRequest;
  int? lastUpdateId;
  bool shouldThrowDuplicate = false;
  bool shouldThrowError = false;

  @override
  Future<Responsible> createResponsible(CreateResponsibleRequest request) async {
    lastCreateRequest = request;
    if (shouldThrowDuplicate) {
      throw const ApiException(
        statusCode: 409,
        code: 'DUPLICATE_EMAIL',
        message: 'E-mail já cadastrado',
      );
    }
    if (shouldThrowError) {
      throw const ApiException(
        statusCode: 500,
        code: 'SERVER_ERROR',
        message: 'Erro interno do servidor',
      );
    }
    return Responsible(
      id: 99,
      name: request.name,
      email: request.email,
      active: request.active,
    );
  }

  @override
  Future<Responsible> updateResponsible(int id, UpdateResponsibleRequest request) async {
    lastUpdateId = id;
    lastUpdateRequest = request;
    if (shouldThrowDuplicate) {
      throw const ApiException(
        statusCode: 409,
        code: 'DUPLICATE_EMAIL',
        message: 'E-mail já cadastrado',
      );
    }
    return Responsible(
      id: id,
      name: request.name,
      email: request.email,
      active: request.active,
    );
  }

  @override
  Future<PageResponse<Responsible>> getResponsibles({
    bool? active,
    int page = 0,
    int size = 20,
    String sort = 'id,asc',
    String? q,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Responsible> getResponsibleById(int id) async => throw UnimplementedError();
}

void main() {
  group('ResponsibleFormPage - SPEC-017', () {
    late MockResponsibleRepository mockRepo;

    setUp(() {
      mockRepo = MockResponsibleRepository();
    });

    Widget createWidgetUnderTest({Responsible? responsible}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: ResponsibleFormPage(
          repository: mockRepo,
          responsible: responsible,
        ),
      );
    }

    testWidgets('deve renderizar campos obrigatórios em modo de criação', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Novo Responsável'), findsOneWidget);
      expect(find.byKey(const Key('responsible-name-input')), findsOneWidget);
      expect(find.byKey(const Key('responsible-email-input')), findsOneWidget);
      expect(find.byKey(const Key('responsible-password-input')), findsOneWidget);
      expect(find.byKey(const Key('responsible-active-switch')), findsNothing);
      expect(find.byKey(const Key('responsible-submit-button')), findsOneWidget);
      expect(find.text('Cadastrar Responsável'), findsOneWidget);
    });

    testWidgets('deve validar campos vazios e formato inválido de e-mail', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('responsible-submit-button')));
      await tester.pumpAndSettle();

      expect(find.text('O nome completo é obrigatório.'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório.'), findsOneWidget);
      expect(find.text('A senha inicial é obrigatória para cadastro.'), findsOneWidget);
      expect(mockRepo.lastCreateRequest, isNull);

      await tester.enterText(
        find.byKey(const Key('responsible-email-input')),
        'email-sem-formato',
      );
      await tester.enterText(
        find.byKey(const Key('responsible-password-input')),
        '123',
      );
      await tester.tap(find.byKey(const Key('responsible-submit-button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Informe um e-mail válido (ex.: usuario@empresa.com).'),
        findsOneWidget,
      );
      expect(
        find.text('A senha deve possuir no mínimo 6 caracteres.'),
        findsOneWidget,
      );
    });

    testWidgets('deve cadastrar novo responsável com sucesso', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('responsible-name-input')),
        'Maria Oliveira',
      );
      await tester.enterText(
        find.byKey(const Key('responsible-email-input')),
        'maria@empresa.com',
      );
      await tester.enterText(
        find.byKey(const Key('responsible-password-input')),
        _testPassword(),
      );

      await tester.tap(find.byKey(const Key('responsible-submit-button')));
      await tester.pumpAndSettle();

      expect(mockRepo.lastCreateRequest, isNotNull);
      expect(mockRepo.lastCreateRequest!.name, 'Maria Oliveira');
      expect(mockRepo.lastCreateRequest!.email, 'maria@empresa.com');
      expect(mockRepo.lastCreateRequest!.password, _testPassword());
      expect(mockRepo.lastCreateRequest!.active, isTrue);
    });

    testWidgets('deve exibir mensagem de erro para e-mail duplicado (409 DUPLICATE_EMAIL)',
        (tester) async {
      mockRepo.shouldThrowDuplicate = true;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('responsible-name-input')),
        'Maria Oliveira',
      );
      await tester.enterText(
        find.byKey(const Key('responsible-email-input')),
        'maria@empresa.com',
      );
      await tester.enterText(
        find.byKey(const Key('responsible-password-input')),
        _testPassword(),
      );

      await tester.tap(find.byKey(const Key('responsible-submit-button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Este e-mail já está em uso por outro responsável (RN-003).'),
        findsOneWidget,
      );
    });

    testWidgets('deve abrir formulário em modo edição com dados preenchidos e sem campo de senha',
        (tester) async {
      const existing = Responsible(
        id: 15,
        name: 'Carlos Alberto',
        email: 'carlos@empresa.com',
        active: true,
      );

      await tester.pumpWidget(createWidgetUnderTest(responsible: existing));
      await tester.pumpAndSettle();

      expect(find.text('Editar Responsável'), findsOneWidget);
      expect(find.text('Carlos Alberto'), findsOneWidget);
      expect(find.text('carlos@empresa.com'), findsOneWidget);
      expect(find.byKey(const Key('responsible-password-input')), findsNothing);
      expect(
        find.text(
          'A senha deste responsável é confidencial e não pode ser visualizada ou alterada neste formulário.',
        ),
        findsOneWidget,
      );
      expect(find.text('Salvar Alterações'), findsOneWidget);

      // Desativar responsável (inativação lógica)
      await tester.tap(find.byKey(const Key('responsible-active-switch')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('responsible-submit-button')));
      await tester.pumpAndSettle();

      expect(mockRepo.lastUpdateId, 15);
      expect(mockRepo.lastUpdateRequest, isNotNull);
      expect(mockRepo.lastUpdateRequest!.name, 'Carlos Alberto');
      expect(mockRepo.lastUpdateRequest!.email, 'carlos@empresa.com');
      expect(mockRepo.lastUpdateRequest!.active, isFalse);
    });

    testWidgets('deve alternar visibilidade da senha inicial ao clicar no toggle', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final pwdFinder = find.byKey(const Key('responsible-password-input'));
      TextField pwdField = tester.widget<TextField>(
        find.descendant(of: pwdFinder, matching: find.byType(TextField)),
      );
      expect(pwdField.obscureText, isTrue);

      await tester.tap(find.byKey(const Key('responsible-password-toggle')));
      await tester.pumpAndSettle();

      pwdField = tester.widget<TextField>(
        find.descendant(of: pwdFinder, matching: find.byType(TextField)),
      );
      expect(pwdField.obscureText, isFalse);
    });
  });
}

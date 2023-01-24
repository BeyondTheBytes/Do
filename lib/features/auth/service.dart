import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../../domain/structures.dart';

final _firebaseAuth = GetIt.I.get<FirebaseAuth>();

class EmailAuthService {
  EmailAuthService();

  Future<Either<UserCredential, Failure>> signUp({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
          email: _normalizeEmail(email), password: password);
      final user = cred.user;
      if (user == null) {
        return Either.failure(Failure('Erro na criação de usuário'));
      }
      await user.updateDisplayName(name);
      return Either.success(cred);
    } on FirebaseAuthException catch (e) {
      return Either.failure(Failure(e.portugueseMessage));
    }
  }

  Future<Either<UserCredential, Failure>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
          email: _normalizeEmail(email), password: password);
      return Either.success(cred);
    } on FirebaseAuthException catch (e) {
      return Either.failure(Failure(e.portugueseMessage));
    }
  }

  Future<Either<void, Failure>> forgotPassword({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: _normalizeEmail(email));
      return Either.success(null);
    } on FirebaseAuthException catch (e) {
      return Either.failure(Failure(e.portugueseMessage));
    }
  }

  Future<Either<void, Failure>> updatePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = await _firebaseAuth.currentUser;
      if (user == null) {
        return Either.failure(Failure(
          'Você precisa estar logado para realizar essa operação',
        ));
      }

      final either = await signIn(
        email: email,
        password: currentPassword,
      );
      return either.when(
        success: (userCred) async {
          await user.updatePassword(newPassword);
          return Either.success(null);
        },
        failure: Either.failure,
      );
    } on FirebaseAuthException catch (e) {
      return Either.failure(Failure(e.portugueseMessage));
    }
  }
}

class UserAuthService {
  Future<void> setProfilePicture(String uid, File file) async {
    final ref = GetIt.I.get<FirebaseStorage>().ref().child('profiles/$uid');
    await ref.putFile(file);

    final imageUrl = await ref.getDownloadURL();
    final user = await _firebaseAuth.currentUser;
    user!.updatePhotoURL(imageUrl);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> deleteAccount() async {
    await _firebaseAuth.currentUser!.delete();
  }
}

// //////////////////////////////////////////////////////////////////////
// UTILS
// //////////////////////////////////////////////////////////////////////

String _normalizeEmail(String email) => email.trim();

// //////////////////////////////////////////////////////////////////////
// FAILURE
// //////////////////////////////////////////////////////////////////////

const _mapErrorsTranslation = {
  'app-deleted': """O banco de dados não foi localizado.""",
  'expired-action-code': """O código da ação o ou link expirou.""",
  'invalid-action-code':
      """O código da ação é inválido. Isso pode acontecer se o código estiver inválido ou já tiver sido usado.""",
  'user-disabled': """Seu usuário foi desativado.""",
  'user-not-found': """Esse usuário não existe.""",
  'weak-password': """A senha é muito fraca.""",
  'email-already-in-use':
      """Já existe uma conta com esse email. Tente fazer o login usando email e senha ou redes sociais.""",
  'invalid-email': """Endereço de email inválido.""",
  'operation-not-allowed': """Seu usuário está desativado.""",
  'account-exists-with-different-credential':
      """Esse email já está associado a outra conta.""",
  'auth-domain-config-required':
      """A configuração para autenticação não foi fornecida.""",
  'credential-already-in-use': """Já existe uma conta para esta credencial.""",
  'operation-not-supported-in-this-environment':
      """Esta operação não é permitida no ambiente que está sendo executada. Verifique se deve ser http ou https.""",
  'timeout':
      """Não foi possível realizar a operação: o servidor demorou muito para responder.""",
  'missing-android-pkg-name':
      """Deve ser fornecido um nome de pacote para instalação do aplicativo Android.""",
  'missing-continue-uri':
      """A próxima URL deve ser fornecida na solicitação.""",
  'missing-ios-bundle-id':
      """Deve ser fornecido um nome de pacote para instalação do aplicativo iOS.""",
  'invalid-continue-uri':
      """A próxima URL fornecida na solicitação é inválida.""",
  'unauthorized-continue-uri':
      """O domínio da próxima URL não está na lista de autorizações.""",
  'invalid-dynamic-link-domain':
      """O domínio de link dinâmico fornecido, não está autorizado ou configurado no projeto atual.""",
  'argument-error': """Verifique a configuração de link para o aplicativo.""",
  'invalid-persistence-type':
      """O tipo especificado para a persistência dos dados é inválido.""",
  'unsupported-persistence-type':
      """O ambiente atual não suportar o tipo especificado para persistência dos dados.""",
  'invalid-credential': """A credencial expirou ou está mal formada.""",
  'wrong-password': """Senha incorreta.""",
  'invalid-verification-code':
      """O código de verificação da credencial não é válido.""",
  'invalid-verification-id':
      """O ID de verificação da credencial não é válido.""",
  'custom-token-mismatch': """O token está diferente do padrão solicitado.""",
  'invalid-custom-token': """O token fornecido não é válido.""",
  'captcha-check-failed':
      """O token de resposta do reCAPTCHA não é válido, expirou ou o domínio não é permitido.""",
  'invalid-phone-number':
      """O número de telefone está em um formato inválido (padrão E.164).""",
  'missing-phone-number': """O número de telefone é requerido.""",
  'quota-exceeded': """A cota de SMS foi excedida.""",
  'cancelled-popup-request':
      """Somente uma solicitação de janela pop-up é permitida de uma só vez.""",
  'popup-blocked': """A janela pop-up foi bloqueado pelo navegador.""",
  'popup-closed-by-user':
      """A janela pop-up foi fechada pelo usuário sem concluir o login no provedor.""",
  'unauthorized-domain':
      """O domínio do aplicativo não está autorizado para realizar operações.""",
  'invalid-user-token': """O usuário atual não foi identificado.""",
  'user-token-expired': """O token do usuário atual expirou.""",
  'null-user': """O usuário atual é nulo.""",
  'app-not-authorized':
      """Aplicação não autorizada para autenticar com a chave informada.""",
  'invalid-api-key': """A chave da API fornecida é inválida.""",
  'network-request-failed': """Falha de conexão com a rede.""",
  'requires-recent-login':
      """O último horário de acesso do usuário não atende ao limite de segurança.""",
  'too-many-requests':
      """As solicitações foram bloqueadas devido a atividades incomuns. Tente novamente depois que algum tempo.""",
  'web-storage-unsupported':
      """O navegador não suporta armazenamento ou se o usuário desativou este recurso.""",
  'invalid-claims': """Os atributos de cadastro personalizado são inválidos.""",
  'claims-too-large':
      """O tamanho da requisição excede o tamanho máximo permitido de 1 Megabyte.""",
  'id-token-expired': """O token informado expirou.""",
  'id-token-revoked': """O token informado perdeu a validade.""",
  'invalid-argument': """Um argumento inválido foi fornecido a um método.""",
  'invalid-creation-time':
      """O horário da criação precisa ser uma data UTC válida.""",
  'invalid-disabled-field':
      """A propriedade para usuário desabilitado é inválida.""",
  'invalid-display-name': """O nome do usuário é inválido.""",
  'invalid-email-verified': """O e-mail é inválido.""",
  'invalid-hash-algorithm':
      """O algoritmo de HASH não é uma criptografia compatível.""",
  'invalid-hash-block-size': """O tamanho do bloco de HASH não é válido.""",
  'invalid-hash-derived-key-length':
      """O tamanho da chave derivada do HASH não é válido.""",
  'invalid-hash-key':
      """A chave de HASH precisa ter um buffer de byte válido.""",
  'invalid-hash-memory-cost': """O custo da memória HASH não é válido.""",
  'invalid-hash-parallelization':
      """O carregamento em paralelo do HASH não é válido.""",
  'invalid-hash-rounds': """O arredondamento de HASH não é válido.""",
  'invalid-hash-salt-separator':
      """O campo do separador de SALT do algoritmo de geração de HASH precisa ser um buffer de byte válido.""",
  'invalid-id-token': """O código do token informado não é válido.""",
  'invalid-last-sign-in-time':
      """O último horário de login precisa ser uma data UTC válida.""",
  'invalid-page-token':
      """A próxima URL fornecida na solicitação é inválida.""",
  'invalid-password':
      """A senha é inválida, precisa ter pelo menos 6 caracteres.""",
  'invalid-password-hash': """O HASH da senha não é válida.""",
  'invalid-password-salt': """O SALT da senha não é válido.""",
  'invalid-photo-url': """A URL da foto de usuário é inválido.""",
  'invalid-provider-id': """O identificador de provedor não é compatível.""",
  'invalid-session-cookie-duration':
      """A duração do COOKIE da sessão precisa ser um número válido em milissegundos, entre 5 minutos e 2 semanas.""",
  'invalid-uid':
      """O identificador fornecido deve ter no máximo 128 caracteres.""",
  'invalid-user-import':
      """O registro do usuário a ser importado não é válido.""",
  'invalid-provider-data': """O provedor de dados não é válido.""",
  'maximum-user-count-exceeded':
      """O número máximo permitido de usuários a serem importados foi excedido.""",
  'missing-hash-algorithm':
      """É necessário fornecer o algoritmo de geração de HASH e seus parâmetros para importar usuários.""",
  'missing-uid': """Um identificador é necessário para a operação atual.""",
  'reserved-claims':
      """Uma ou mais propriedades personalizadas fornecidas usaram palavras reservadas.""",
  'session-cookie-revoked': """O COOKIE da sessão perdeu a validade.""",
  'uid-alread-exists': """O indentificador fornecido já está em uso.""",
  'email-already-exists': """O e-mail fornecido já está em uso.""",
  'phone-number-already-exists': """O telefone fornecido já está em uso.""",
  'project-not-found': """Nenhum projeto foi encontrado.""",
  'insufficient-permission':
      """A credencial utilizada não tem permissão para acessar o recurso solicitado.""",
  'internal-error':
      """O servidor de autenticação encontrou um erro inesperado ao tentar processar a solicitação."""
};

extension _TranslateFirebaseAuthException on FirebaseAuthException {
  String get portugueseMessage {
    final maybePtMessage = _mapErrorsTranslation[code];
    if (maybePtMessage != null) return maybePtMessage;
    // TODO: add crashlytics
    return 'Erro na autenticação: credenciais inválidas!';
  }
}

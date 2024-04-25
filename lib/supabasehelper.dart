import 'package:passwd/constants.dart';
import 'package:passwd/encryption.dart';
import 'package:passwd/kuznechik.dart';
import 'package:passwd/main.dart';
import 'package:supabase/supabase.dart';
import 'package:encrypt/encrypt.dart';

class SupabaseHelper extends Kuznechik {
  static final SupabaseHelper instance = SupabaseHelper._privateConstructor();
  static SupabaseClient? _client;
  SupabaseHelper._privateConstructor();

  Future<void> addUserAccount(String serviceName, String login, String password) async {
    final response = await supabase
        .from('user_accounts')
        .insert([
      {Constants.idUser: supabase.auth.currentUser!.id, Constants.serviceName: encrypt(serviceName), Constants.login: encrypt(login), Constants.pass: encrypt(password)}
    ]);

    if (response != null) {
      print('[DEBUG] - Ошибка при добавлении данных: ${response.error!.message}');
    } else {
      print('[DEBUG] - Данные успешно добавлены в таблицу user_accounts');
    }
  }

  Future<List<Map<String, dynamic>>> getUserAccounts() async {
    final response = await supabase.from('user_accounts').select().eq('user_id', supabase.auth.currentUser!.id).order("id");
    for (final account in response) {
      account[Constants.serviceName] = decrypt(account[Constants.serviceName]);
      account[Constants.login] = decrypt(account[Constants.login]);
      account[Constants.pass] = decrypt(account[Constants.pass]);
      //print(account);
    }
    print('[DEBUG] - user: ${supabase.auth.currentUser!.id}');
    return response;
  }

  Future<void> updateUserAccount(int id, String serviceName, String login, String password) async {
    final response = await supabase
        .from('user_accounts')
        .update({Constants.idUser: supabase.auth.currentUser!.id, Constants.serviceName: encrypt(serviceName), Constants.login: encrypt(login), Constants.pass: encrypt(password)})
        .eq('id', id);
    if (response != null) {
      print('[DEBUG] - Ошибка при обновлении данных: ${response.error!.message}');
    } else {
      print('[DEBUG] - Данные успешно обновлены');
    }
  }

  Future<void> deleteUserAccount(int id) async {
    final response = await supabase.from('user_accounts').delete().eq('id', id);
    if (response != null) {
      print('[DEBUG] - Ошибка при удалении данных: ${response.error!.message}');
    } else {
      print('[DEBUG] - Данные успешно удалены');
    }
  }
}

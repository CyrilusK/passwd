import 'package:passwd/main.dart';
import 'package:supabase/supabase.dart';

class SupabaseHelper {
  static final SupabaseHelper instance = SupabaseHelper._privateConstructor();
  static SupabaseClient? _client;
  static String? _userId = supabase.auth.currentUser!.id;

  SupabaseHelper._privateConstructor();

  Future<void> addUserAccount(String serviceName, String login, String password) async {
    final response = await supabase
        .from('user_accounts')
        .insert([
      {'user_id': _userId, 'service_name': serviceName, 'login': login, 'password': password}
    ]);

    if (response != null) {
      print('[DEBUG] - Ошибка при добавлении данных: ${response.error!.message}');
    } else {
      print('[DEBUG] - Данные успешно добавлены в таблицу user_accounts');
    }
  }

  Future<List<Map<String, dynamic>>> getUserAccounts() async {
    final response = await supabase.from('user_accounts').select().eq('user_id', _userId!);
    print(_userId);
    return response;
  }

  Future<void> updateUserAccount(int id, String serviceName, String login, String password) async {
    final response = await supabase
        .from('user_accounts')
        .update({'service_name': serviceName, 'login': login, 'password': password})
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

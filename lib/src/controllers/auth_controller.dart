import 'package:kitokopay/src/customs/network.dart';

class AuthController {
   final _networkUtil = NetworkUtil();


  // this is a sample request to be used in accessing apis
  /*
   Another variation
    Future<User> register(String name,String email,String password)async{
    final  response = _networkUtil.postReq(
        'auth/register',
        body: user,
      );
      User user = User.fromNetwork(response);
      return user;
    }
   */

   Future register(String name,String email,String password)async{
    try {
      final  response = _networkUtil.postReq(
        'auth/register',
        body: {
          'name':name,
          'email':email,
          'password':password,
        },
      );
    } catch (e) {
      // you can handle errors here
      rethrow;
    }

   }

}
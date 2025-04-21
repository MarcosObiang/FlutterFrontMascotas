import 'package:mascotas_citas/Modules/CreateUserModule/model/CreateUserModel.dart';
import 'package:mascotas_citas/services/ApiService.dart';

abstract class CreateUserRepo {
  Future<bool> createUser(CreateSignUpModel model);
}

class CreateUserRepoImpl implements CreateUserRepo {
  final ApiService apiService;

  CreateUserRepoImpl({required this.apiService});

  @override
  Future<bool> createUser(CreateSignUpModel model) async {
    final result = await apiService.post(
        path: "/orquestador/api/register", data: model.toJson(), files: model.files);
    return true;
  }
}

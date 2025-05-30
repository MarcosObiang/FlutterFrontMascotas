import 'package:get_it/get_it.dart';
import 'package:mascotas_citas/Modules/SocialModule/State/SocialState.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import '../../../services/ApiService.dart';

// Importa tus repositorios
import '../repos/CommentLikesRepository.dart';
import '../repos/CommentRepliesRepository.dart';
import '../repos/CommentsRepository.dart';
import '../repos/LikesRepository.dart';
import '../repos/SocialRepository.dart';

// Importa tus casos de uso
import '../usecases/CheckCommentLikedUseCase.dart';
import '../usecases/CheckLikedUseCase.dart';
import '../usecases/CreateCommentLikeUseCase.dart';
import '../usecases/CreateCommentReplyUseCase.dart';
import '../usecases/CreateCommentUseCase.dart';
import '../usecases/CreateLikeUseCase.dart';
import '../usecases/CreatePostUseCase.dart';
import '../usecases/DeleteCommentLikeUseCase.dart';
import '../usecases/DeleteCommentReplyUseCase.dart';
import '../usecases/DeleteCommentUseCase.dart';
import '../usecases/DeleteLikeUseCase.dart';
import '../usecases/DeletePostUseCase.dart';
import '../usecases/GetAllPostUseCase.dart';
import '../usecases/GetCommentsByPostUseCase.dart';
import '../usecases/GetRepliesByCommentUseCase.dart';
import '../usecases/UpdateCommentReplyUseCase.dart';
import '../usecases/UpdateCommentUseCase.dart';
import '../usecases/UpdatePostUseCase.dart';



void setUpSocialDependencies() {

  getIt.registerSingleton<SocialState>(SocialState());

  // Registra los repositorios primero
  getIt.registerLazySingleton<CommentLikesRepository>(
    () => CommentLikesRepositoryImpl(dioApiService: getIt<DioApiService>()),
  );
  getIt.registerLazySingleton<CommentRepliesRepository>(
    () => CommentRepliesRepositoryImpl(dioApiService: getIt<DioApiService>()),
  );
  getIt.registerLazySingleton<CommentsRepository>(
    () => CommentsRepositoryImpl(dioApiService: getIt<DioApiService>()),
  );
  getIt.registerLazySingleton<LikesRepository>(
    () => LikesRepositoryImpl(dioApiService: getIt<DioApiService>()),
  );
  getIt.registerLazySingleton<SocialRepository>(
    () => SocialRepositoryImpl(dioApiService: getIt<DioApiService>()),
  );

  // Registra los casos de uso con sus dependencias
  getIt.registerLazySingleton<CheckCommentLikedUseCase>(
    () => CheckCommentLikedUseCase(
      commentLikesRepository: getIt<CommentLikesRepository>(),
    ),
  );
  getIt.registerLazySingleton<CheckLikedUseCase>(
    () => CheckLikedUseCase(
      likesRepository: getIt<LikesRepository>(),
    ),
  );
  getIt.registerLazySingleton<CreateCommentLikeUseCase>(
    () => CreateCommentLikeUseCase(
      commentLikesRepository: getIt<CommentLikesRepository>(),
    ),
  );
  getIt.registerLazySingleton<CreateCommentReplyUseCase>(
    () => CreateCommentReplyUseCase(
      commentRepliesRepository: getIt<CommentRepliesRepository>(),
    ),
  );
  getIt.registerLazySingleton<CreateCommentUseCase>(
    () => CreateCommentUseCase(
      commentsRepository: getIt<CommentsRepository>(),
    ),
  );
  getIt.registerLazySingleton<CreateLikeUseCase>(
    () => CreateLikeUseCase(
      likesRepository: getIt<LikesRepository>(),
    ),
  );
  getIt.registerLazySingleton<CreatePostUseCase>(
    () => CreatePostUseCase(
      socialRepository: getIt<SocialRepository>(),
    ),
  );
  getIt.registerLazySingleton<DeleteCommentLikeUseCase>(
    () => DeleteCommentLikeUseCase(
      commentLikesRepository: getIt<CommentLikesRepository>(),
    ),
  );
  getIt.registerLazySingleton<DeleteCommentReplyUseCase>(
    () => DeleteCommentReplyUseCase(
      commentRepliesRepository: getIt<CommentRepliesRepository>(),
    ),
  );
  getIt.registerLazySingleton<DeleteCommentUseCase>(
    () => DeleteCommentUseCase(
      commentsRepository: getIt<CommentsRepository>(),
    ),
  );
  getIt.registerLazySingleton<DeleteLikeUseCase>(
    () => DeleteLikeUseCase(
      likesRepository: getIt<LikesRepository>(),
    ),
  );
  getIt.registerLazySingleton<DeletePostUseCase>(
    () => DeletePostUseCase(
      socialRepository: getIt<SocialRepository>(),
    ),
  );
  getIt.registerLazySingleton<GetAllPostUseCase>(
    () => GetAllPostUseCase(
      socialRepository: getIt<SocialRepository>(),
    ),
  );
  getIt.registerLazySingleton<GetCommentsByPostUseCase>(
    () => GetCommentsByPostUseCase(
      commentsRepository: getIt<CommentsRepository>(),
    ),
  );
  getIt.registerLazySingleton<GetRepliesByCommentUseCase>(
    () => GetRepliesByCommentUseCase(
      commentRepliesRepository: getIt<CommentRepliesRepository>(),
    ),
  );
  getIt.registerLazySingleton<UpdateCommentReplyUseCase>(
    () => UpdateCommentReplyUseCase(
      commentRepliesRepository: getIt<CommentRepliesRepository>(),
    ),
  );
  getIt.registerLazySingleton<UpdateCommentUseCase>(
    () => UpdateCommentUseCase(
      commentsRepository: getIt<CommentsRepository>(),
    ),
  );
  getIt.registerLazySingleton<UpdatePostUseCase>(
    () => UpdatePostUseCase(
      socialRepository: getIt<SocialRepository>(),
    ),
  );
}
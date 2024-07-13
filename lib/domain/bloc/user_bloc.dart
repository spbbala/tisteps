import 'package:demo/data/models/user_details.dart';
import 'package:demo/data/repositotories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user.dart';

// Events
abstract class UserEvent {
  const UserEvent();

}

class FetchUsers extends UserEvent {
  final int page;

  const FetchUsers(this.page);
}


class FetchUserDetails extends UserEvent {

  final User userDetails;

  const FetchUserDetails(this.userDetails);
}

// States
abstract class UserState {
  const UserState();
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  final bool hasReachedMax;

  const UserLoaded({
    required this.users,
    this.hasReachedMax = false,
  });

  UserLoaded copyWith({
    List<User>? users,
    bool? hasReachedMax,
  }) {
    return UserLoaded(
      users: users ?? this.users,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class UserDetailState extends UserState{

  const UserDetailState(this.userDetails);

  final UserDetails userDetails;
}

class UserError extends UserState {}


class ResetUserDetailState extends UserState{}

// Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc({required this.userRepository}) : super(UserInitial());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    final currentState = state;
    if (event is FetchUsers && !_hasReachedMax(currentState)) {
      try {
        if (currentState is UserInitial) {
          final users = await userRepository.getUsers(event.page);
          yield UserLoaded(users: users, hasReachedMax: false);
          return;
        }
        if (currentState is UserLoaded) {
          final users = await userRepository.getUsers(event.page);
          yield users.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : UserLoaded(
            users: currentState.users + users,
            hasReachedMax: false,
          );
        }
      } catch (_) {
        yield UserError();
      }
    } else if(event is FetchUserDetails){
   //   yield UserLoading();

      final dynamic users = await userRepository.getUsersDetails(event.userDetails);
      if(users is UserDetails){
        emit( UserDetailState(users));
      }else{
        yield UserError();
      }


    } else if(currentState is ResetUserDetailState){

    }
  }

  bool _hasReachedMax(UserState state) =>
      state is UserLoaded && state.hasReachedMax;
}

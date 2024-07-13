import 'package:demo/data/models/user_details.dart';
import 'package:demo/data/repositotories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../data/models/user.dart';
import '../../../domain/bloc/user_bloc.dart';
import '../user_detail/user_detail_screen.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.cyan,
          title: const Text(
            'User List',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontFamily: 'SFPro'

            ),
          )),
      body: BlocProvider(
        create: (context) => UserBloc(userRepository: UserRepository()),
        child: const UserList(),
      ),
    );
  }
}

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final PagingController<int, User> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    BlocProvider.of<UserBloc>(context).add(FetchUsers(1));
    _pagingController.addPageRequestListener((pageKey) {
      BlocProvider.of<UserBloc>(context).add(FetchUsers(pageKey));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded) {
          _pagingController.value = PagingState(
            itemList: state.users,
            nextPageKey:
                state.hasReachedMax ? null : state.users.length ~/ 6 + 1,
          );
        } else if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load users', style: TextStyle( fontFamily: 'SFPro', color: Colors.red),)),
          );
        } else if (state is UserDetailState) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UserDetailScreen(user: state.userDetails),
          ));
        }
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserInitial || state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            color: Colors.cyanAccent.withOpacity(0.6),
            child: PagedListView<int, User>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<User>(
                itemBuilder: (context, user, index) {
                  return Card(
                    // color: Colors.cyanAccent.withOpacity(0.8),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          user.avatar,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SFPro',
                            fontSize: 18),
                      ),
                      subtitle: Text(
                        user.email,
                        style:
                            const TextStyle(fontFamily: 'SFPro', fontSize: 14),
                      ),
                      onTap: () {
                        BlocProvider.of<UserBloc>(context)
                            .add(FetchUserDetails(user));
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

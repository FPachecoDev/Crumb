import 'package:crumb/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:crumb/modules/auth/presentation/bloc/auth_event.dart';
import 'package:crumb/modules/home/presentation/bloc/home_event.dart';
import 'package:crumb/modules/home/presentation/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crumb/modules/home/presentation/bloc/home_bloc.dart';
import 'package:crumb/modules/home/domain/entities/crumb_entity.dart';

class HomeScreenPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use o HomeBloc do provider
    final homeBloc = context.read<HomeBloc>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is UserLocationLoaded) {
            // Inicia a busca por crumbs próximos
            homeBloc.add(GetNearbyCrumbsEvent(
              latitude: state.position.latitude,
              longitude: state.position.longitude,
            ));
            return Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Bem-vindo à Home!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.crumbs.length,
                    itemBuilder: (context, index) {
                      CrumbEntity crumb = state.crumbs[index];
                      return ListTile(
                        title: Text(crumb.title), // Exibe o título do crumb
                        subtitle: Text(
                            crumb.description), // Exibe a descrição do crumb
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is HomeError) {
            return Center(child: Text('Erro: ${state.message}'));
          }
          return Center(child: Text('Estado desconhecido'));
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Exemplo de navegação para outra página
              Navigator.pushNamed(context, '/profile');
            },
            child: Icon(Icons.person),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              // Exemplo de logout
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Icon(Icons.exit_to_app),
          ),
        ],
      ),
    );
  }
}

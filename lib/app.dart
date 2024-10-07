import 'package:crumb/features/create/create_page.dart';
import 'package:crumb/features/global/global_page.dart';
import 'package:crumb/features/home/home_page.dart';
import 'package:crumb/features/profile/profile_page.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: PageView(
          controller: _pageController,
          physics:
              const NeverScrollableScrollPhysics(), // Evita arrastar entre páginas
          children: [
            const HomePage(), // Página Home
            CreatePage(), // Página de criação
            GlobalPage(), // Página Global
            ProfilePage(), // Página Perfil
          ],
        ),
        // Exibe o BottomNavigationBar somente se a página atual não for CreatePage
        bottomNavigationBar: _selectedIndex != 1
            ? BottomNavigationBar(
                backgroundColor: Colors.black, // Fundo preto
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed, // Remove animação
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                      color: _selectedIndex == 0
                          ? Colors.white
                          : Colors.grey, // Muda a cor do ícone
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.add_box,
                      color: _selectedIndex == 1
                          ? Colors.white
                          : Colors.grey, // Muda a cor do ícone
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.public,
                      color: _selectedIndex == 2
                          ? Colors.white
                          : Colors.grey, // Muda a cor do ícone
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person,
                      color: _selectedIndex == 3
                          ? Colors.white
                          : Colors.grey, // Muda a cor do ícone
                    ),
                    label: '',
                  ),
                ],
              )
            : null, // Não exibe o BottomNavigationBar na CreatePage
      ),
    );
  }
}

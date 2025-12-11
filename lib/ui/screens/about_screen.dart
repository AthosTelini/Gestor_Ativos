import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Sobre o Projeto'),
        backgroundColor: AppTheme.darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.school_outlined,
                size: 60,
                color: AppTheme.royalBlue,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Gestor de Ativos',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Versão 2.0 (Flutter Edition)',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Este aplicativo foi desenvolvido para a disciplina de Tópicos Especiais em Computação.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'O objetivo deste trabalho foi evoluir um projeto legado, originalmente desenvolvido na disciplina de Desenvolvimento de Dispositivos Móveis (5º período) em Java Nativo.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nesta nova iteração, migramos a tecnologia para Flutter e alteramos o foco do produto: de um simples gerenciador de contas a pagar para um gestor de entrada de ativos (receitas), implementando persistência de dados local e arquitetura MVVM.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            Text(
              'Sobre o Criador:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Athos Telini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.royalBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: 'LinkedIn',
                  icon: const FaIcon(FontAwesomeIcons.linkedin, size: 30, color: Color(0xFF0077B5)),
                  onPressed: () => _launchUrl('https://www.linkedin.com/in/athos-telini-b05b1b240/'),
                ),
                const SizedBox(width: 16),
                IconButton(
                  tooltip: 'GitHub',
                  icon: const FaIcon(FontAwesomeIcons.github, size: 30, color: AppTheme.darkBlue),
                  onPressed: () => _launchUrl('https://github.com/AthosTelini'),
                ),
                const SizedBox(width: 16),
                IconButton(
                  tooltip: 'Instagram',
                  icon: const FaIcon(FontAwesomeIcons.instagram, size: 30, color: Color(0xFFE1306C)),
                  onPressed: () => _launchUrl('https://www.instagram.com/ath6s/'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Desenvolvido com Flutter',
                style: TextStyle(
                  color: AppTheme.darkBlue.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
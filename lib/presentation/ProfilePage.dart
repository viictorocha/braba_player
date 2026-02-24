import 'package:braba_player/presentation/LoginPage.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Header do Perfil
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE0C097),
                        width: 2,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0C097),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Karol Sena",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Aluna Premium",
              style: TextStyle(color: Color(0xFFE0C097), letterSpacing: 1),
            ),
            const SizedBox(height: 30),

            // Cards de Estatísticas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard("12", "Cursos\nIniciados"),
                  const SizedBox(width: 12),
                  _buildStatCard("05", "Certificados\nEmitidos"),
                  const SizedBox(width: 12),
                  _buildStatCard("48h", "Tempo de\nEstudo"),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Lista de Opções - Passando o context para as funções
            _buildOptionTile(context, Icons.person_outline, "Dados Pessoais"),
            _buildOptionTile(
              context,
              Icons.workspace_premium_outlined,
              "Minha Assinatura",
            ),
            _buildOptionTile(
              context,
              Icons.download_for_offline_outlined,
              "Aulas Offline",
            ),
            _buildOptionTile(context, Icons.notifications_none, "Notificações"),
            _buildOptionTile(context, Icons.help_outline, "Suporte e FAQ"),

            const Divider(
              color: Colors.white10,
              height: 40,
              indent: 20,
              endIndent: 20,
            ),

            _buildOptionTile(
              context, // Adicionado context
              Icons.logout,
              "Sair da Conta",
              isDestructive: true,
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE0C097),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, // Adicionei o contexto aqui
    IconData icon,
    String title, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.redAccent : const Color(0xFFE0C097),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : Colors.white,
          fontSize: 15,
        ),
      ),
      trailing: isDestructive
          ? null
          : const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.white24,
            ),
      onTap: () {
        if (isDestructive) {
          // Remove todas as telas e volta para o login (Segurança)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        } else {
          // Outras navegações podem entrar aqui
        }
      },
    );
  }
}

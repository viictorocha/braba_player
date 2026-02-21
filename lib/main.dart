import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

// Imports da sua arquitetura (Certifique-se que os caminhos estão corretos)
import 'domain/repositories/video_player_repository.dart';
import 'domain/repositories/youtube_repository_impl.dart';
import 'presentation/widgets/braba_video_player.dart';

final getIt = GetIt.instance;

void setupDI() {
  if (!getIt.isRegistered<IVideoPlayerRepository>()) {
    getIt.registerLazySingleton<IVideoPlayerRepository>(
      () => YoutubeRepositoryImpl(),
    );
  }
}

void main() {
  setupDI();
  runApp(const BrabaPlayerApp());
}

// --- DADOS MOCKADOS ---
class Course {
  final String id;
  final String title;
  final String author;
  final String image;
  final double progress;
  final String videoId;

  const Course(
    this.id,
    this.title,
    this.author,
    this.image,
    this.progress,
    this.videoId,
  );
}

final List<Course> recentCourses = [
  const Course(
    "1",
    "Flutter Forward: Strategy & Vision",
    "Google Tech",
    "https://images.unsplash.com/photo-1628258334491-904793f1643d?q=80&w=600",
    0.85,
    "un9v_fB6R8A", // Flutter Official - Alta compatibilidade
  ),
  const Course(
    "2",
    "The Art of Minimalist Living",
    "Netflix Design",
    "https://images.unsplash.com/photo-1494438639946-1ebd1d20bf85?q=80&w=600",
    0.45,
    "Ym6fO6V_p7U", // Documentário sobre Design/Minimalismo
  ),
];

final List<Course> categories = [
  const Course(
    "3",
    "UI Design Principles 2024",
    "Design Course",
    "https://images.unsplash.com/photo-1586717791821-3f44a563eb4c?q=80&w=600",
    0.0,
    "TRf2X4nSPlU", // UI Design
  ),
  const Course(
    "4",
    "Building Premium Experiences",
    "Apple Style Guide",
    "https://images.unsplash.com/photo-1460925895917-afdab827c52f?q=80&w=600",
    0.0,
    "f7pZ7pYpZ7p", // Placeholder - Tente esse: "7XGIn_v3pS0"
  ),
];

// --- APP & TEMA ---
class BrabaPlayerApp extends StatelessWidget {
  const BrabaPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Braba Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121214),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE0C097),
          surface: Color(0xFF1C1C1E),
          onSurface: Color(0xFFF5F5F5),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const RootPage(),
    );
  }
}

// --- NAVEGAÇÃO PRINCIPAL ---
class RootPage extends StatefulWidget {
  const RootPage({super.key});
  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text("Busca")),
    const Center(child: Text("Perfil")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        height: 65,
        backgroundColor: const Color(0xFF121214),
        indicatorColor: const Color(0xFFE0C097).withOpacity(0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Explorar'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// --- TELA INICIAL (Corrigida) ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              // Corrigido: era 'child', agora é 'sliver'
              child: SectionTitle(title: "Continue Aprendendo"),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: recentCourses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) => ContinueWatchingCard(
                  course: recentCourses[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CoursePlayerPage(course: recentCourses[index]),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            sliver: SliverToBoxAdapter(
              // Corrigido: era 'child', agora é 'sliver'
              child: SectionTitle(title: "Para sua Carreira"),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              // Corrigido: era 'child', agora é 'sliver'
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    CompactCourseCard(course: categories[index]),
                childCount: categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      sliver: SliverToBoxAdapter(
        // Corrigido: era 'child', agora é 'sliver'
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bem-vinda de volta,",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  "Victoria Rocha",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            _SafeImage(
              url: 'https://i.pravatar.cc/150?img=9',
              radius: 24,
              width: 48,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}

// --- TELA DE PLAYER (SUBSTITUA AS DUAS VERSÕES POR ESTA) ---
class CoursePlayerPage extends StatelessWidget {
  final Course course;
  const CoursePlayerPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header com botão de voltar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Assistindo agora",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // O Player de Vídeo
          BrabaVideoPlayer(videoId: course.videoId),

          // Detalhes do Curso
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF121214),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Com ${course.author}",
                      style: const TextStyle(
                        color: Color(0xFFE0C097),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Conteúdo do Curso",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Lista de aulas fake
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, i) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          i == 0 ? Icons.play_circle_fill : Icons.lock_outline,
                          color: i == 0
                              ? const Color(0xFFE0C097)
                              : Colors.white24,
                        ),
                        title: Text(
                          "Aula 0${i + 1} - Conceitos Fundamentais",
                          style: TextStyle(
                            color: i == 0 ? Colors.white : Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        trailing: const Text(
                          "15:00",
                          style: TextStyle(color: Colors.white24, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// --- UTILS & COMPONENTES VISUAIS ---

class _SafeImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double radius;

  const _SafeImage({
    required this.url,
    this.width,
    this.height,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: Colors.white10,
          child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );
}

class ContinueWatchingCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  const ContinueWatchingCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  _SafeImage(
                    url: course.image,
                    width: double.infinity,
                    height: double.infinity,
                    radius: 16,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: course.progress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFE0C097),
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              course.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class CompactCourseCard extends StatelessWidget {
  final Course course;
  const CompactCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _SafeImage(url: course.image, width: 80, height: 80, radius: 10),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  course.author,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}

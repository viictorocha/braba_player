import 'package:braba_player/domain/repositories/video_repository_impl.dart';
import 'package:braba_player/presentation/ExplorePage.dart';
import 'package:braba_player/presentation/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'domain/repositories/video_player_repository.dart';

final getIt = GetIt.instance;

void setupDI() {
  if (!getIt.isRegistered<IVideoPlayerRepository>()) {
    getIt.registerLazySingleton<IVideoPlayerRepository>(
      () => DirectVideoRepositoryImpl(),
    );
  }
}

void main() {
  setupDI();
  runApp(const BrabaPlayerApp());
}

// --- MODELO DE DADOS ---
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
    "Cinematic Nature",
    "National Geo Style",
    "https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=600",
    0.85,
    "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
  ),
  const Course(
    "2",
    "Abstract Design",
    "Motion Studio",
    "https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=600",
    0.45,
    "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
  ),
];

final List<Course> allCourses = [
  const Course(
    "1",
    "Domínio Emocional",
    "Karol Sena",
    "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=600",
    0,
    "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
  ),
  const Course(
    "2",
    "Liderança Feminina",
    "Bruna Costa",
    "https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=600",
    0,
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
  ),
  const Course(
    "3",
    "Estratégias de Carreira",
    "Clara Mendes",
    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=600",
    0,
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
  ),
  const Course(
    "4",
    "Branding Pessoal",
    "Erika Lima",
    "https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?q=80&w=600",
    0,
    "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
  ),
];

// --- APP PRINCIPAL ---
class BrabaPlayerApp extends StatelessWidget {
  const BrabaPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121214),
        colorScheme: const ColorScheme.dark(primary: Color(0xFFE0C097)),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const RootPage(),
    );
  }
}

// --- WIDGET DO PLAYER AJUSTADO ---
class BrabaVideoPlayer extends StatelessWidget {
  final String videoId;
  const BrabaVideoPlayer({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    // Detecta se a tela está deitada
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AspectRatio(
      // Se estiver deitado, o AspectRatio deve ser o da tela inteira, não 16/9 fixo
      aspectRatio: isLandscape
          ? MediaQuery.of(context).size.aspectRatio
          : 16 / 9,
      child: GetIt.I<IVideoPlayerRepository>().buildPlayer(videoId),
    );
  }
}

// --- HOME PAGE E NAVEGAÇÃO ---
class RootPage extends StatefulWidget {
  const RootPage({super.key});
  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const HomePage(),
        const ExplorePage(),
        const ProfilePage(),
      ][_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Explorar'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header com saudação
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: const Color(0xFF121214),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "BEM-VINDA AO",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "Braba Academy",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE0C097),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
              ),
              const SizedBox(width: 10),
            ],
          ),

          // Seção: Continuar Assistindo (Horizontal)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: _sectionHeader("Continuar assistindo", showSeeAll: false),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: recentCourses.length,
                itemBuilder: (context, index) =>
                    _RecentCourseCard(course: recentCourses[index]),
              ),
            ),
          ),

          // Seção: Catálogo de Cursos (Vertical)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: _sectionHeader("Explorar Formações"),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _CourseListTile(course: allCourses[index]),
                childCount: allCourses.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {bool showSeeAll = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (showSeeAll)
          const Text(
            "Ver tudo",
            style: TextStyle(color: Color(0xFFE0C097), fontSize: 12),
          ),
      ],
    );
  }
}

// --- COMPONENTES AUXILIARES ---

class _RecentCourseCard extends StatelessWidget {
  final Course course;
  const _RecentCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CoursePlayerPage(course: course)),
      ),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(course.image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: course.progress,
                    backgroundColor: Colors.white24,
                    color: const Color(0xFFE0C097),
                    minHeight: 3,
                  ),
                ],
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 40,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseListTile extends StatelessWidget {
  final Course course;
  const _CourseListTile({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CoursePlayerPage(course: course)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                course.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Mentora: ${course.author}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }
}

class CoursePlayerPage extends StatelessWidget {
  final Course course;
  const CoursePlayerPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          GetIt.I<IVideoPlayerRepository>().dispose();
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: isLandscape
            ? BrabaVideoPlayer(
                key: const ValueKey('video_player_shared'),
                videoId: course.videoId,
              )
            : Column(
                children: [
                  SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "Assistindo agora",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  BrabaVideoPlayer(
                    key: const ValueKey('video_player_shared'),
                    videoId: course.videoId,
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFF121214),
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
                          Text(
                            "Com ${course.author}",
                            style: const TextStyle(color: Color(0xFFE0C097)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

import 'package:braba_player/domain/repositories/video_repository_impl.dart';
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
        const Center(child: Text("Busca")),
        const Center(child: Text("Perfil")),
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
          SliverToBoxAdapter(child: const SizedBox(height: 60)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bem-vinda de volta,",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Text(
                    "Karol Sena",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                scrollDirection: Axis.horizontal,
                itemCount: recentCourses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CoursePlayerPage(course: recentCourses[index]),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            recentCourses[index].image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        recentCourses[index].title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TELA DE PLAYER REVISADA ---
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

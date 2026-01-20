import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.brown),
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(title: const Text('Knight\'s Path')),
        body: const Center(child: ChessBoard()),
      ),
    );
  }
}

class ChessBoard extends StatelessWidget {
  const ChessBoard({super.key});

  @override
  Widget build(BuildContext context) {
    // ekran boyutunu al

    final size = MediaQuery.of(context).size;
    final double boardWidth = size.width < size.height
        ? size.width
        : size.height;

    return Container(
      width: boardWidth * 0.9,
      height: boardWidth * 0.9,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(2, 2)),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 64,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemBuilder: (context, index) {
          int x = index ~/ 8;
          int y = index % 8;
          bool isLight = (x + y) % 2 == 0;
          List<String> columns = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

          // taslari yerlestir
          Widget? tasIcon;

          // beyazlar
          if (x == 7 && y == 4) {
            tasIcon = SvgPicture.asset('assets/images/beyaz_sah.svg');
          } else if (x == 7 && y == 6) {
            tasIcon = SvgPicture.asset('assets/images/beyaz_at.svg');
          }
          // siyahlar
          else if (x == 0 && y == 4) {
            tasIcon = SvgPicture.asset('assets/images/siyah_sah.svg');
          } else if (x == 0 && y == 6) {
            tasIcon = SvgPicture.asset('assets/images/siyah_at.svg');
          }

          // kenar koordinatlari

          Widget? sayiText;
          if (y == 0) {
            sayiText = Positioned(
              left: 2,
              top: 2,
              child: Text(
                "${8 - x}",
                style: TextStyle(
                  color: isLight ? Colors.brown : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            );
          }

          Widget? harfText;
          if (x == 7) {
            harfText = Positioned(
              right: 2,
              bottom: 2,
              child: Text(
                columns[y],
                style: TextStyle(
                  color: isLight ? Colors.brown : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            );
          }

          // 3. kare
          return Container(
            color: isLight ? const Color(0xFFF0D9B5) : const Color(0xFFB58863),
            child: Stack(
              children: [
                // Koordinatlari ekle (sadece kenarlardaysa gorunur)
                if (sayiText != null) sayiText,
                if (harfText != null) harfText,

                // Tasi ekle (eger varsa)
                if (tasIcon != null)
                  Center(
                    child: SizedBox(
                      width: size.width * 0.08,
                      height: size.width * 0.08,
                      child: tasIcon,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

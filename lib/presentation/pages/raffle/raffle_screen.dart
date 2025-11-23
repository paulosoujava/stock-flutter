// presentation/pages/live/sale/widget/raffle_screen.dart
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RaffleScreen extends StatefulWidget {
  final List<Map<String, dynamic>> buyers;

  const RaffleScreen({super.key, required this.buyers});

  @override
  State<RaffleScreen> createState() => _RaffleScreenState();
}

class _RaffleScreenState extends State<RaffleScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  String? winner;
  int countdown = 0;
  bool isCounting = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startRaffle() {
    if (isCounting || widget.buyers.isEmpty) return;

    setState(() {
      winner = null;
      isCounting = true;
      countdown = 5;
    });

    int current = 5;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        current--;
        countdown = current;
      });

      if (current <= 0) {
        final randomWinner = (widget.buyers..shuffle()).first;
        setState(() => winner = randomWinner['name']);
        _confettiController.play();
        _pulseController.repeat(reverse: true);
        return false;
      }
      return true;
    });
  }

  void _resetRaffle() {
    setState(() {
      winner = null;
      isCounting = false;
      countdown = 0;
    });
    _pulseController.stop();
    _confettiController.stop();
  }

  @override
  Widget build(BuildContext context) {
    final hasBuyers = widget.buyers.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      body: Stack(
        children: [
          // Confetti
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.amber, Colors.pink, Colors.cyan, Colors.green, Colors.orange, Colors.purple],
            numberOfParticles: 180,
            gravity: 0.15,
          ),

          // Botão fechar (X)
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
            child: Column(
              children: [
                // Título
                Text(
                  'SORTEIO DE BRINDE!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    letterSpacing: 2,
                    shadows: [Shadow(color: Colors.amber.withOpacity(0.9), blurRadius: 25)],
                  ),
                ),
                const SizedBox(height: 20),

                // Contagem regressiva
                if (isCounting && countdown > 0)
                  Expanded(
                    child: Center(
                      child: Text(
                        '$countdown',
                        style: GoogleFonts.poppins(
                          fontSize: 160,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.white.withOpacity(0.6), blurRadius: 30)],
                        ),
                      ),
                    ),
                  ),

                // GANHADOR (agora sem overflow nenhum!)
                if (winner != null)
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                            CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
                          ),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 380),
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.amber, Colors.orangeAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(36),
                              boxShadow: [
                                BoxShadow(color: Colors.amber.withOpacity(0.9), blurRadius: 40, spreadRadius: 10),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.emoji_events, size: 80, color: Colors.white),
                                const SizedBox(height: 16),
                                Text(
                                  'GANHADOR(A)!',
                                  style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  winner!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Botão SORTEAR NOVAMENTE (só aparece depois do sorteio)
                if (winner != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton.icon(
                      onPressed: _resetRaffle,
                      icon: const Icon(Icons.refresh, size: 32),
                      label: Text(
                        'SORTEAR NOVAMENTE',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple.shade900,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                        elevation: 12,
                      ),
                    ),
                  ),

                // Lista de participantes (8 colunas = super compacta)
                if (!isCounting || countdown == 0)
                  Expanded(
                    flex: winner != null ? 1 : 2,
                    child: Column(
                      children: [
                        Text(
                          '${widget.buyers.length} participantes',
                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(6),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 8,        // 8 colunas = ultra compacto
                                childAspectRatio: 2.4,     // cards fininhos e elegantes
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: widget.buyers.length,
                              itemBuilder: (_, i) {
                                final name = widget.buyers[i]['name'] as String;
                                final initials = name.isNotEmpty
                                    ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                                    : '?';

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(radius: 11, backgroundColor: Colors.amber, child: Text(initials, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          name,
                                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Botão INICIAR SORTEIO (só aparece quando ainda não sorteou)
                if (winner == null && hasBuyers)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton.icon(
                      onPressed: _startRaffle,
                      icon: const Icon(Icons.card_giftcard, size: 38),
                      label: const Text('INICIAR SORTEIO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.deepPurple.shade900,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 22),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        elevation: 20,
                      ),
                    ),
                  ),

                if (!hasBuyers)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text('Nenhum comprador ainda.\nAdicione pedidos para sortear!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 18)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const GDPRPrivacyApp());
}

class GDPRPrivacyApp extends StatelessWidget {
  const GDPRPrivacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrivacyEraser GDPR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFF020617),
        textTheme:
            GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
      ),
      home: const DashboardScreen(),
    );
  }
}

class AccountService {
  final String id;
  final String name;
  final String category;
  final String emailDetected;
  final String? privacyEmail;
  final String? directUnsubscribeUrl;
  final String iconLetter;
  final Color brandColor;
  bool isDeleted;
  bool isPending;

  AccountService({
    required this.id,
    required this.name,
    required this.category,
    required this.emailDetected,
    this.privacyEmail,
    this.directUnsubscribeUrl,
    required this.iconLetter,
    required this.brandColor,
    this.isDeleted = false,
    this.isPending = false,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isScanning = false;
  bool _hasScanned = false;
  double _scanProgress = 0.0;
  String _scanStatusText = '';

  final TextEditingController _emailController =
      TextEditingController(text: 'utente@gmail.com');

  // ATTENZIONE: dati di esempio (modalità demo). Gli indirizzi privacy
  // vanno verificati prima di un uso reale.
  final List<AccountService> _services = [
    AccountService(
      id: '1',
      name: 'Spotify',
      category: 'Musica & Streaming',
      emailDetected: 'privacy@spotify.com',
      privacyEmail: 'privacy@spotify.com',
      directUnsubscribeUrl: 'https://www.spotify.com/account/privacy/',
      iconLetter: 'S',
      brandColor: const Color(0xFF1DB954),
    ),
    AccountService(
      id: '2',
      name: 'Amazon',
      category: 'E-commerce',
      emailDetected: 'no-reply@amazon.it',
      privacyEmail: 'cis@amazon.com',
      directUnsubscribeUrl:
          'https://www.amazon.it/gp/help/customer/display.html?nodeId=GX7NJ2S3A2DY33AH',
      iconLetter: 'A',
      brandColor: const Color(0xFFFF9900),
    ),
    AccountService(
      id: '3',
      name: 'Adobe Creative Cloud',
      category: 'Software',
      emailDetected: 'message@adobe.com',
      privacyEmail: 'dpo@adobe.com',
      directUnsubscribeUrl: 'https://account.adobe.com/privacy',
      iconLetter: 'A',
      brandColor: const Color(0xFFED2224),
    ),
    AccountService(
      id: '4',
      name: 'Newsletter Tech Weekly',
      category: 'Newsletter / Marketing',
      emailDetected: 'news@techweekly.io',
      privacyEmail: 'unsubscribe@techweekly.io',
      directUnsubscribeUrl: 'https://techweekly.io/unsubscribe?id=92812',
      iconLetter: 'T',
      brandColor: const Color(0xFF3B82F6),
    ),
    AccountService(
      id: '5',
      name: 'Vecchio Forum Videogiochi',
      category: 'Forum & Community',
      emailDetected: 'admin@retrogamingforum.net',
      privacyEmail: 'privacy@retrogamingforum.net',
      iconLetter: 'F',
      brandColor: const Color(0xFF8B5CF6),
    ),
  ];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _snack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _hasScanned = false;
      _scanProgress = 0.0;
      _scanStatusText = 'Preparazione scansione (demo)...';
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _scanProgress = 0.4;
      _scanStatusText = 'Caricamento servizi di esempio...';
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _scanProgress = 0.8;
      _scanStatusText = 'Associazione contatti privacy...';
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _scanProgress = 1.0;
      _isScanning = false;
      _hasScanned = true;
    });
  }

  String _buildSubject(String userEmail) =>
      'Richiesta di cancellazione dati personali (GDPR Art. 17) - $userEmail';

  String _buildBody(AccountService service, String userEmail) {
    return '''Gentile Assistenza / DPO di ${service.name},

con la presente esercito il diritto alla cancellazione ("diritto all'oblio") ai sensi dell'art. 17 del Regolamento (UE) 2016/679 (GDPR).

Chiedo la cancellazione completa e definitiva di:
1. L'account associato all'indirizzo e-mail: $userEmail
2. Tutti i dati personali che mi riguardano, inclusi profili, dati di tracciamento e storico.

Vi chiedo inoltre di:
- comunicare la cancellazione ad eventuali terzi cui i dati sono stati trasmessi (artt. 17.2 e 19 GDPR);
- darmi riscontro entro un mese dal ricevimento della presente (art. 12.3 GDPR).

Per identificarmi potete usare l'indirizzo e-mail da cui scrivo. Restano ferme le mie facoltà di rivolgermi al Garante per la protezione dei dati personali.

Distinti saluti''';
  }

  Uri _buildMailto(String to, String subject, String body) {
    // Codifica con %20 (e non '+') per evitare spazi errati nei client mail.
    return Uri.parse(
      'mailto:$to?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
  }

  Future<void> _sendGDPRRequest(AccountService service) async {
    final String userEmail = _emailController.text.trim();
    if (userEmail.isEmpty || !userEmail.contains('@')) {
      _snack('Inserisci un indirizzo e-mail valido.', color: Colors.red);
      return;
    }

    final String targetEmail = service.privacyEmail ?? service.emailDetected;
    final String subject = _buildSubject(userEmail);
    final String body = _buildBody(service, userEmail);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: Text('Richiesta a ${service.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('A: $targetEmail',
                  style: const TextStyle(color: Color(0xFF94A3B8))),
              const SizedBox(height: 4),
              const Text(
                'Verifica che l\'indirizzo sia quello corretto del titolare del trattamento.',
                style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(body, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apri e-mail'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    bool launched = false;
    try {
      launched = await launchUrl(_buildMailto(targetEmail, subject, body));
    } catch (_) {
      launched = false;
    }

    if (!mounted) return;
    if (launched) {
      setState(() => service.isPending = true);
      _snack(
        'E-mail preparata per ${service.name}. Ricorda di inviarla!',
        color: Colors.green,
      );
    } else {
      _snack(
        'Nessuna app e-mail disponibile su questo dispositivo.',
        color: Colors.red,
      );
    }
  }

  Future<void> _openDirectUnsubscribe(AccountService service) async {
    final String? raw = service.directUnsubscribeUrl;
    if (raw == null) return;
    bool ok = false;
    try {
      ok = await launchUrl(Uri.parse(raw),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok) _snack('Impossibile aprire il link.', color: Colors.red);
  }

  void _markCompleted(AccountService service) {
    setState(() {
      service.isPending = false;
      service.isDeleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int activeAccounts = _services.where((s) => !s.isDeleted).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.shield_outlined, color: Color(0xFF818CF8)),
            ),
            const SizedBox(width: 12),
            const Text(
              'PrivacyEraser GDPR',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Modalità demo: i servizi mostrati sono esempi e non vengono letti dalla tua casella e-mail.',
                      style: TextStyle(color: Color(0xFFFCD34D), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scansione Impronta Digitale',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Inserisci la tua e-mail: verrà usata nelle richieste di cancellazione.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Color(0xFF818CF8)),
                      labelText: 'Indirizzo E-mail',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : _startScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isScanning
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.search_rounded),
                      label: Text(
                        _isScanning
                            ? 'Scansione in corso...'
                            : 'Avvia Scansione (demo)',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (_isScanning) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _scanProgress,
                      backgroundColor: const Color(0xFF1E293B),
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _scanStatusText,
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_hasScanned) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Servizi Trovati',
                      '${_services.length}',
                      Icons.account_tree_outlined,
                      const Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Da Gestire',
                      '$activeAccounts',
                      Icons.delete_sweep_outlined,
                      const Color(0xFFF43F5E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Servizi e Iscrizioni Rilevate',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    '$activeAccounts attivi',
                    style:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _services.length,
                itemBuilder: (context, index) =>
                    _buildServiceCard(_services[index]),
              ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: [
                      Icon(Icons.radar_rounded,
                          size: 60, color: Color(0xFF334155)),
                      SizedBox(height: 12),
                      Text(
                        'Nessuna scansione effettuata.',
                        style:
                            TextStyle(color: Color(0xFF64748B), fontSize: 15),
                      ),
                      Text(
                        'Premi "Avvia Scansione" per vedere la demo.',
                        style:
                            TextStyle(color: Color(0xFF475569), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(title,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11)),
    );
  }

  Widget _buildServiceCard(AccountService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: service.isDeleted
            ? const Color(0xFF0F172A).withValues(alpha: 0.5)
            : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: service.isPending
              ? const Color(0xFFF59E0B)
              : const Color(0xFF1E293B),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: service.brandColor.withValues(alpha: 0.2),
                radius: 22,
                child: Text(
                  service.iconLetter,
                  style: TextStyle(
                      color: service.brandColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: service.isDeleted ? Colors.grey : Colors.white,
                        decoration: service.isDeleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      '${service.category} • ${service.emailDetected}',
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (service.isPending)
                _buildBadge('Da confermare', const Color(0xFFF59E0B)),
              if (service.isDeleted)
                _buildBadge('Eliminato', const Color(0xFF22C55E)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (service.directUnsubscribeUrl != null) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openDirectUnsubscribe(service),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF38BDF8),
                      side: const BorderSide(color: Color(0xFF0284C7)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Unsubscribe Web',
                        style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: service.isDeleted
                      ? null
                      : () => _sendGDPRRequest(service),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.mark_email_read_outlined, size: 16),
                  label: const Text('Elimina (GDPR)',
                      style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          if (service.isPending) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _markCompleted(service),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Cancellazione confermata dal servizio',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../themes/app_themes.dart';
import 'manual_entry_screen.dart';

class VoiceNoteScreen extends StatefulWidget {
  const VoiceNoteScreen({super.key});

  @override
  State<VoiceNoteScreen> createState() => _VoiceNoteScreenState();
}

class _VoiceNoteScreenState extends State<VoiceNoteScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Tekan mikrofon dan mulailah bicara...';

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        setState(() => _text = 'Izin mikrofon ditolak.');
        return;
      }

      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() {
              _isListening = false;
              _pulseCtrl.stop();
            });
            _processVoiceCommand();
          }
        },
        onError: (val) => print('onError: $val'),
      );

      if (available) {
        setState(() {
          _isListening = true;
          _text = 'Mendengarkan...';
        });
        _pulseCtrl.repeat(reverse: true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _pulseCtrl.stop();
      });
      _speech.stop();
      _processVoiceCommand();
    }
  }

  void _processVoiceCommand() {
    if (_text.isEmpty || _text == 'Mendengarkan...' || _text.contains('mikrofon')) {
      return;
    }

    // Very basic parsing for demo: "Makan 50000"
    String lowerText = _text.toLowerCase();
    
    // Find numbers in text
    final numReg = RegExp(r'\d[\d\.\,]*');
    final match = numReg.firstMatch(lowerText);
    
    double? amount;
    String title = _text;
    bool isExpense = true; // default

    if (lowerText.contains('gaji') || lowerText.contains('dapat')) {
      isExpense = false;
    }

    if (match != null) {
      String numStr = match.group(0)!.replaceAll('.', '').replaceAll(',', '');
      amount = double.tryParse(numStr);
      // If user says "50 ribu", we might need to multiply, but for demo let's assume they say exact or we leave it.
      if (lowerText.contains('ribu') && amount != null && amount < 1000) {
        amount *= 1000;
      }
      
      title = _text.substring(0, match.start).trim();
      if (title.isEmpty) title = 'Transaksi Suara';
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ManualEntryScreen(
          initialTitle: title,
          initialAmount: amount,
          isExpense: isExpense,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Catat dengan Suara',
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Contoh: "Makan siang 50 ribu"',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: isDark ? AppTheme.textDarkSecondary : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 60),
              
              // Microphone Button
              GestureDetector(
                onTap: _listen,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, child) {
                    return Container(
                      width: 120 + (_pulseCtrl.value * 20),
                      height: 120 + (_pulseCtrl.value * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? const Color(0xFFEF4444).withOpacity(0.2)
                            : const Color(0xFF2563EB).withOpacity(0.1),
                        border: Border.all(
                          color: _isListening
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF2563EB),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          size: 50,
                          color: _isListening
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF2563EB),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 60),
              Text(
                _text,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.textDarkPrimary : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

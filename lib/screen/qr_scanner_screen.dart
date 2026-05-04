import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../themes/app_themes.dart';
import 'manual_entry_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isScanned = false;
  bool _flashOn = false;
  late AnimationController _scanLineCtrl;
  late Animation<double> _scanLineAnim;

  @override
  void initState() {
    super.initState();
    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    _scanLineCtrl.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    ctrl.scannedDataStream.listen((scanData) {
      if (!_isScanned && scanData.code != null && scanData.code!.isNotEmpty) {
        setState(() => _isScanned = true);
        ctrl.pauseCamera();
        _showScanResult(scanData.code!);
      }
    });
  }

  void _showScanResult(String code) {
    // Attempt to parse QR code as a receipt
    // In a real app this would use OCR or a standardized receipt QR format
    // Here we'll simulate parsing:
    double amount = 50000;
    String title = "Struk Belanja";

    if (code.startsWith('PAY:')) {
      final parts = code.split(':');
      if (parts.length >= 2) title = parts[1];
      if (parts.length >= 3) amount = double.tryParse(parts[2]) ?? 50000;
    } else {
      title = code;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ManualEntryScreen(
          initialTitle: title,
          initialAmount: amount,
          isExpense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: AppTheme.primaryAccent,
              borderRadius: 20,
              borderLength: 36,
              borderWidth: 4,
              cutOutSize: MediaQuery.of(context).size.width * 0.72,
              cutOutBottomOffset: 40,
            ),
          ),

          // Scan line animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _scanLineAnim,
              builder: (context, _) {
                final scanBoxSize = MediaQuery.of(context).size.width * 0.72;
                final top = (MediaQuery.of(context).size.height / 2) -
                    (scanBoxSize / 2) +
                    40 +
                    (_scanLineAnim.value * (scanBoxSize - 4));
                return Positioned(
                  top: top,
                  left: (MediaQuery.of(context).size.width - scanBoxSize) / 2,
                  child: Container(
                    width: scanBoxSize,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryAccent.withOpacity(0.8),
                          AppTheme.primaryAccent,
                          AppTheme.primaryAccent.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  Text(
                    'Scan QR Code',
                    style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  // Flash toggle
                  GestureDetector(
                    onTap: () async {
                      await controller?.toggleFlash();
                      setState(() => _flashOn = !_flashOn);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _flashOn
                            ? AppTheme.primaryAccent
                            : Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _flashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom instruction
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_scanner_rounded,
                            color: Colors.white.withOpacity(0.8), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Arahkan kamera ke QR Code',
                          style: GoogleFonts.dmSans(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Batalkan',
                          style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


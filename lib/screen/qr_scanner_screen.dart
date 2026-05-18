import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/app_themes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'manual_entry_screen.dart';
import 'scan_result_screen.dart';
import 'dart:io' show Platform;

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      // 1. Check Permissions
      var status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
      }
      
      if (status.isPermanentlyDenied || status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin kamera diperlukan untuk fitur ini.')),
          );
        }
        return;
      }

      // 2. Check Platform
      if (!Platform.isAndroid && !Platform.isIOS) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur scan struk hanya tersedia di Android dan iOS.')),
          );
        }
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final firstCamera = cameras.first;
      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high, // 'high' is more stable for OCR across most devices
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      
      // Get zoom levels
      _minAvailableZoom = await _cameraController!.getMinZoomLevel();
      _maxAvailableZoom = await _cameraController!.getMaxZoomLevel();
      
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint("Kamera error: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _captureAndScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      // Ensure the camera is ready and stable
      if (_cameraController!.value.isTakingPicture) return;
      
      final XFile imageFile = await _cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada teks yang terdeteksi. Pastikan gambar jelas.')),
          );
        }
      }
      
      _parseReceiptText(recognizedText);

    } catch (e) {
      debugPrint("Gagal scan error: $e");
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gagal Membaca Struk'),
            content: Text(
              'Terjadi kesalahan saat memproses gambar.\n\nDetail: ${e.toString()}\n\nPastikan struk berada di tempat yang terang dan teks terlihat jelas.',
              style: GoogleFonts.inter(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _pickFromGallery();
                },
                child: const Text('Coba dari Galeri'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    // 1. Platform check
    if (!Platform.isAndroid && !Platform.isIOS) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur galeri hanya tersedia di Android dan iOS.')),
        );
      }
      return;
    }

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isScanning = true);

      final InputImage inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak ada teks yang terdeteksi. Pastikan gambar jelas.')),
          );
        }
      }

      _parseReceiptText(recognizedText);
    } catch (e) {
      debugPrint("Gallery scan error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses gambar: ${e.toString().contains('Tidak ada teks') ? 'Teks tidak terbaca' : 'Coba gambar lain'}'),
            backgroundColor: AppTheme.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _parseReceiptText(RecognizedText recognizedText) {
    debugPrint("=== MEMULAI PEMETAAN VISUAL OCR ===");

    // 1. REKONSTRUKSI VISUAL (Menggabungkan kata yang sejajar secara horizontal)
    List<TextLine> allLines = [];
    for (var block in recognizedText.blocks) {
      for (var line in block.lines) {
        allLines.add(line);
      }
    }

    if (allLines.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada teks yang dapat diproses.')),
        );
      }
      return;
    }

    // Urutkan dari atas ke bawah (berdasarkan koordinat Y)
    allLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    // Kelompokkan kata-kata yang sejajar ke dalam baris yang sama
    List<List<TextLine>> visualRows = [];
    for (var line in allLines) {
      if (visualRows.isEmpty) {
        visualRows.add([line]);
      } else {
        var lastRow = visualRows.last;
        double lastRowAvgY = lastRow.map((l) => l.boundingBox.top).reduce((a, b) => a + b) / lastRow.length;
        
        // Toleransi sejajar, ambil setengah dari tinggi font
        double threshold = line.boundingBox.height / 2;
        if (threshold < 10) threshold = 10;
        
        if ((line.boundingBox.top - lastRowAvgY).abs() < threshold) {
          lastRow.add(line);
        } else {
          visualRows.add([line]);
        }
      }
    }

    // Urutkan kata dari kiri ke kanan (berdasarkan koordinat X) dalam setiap baris
    for (var row in visualRows) {
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
    }

    // Gabungkan menjadi teks baris demi baris
    List<String> lines = visualRows.map((row) {
      return row.map((l) => l.text).join(' ').trim();
    }).toList();

    debugPrint("=== TEKS REKONSTRUKSI VISUAL ===");
    for (var l in lines) {
      debugPrint(l);
    }
    debugPrint("=================================");
    
    double finalAmount = 0.0;
    String title = "Struk Belanja";

    // 1. HIGH-PRECISION MERCHANT NAME EXTRACTION
    if (lines.isNotEmpty) {
      // Ignore lines that are definitely NOT merchant names
      final ignoreKeywords = [
        'jl.', 'jalan', 'telp', '08', 'date', 'tanggal', 'npwp', 'receipt', 'faktur', 
        'inv', 'no.', 'order', 'table', 'kasir', 'cashier', 'server', 'check', 'pajak', 
        'tax', 'time', 'jam', 'pindah', 'meja', 'antrian', 'qris', 'merchant'
      ];

      for (var i = 0; i < lines.length && i < 15; i++) {
        final line = lines[i].trim();
        final lower = line.toLowerCase();
        
        bool isAddressLine = lower.contains('jl.') || 
                             lower.contains('jalan ') || 
                             lower.contains('jakarta') ||
                             lower.contains('raya') ||
                             (lower.contains(',') && line.length > 15);

        bool shouldIgnore = ignoreKeywords.any((k) => lower.contains(k)) || 
                           lower.contains(':') || 
                           lower.contains('=') ||
                           line.length <= 3 ||
                           RegExp(r'^\d+$').hasMatch(line) || // only numbers
                           RegExp(r'\d{2,}[./-]\d{2,}').hasMatch(line) || // dates
                           RegExp(r'\d{2,}:\d{2,}').hasMatch(line) || // times
                           isAddressLine;

        if (!shouldIgnore) {
          title = line;
          
          // Optionally, grab the next line if it's short and doesn't look like another field
          // For example, combining "Meatsmith" and "Steakhouse"
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1].trim();
            final nextLower = nextLine.toLowerCase();
            bool nextIgnore = ignoreKeywords.any((k) => nextLower.contains(k)) || 
                              nextLine.contains(':') || 
                              nextLine.contains('=') ||
                              nextLine.length > 25 ||
                              RegExp(r'\d').hasMatch(nextLine) ||
                              nextLine.contains(',') ||
                              nextLower.contains('jl.') ||
                              nextLower.contains('jalan');
            if (!nextIgnore && nextLine.isNotEmpty) {
              title += " $nextLine";
            }
          }
          
          break; // Stop immediately at the first valid line
        }
      }
    }

    // 2. HIGH-PRECISION TOTAL EXTRACTION (WITH RANKING)
    final highPriorityKeywords = ['grand total', 'total bayar', 'tagihan', 'total belanja', 'nett', 'payable', 'amount due'];
    final mediumPriorityKeywords = ['total', 'jumlah', 'amount', 'tunai', 'cash'];
    final lowPriorityKeywords = ['subtotal', 'sub total', 'item'];

    int bestRank = -1; // -1: none, 0: low, 1: med, 2: high

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      int currentRank = -1;
      
      if (highPriorityKeywords.any((k) => line.contains(k))) {
        currentRank = 2;
      } else if (mediumPriorityKeywords.any((k) => line.contains(k))) {
        // Double check it's not a subtotal
        if (!line.contains('sub')) currentRank = 1;
      } else if (lowPriorityKeywords.any((k) => line.contains(k))) {
        currentRank = 0;
      }

      if (currentRank >= bestRank && currentRank != -1) {
        // Try to find a number in this line
        double? val = _extractPrice(line);
        
        // If not on same line, look up to 3 lines below
        if (val == null || val < 100) {
          for (int j = 1; j <= 3; j++) {
            if (i + j < lines.length) {
              val = _extractPrice(lines[i + j]);
              if (val != null && val > 100) break;
            }
          }
        }

        if (val != null && val > 100) {
          // If we found a better rank or a larger value for the same rank
          if (currentRank > bestRank || val > finalAmount) {
            finalAmount = val;
            bestRank = currentRank;
          }
        }
      }
    }

    // 3. Fallback: Take largest number with strict filters
    if (finalAmount == 0.0) {
      double maxNum = 0.0;
      for (var line in lines) {
        final val = _extractPrice(line);
        if (val != null) {
          bool isYear = val >= 2020 && val <= 2030;
          bool isTooLarge = val > 50000000; // Filter out very long numbers
          bool isDatePattern = RegExp(r'\b\d{2}[./-]\d{2}[./-]\d{2,4}\b').hasMatch(line);
          bool isTimePattern = RegExp(r'\b\d{1,2}:\d{2}\b').hasMatch(line);

          if (!isYear && !isTooLarge && !isDatePattern && !isTimePattern && val > maxNum) {
            maxNum = val;
          }
        }
      }
      finalAmount = maxNum;
    }

    if (finalAmount == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal tidak terdeteksi otomatis. Silakan isi manual.'),
          backgroundColor: AppTheme.expense,
        ),
      );
    }

    // Navigasi ke layar review hasil scan
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScanResultScreen(
          scannedTitle: title,
          scannedAmount: finalAmount,
          rawText: recognizedText.text,
        ),
      ),
    );
  }

  double? _extractPrice(String input) {
    // 1. SAFE PRE-CLEANING
    // Hapus kata-kata kunci struk agar saat hurufnya di-replace jadi angka (misal 't0tal')
    // tidak menempel dengan angka aslinya (misal 't0ta13.000.000' dari 'total 3.000.000').
    String clean = input.toLowerCase()
        .replaceAll(RegExp(r'total|subtotal|jumlah|tagihan|tunai|cash|bayar|kembali|tax|pajak|nett|rp|idr'), ' ')
        .replaceAll(':', ' ')
        .replaceAll('=', ' ');
    
    // 2. CHARACTER CORRECTION
    // Ganti huruf yang mirip angka karena salah baca OCR
    clean = clean
        .replaceAll('s', '5')
        .replaceAll('o', '0')
        .replaceAll('i', '1')
        .replaceAll('l', '1')
        .replaceAll(' ', ''); // Hapus semua spasi HANYA setelah filter kata aman
    
    // 3. REGEX FOR VARIOUS PRICE FORMATS
    final priceRegex = RegExp(r'\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?|\b\d{4,}\b');
    final matches = priceRegex.allMatches(clean);
    
    double? bestMatch;
    
    for (var match in matches) {
      String m = match.group(0)!;
      String normalized = m;
      
      // Normalize Indonesian/European formats (100.000,00)
      if (m.contains('.') && m.contains(',')) {
        if (m.lastIndexOf('.') < m.lastIndexOf(',')) {
          normalized = m.replaceAll('.', '').replaceAll(',', '.');
        } else {
          normalized = m.replaceAll(',', '').replaceAll('.', '.');
        }
      } else if (m.contains(',')) {
        if (m.split(',').last.length == 3) {
          normalized = m.replaceAll(',', '');
        } else {
          normalized = m.replaceAll(',', '.');
        }
      } else if (m.contains('.')) {
        if (m.split('.').last.length == 3) {
          normalized = m.replaceAll('.', '');
        } else {
          normalized = m;
        }
      }
      
      normalized = normalized.replaceAll(RegExp(r'[^0-9.]'), '');
      final val = double.tryParse(normalized);
      if (val != null) {
        if (bestMatch == null || val > bestMatch) {
          bestMatch = val;
        }
      }
    }
    
    return bestMatch;
  }

  Widget _buildCorners() {
    return Stack(
      children: [
        // Top Left
        Positioned(
          top: 0, left: 0,
          child: _corner(top: true, left: true),
        ),
        // Top Right
        Positioned(
          top: 0, right: 0,
          child: _corner(top: true, left: false),
        ),
        // Bottom Left
        Positioned(
          bottom: 0, left: 0,
          child: _corner(top: false, left: true),
        ),
        // Bottom Right
        Positioned(
          bottom: 0, right: 0,
          child: _corner(top: false, left: false),
        ),
      ],
    );
  }

  Widget _corner({required bool top, required bool left}) {
    const double size = 30;
    const double thickness = 4;
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            left: 0, right: 0,
            child: Container(height: thickness, color: AppTheme.primaryAccent),
          ),
          Positioned(
            left: left ? 0 : null,
            right: left ? null : 0,
            top: 0, bottom: 0,
            child: Container(width: thickness, color: AppTheme.primaryAccent),
          ),
        ],
      ),
    );
  }

  void _onViewfinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (_cameraController == null) return;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _cameraController!.setFocusPoint(offset);
    _cameraController!.setExposurePoint(offset);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = MediaQuery.of(context).size;
                  final screenRatio = size.aspectRatio;
                  double cameraRatio = _cameraController!.value.aspectRatio;
                  
                  // Sesuaikan orientasi aspectRatio kamera dengan layar
                  if ((screenRatio > 1.0 && cameraRatio < 1.0) || 
                      (screenRatio < 1.0 && cameraRatio > 1.0)) {
                    cameraRatio = 1.0 / cameraRatio;
                  }
                  
                  final scale = screenRatio > cameraRatio 
                      ? screenRatio / cameraRatio 
                      : cameraRatio / screenRatio;

                  return ClipRect(
                    child: Transform.scale(
                      scale: scale,
                      child: Center(
                        child: GestureDetector(
                          onTapDown: (details) => _onViewfinderTap(details, constraints),
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: AppTheme.income)),

          // Overlay Gelap dengan lubang
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scanning Box Decoration (Corners & Line)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Stack(
                children: [
                  // Corner Borders
                  _buildCorners(),
                  
                  if (_isScanning)
                    const _ScanningLine(),
                    
                  if (_isScanning)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Pindai Struk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Flash Toggle
                  GestureDetector(
                    onTap: () async {
                      if (_cameraController == null) return;
                      final isFlashOn = _cameraController!.value.flashMode == FlashMode.torch;
                      await _cameraController!.setFlashMode(
                        isFlashOn ? FlashMode.off : FlashMode.torch,
                      );
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _cameraController?.value.flashMode == FlashMode.torch
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: _cameraController?.value.flashMode == FlashMode.torch
                            ? Colors.yellow
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Bar - Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Arahkan struk ke dalam kotak dan tekan tombol',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
                
                // Zoom Slider
                if (_isCameraInitialized)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        const Icon(Icons.zoom_out_rounded, color: Colors.white70, size: 18),
                        Expanded(
                          child: Slider(
                            value: _currentZoomLevel,
                            min: _minAvailableZoom,
                            max: _maxAvailableZoom,
                            activeColor: AppTheme.primaryAccent,
                            onChanged: (value) async {
                              setState(() => _currentZoomLevel = value);
                              await _cameraController!.setZoomLevel(value);
                            },
                          ),
                        ),
                        const Icon(Icons.zoom_in_rounded, color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
                  
                const SizedBox(height: 10),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Gallery Button
                    GestureDetector(
                      onTap: _pickFromGallery,
                      child: Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 32),
                    
                    // Capture Button
                    GestureDetector(
                      onTap: _captureAndScan,
                      child: Container(
                        height: 84,
                        width: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Container(
                            height: 68,
                            width: 68,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryAccent,
                              shape: BoxShape.circle,
                            ),
                            child: _isScanning
                                ? const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 34),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 32),
                    // Placeholder for balance
                    const SizedBox(width: 54),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _ScanningLine extends StatefulWidget {
  const _ScanningLine();

  @override
  State<_ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<_ScanningLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: _controller.value * (MediaQuery.of(context).size.height * 0.5 - 2),
          left: 10,
          right: 10,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryAccent.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryAccent.withOpacity(0.1),
                  AppTheme.primaryAccent,
                  AppTheme.primaryAccent.withOpacity(0.1),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

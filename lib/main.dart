import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CoolingTimerPage(),
    );
  }
}

class CoolingTimerPage extends StatefulWidget {
  const CoolingTimerPage({super.key});

  @override
  State<CoolingTimerPage> createState() => _CoolingTimerPageState();
}

class _CoolingTimerPageState extends State<CoolingTimerPage> {
  // Membuat Controller untuk setiap TextBox (tbx)
  // Waktu Mulai
  final TextEditingController _startHourCtrl = TextEditingController();
  final TextEditingController _startMinCtrl = TextEditingController();
  final TextEditingController _startSecCtrl = TextEditingController();

  // Waktu Selesai
  final TextEditingController _endHourCtrl = TextEditingController();
  final TextEditingController _endMinCtrl = TextEditingController();
  final TextEditingController _endSecCtrl = TextEditingController();

  // Membuat FocusNode untuk mengatur perpindahan kursor
  final FocusNode _startHourNode = FocusNode();
  final FocusNode _startMinNode = FocusNode();
  final FocusNode _startSecNode = FocusNode();
  final FocusNode _endHourNode = FocusNode();
  final FocusNode _endMinNode = FocusNode();
  final FocusNode _endSecNode = FocusNode();

  String _hasilPerhitungan = "Hasil : -";

  @override
  void dispose() {
    // Bersihkan controller dan node saat aplikasi ditutup
    _startHourCtrl.dispose();
    _startMinCtrl.dispose();
    _startSecCtrl.dispose();
    _endHourCtrl.dispose();
    _endMinCtrl.dispose();
    _endSecCtrl.dispose();
    _startHourNode.dispose();
    _startMinNode.dispose();
    _startSecNode.dispose();
    _endHourNode.dispose();
    _endMinNode.dispose();
    _endSecNode.dispose();
    super.dispose();
  }

  // Fungsi untuk menghitung durasi
  void _hitungDurasi() {
    // Helper untuk konversi text ke int, default 0 jika kosong
    int getVal(TextEditingController ctrl) => int.tryParse(ctrl.text) ?? 0;

    int startH = getVal(_startHourCtrl);
    int startM = getVal(_startMinCtrl);
    int startS = getVal(_startSecCtrl);

    int endH = getVal(_endHourCtrl);
    int endM = getVal(_endMinCtrl);
    int endS = getVal(_endSecCtrl);

    // Konversi semua ke total detik
    int totalStartSeconds = (startH * 3600) + (startM * 60) + startS;
    int totalEndSeconds = (endH * 3600) + (endM * 60) + endS;

    int diffSeconds = totalEndSeconds - totalStartSeconds;

    // Logic jika melewati tengah malam (misal mulai 23:00 selesai 01:00)
    if (diffSeconds < 0) {
      diffSeconds += 24 * 3600;
    }

    // Konversi balik ke Jam, Menit, Detik
    int h = diffSeconds ~/ 3600;
    int m = (diffSeconds % 3600) ~/ 60;
    int s = diffSeconds % 60;

    setState(() {
      List<String> parts = [];
      if (h > 0) parts.add("$h Jam");
      if (m > 0) parts.add("$m Menit");
      parts.add("$s Detik"); // Detik selalu ditampilkan meski 0

      _hasilPerhitungan = "Hasil : ${parts.join(" ")}";
    });
  }

  // Fungsi Reset
  void _resetFields() {
    _startHourCtrl.clear();
    _startMinCtrl.clear();
    _startSecCtrl.clear();
    _endHourCtrl.clear();
    _endMinCtrl.clear();
    _endSecCtrl.clear();

    setState(() {
      _hasilPerhitungan = "Hasil : -";
    });

    // Request fokus kembali ke tbx1 (Start Hour)
    FocusScope.of(context).requestFocus(_startHourNode);
  }

  // Widget custom untuk Kotak Input (Tbx)
  Widget _buildTimeInput(
    TextEditingController controller,
    FocusNode currentNode,
    FocusNode? nextNode, // Bisa null jika ini kotak terakhir
    String label, {
    int maxValue = 59, // Default max value adalah 59 (untuk menit dan detik)
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            focusNode: currentNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // Input Formatters: Hanya angka & Maksimal 2 karakter
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              counterText: '', // Hilangkan counter karakter default
            ),
            onChanged: (value) {
              // Validasi nilai tidak melebihi maxValue
              if (value.isNotEmpty) {
                int inputValue = int.parse(value);
                if (inputValue > maxValue) {
                  controller.text = maxValue.toString();
                  if (maxValue < 10) {
                    controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length),
                    );
                  }
                }
              }

              // Trigger hitung setiap ada perubahan (opsional, bisa juga pakai tombol)
              _hitungDurasi();

              // Logic Auto Focus: Jika panjang 2, pindah ke nextNode
              if (value.length == 2 && nextNode != null) {
                FocusScope.of(context).requestFocus(nextNode);
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kalkulator Cooling Time")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: Waktu Mulai ---
            const Text(
              "Waktu Mulai Cooling",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeInput(
                  _startHourCtrl,
                  _startHourNode,
                  _startMinNode,
                  "Jam",
                  maxValue: 23,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    ":",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildTimeInput(
                  _startMinCtrl,
                  _startMinNode,
                  _startSecNode,
                  "Menit",
                  maxValue: 59,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    ":",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildTimeInput(
                  _startSecCtrl,
                  _startSecNode,
                  _endHourNode,
                  "Detik",
                  maxValue: 59,
                ), // Next node lompat ke End Hour
              ],
            ),

            const SizedBox(height: 30),

            // --- SECTION 2: Waktu Selesai ---
            const Text(
              "Waktu Selesai Cooling",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeInput(
                  _endHourCtrl,
                  _endHourNode,
                  _endMinNode,
                  "Jam",
                  maxValue: 23,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    ":",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildTimeInput(
                  _endMinCtrl,
                  _endMinNode,
                  _endSecNode,
                  "Menit",
                  maxValue: 59,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    ":",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildTimeInput(
                  _endSecCtrl,
                  _endSecNode,
                  null,
                  "Detik",
                  maxValue: 59,
                ), // Last node next is null
              ],
            ),

            const SizedBox(height: 40),

            // --- SECTION 3: Hasil ---
            Center(
              child: Text(
                _hasilPerhitungan,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),

            const Spacer(),

            // --- SECTION 4: Tombol Reset ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _resetFields,
                icon: const Icon(Icons.refresh),
                label: const Text("RESET", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

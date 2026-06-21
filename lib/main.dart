import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const UltimateCalculatorApp());

// ============ LOCALIZATION SYSTEM ============
class AppStrings {
  static const Map<String, Map<String, String>> _data = {
    'en': {
      'appTitle': 'ULTIMATE CALC',
      'basic': 'Basic',
      'scientific': 'Scientific',
      'programmer': 'Programmer',
      'graph': 'Graph',
      'convert': 'Convert',
      'date': 'Date',
      'history': 'History',
      'clearAll': 'Clear All',
      'noHistory': 'No history yet',
      'copied': 'Copied!',
      'language': 'Language',
      'enterFunction': 'Enter a function',
      'result': 'RESULT',
      'from': 'From',
      'to': 'To',
      'length': 'Length',
      'weight': 'Weight',
      'temperature': 'Temperature',
      'startDate': 'Start Date',
      'endDate': 'End Date',
      'daysDifference': 'Days Difference',
      'days': 'days',
      'years': 'years',
      'months': 'months',
    },
    'fa': {
      'appTitle': 'ماشین حساب نهایی',
      'basic': 'ساده',
      'scientific': 'علمی',
      'programmer': 'برنامه‌نویسی',
      'graph': 'نمودار',
      'convert': 'تبدیل',
      'date': 'تاریخ',
      'history': 'تاریخچه',
      'clearAll': 'پاک کردن',
      'noHistory': 'تاریخچه‌ای نیست',
      'copied': 'کپی شد!',
      'language': 'زبان',
      'enterFunction': 'تابع را وارد کنید',
      'result': 'نتیجه',
      'from': 'از',
      'to': 'به',
      'length': 'طول',
      'weight': 'وزن',
      'temperature': 'دما',
      'startDate': 'تاریخ شروع',
      'endDate': 'تاریخ پایان',
      'daysDifference': 'اختلاف روزها',
      'days': 'روز',
      'years': 'سال',
      'months': 'ماه',
    },
  };

  static String get(String key, String lang) {
    return _data[lang]?[key] ?? _data['en']?[key] ?? key;
  }
}

class UltimateCalculatorApp extends StatefulWidget {
  const UltimateCalculatorApp({super.key});

  @override
  State<UltimateCalculatorApp> createState() => _UltimateCalculatorAppState();
}

class _UltimateCalculatorAppState extends State<UltimateCalculatorApp> {
  String _lang = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lang = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _changeLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() => _lang = lang);
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = _lang == 'fa';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ultimate Calculator',
      locale: Locale(_lang),
      supportedLocales: const [Locale('en'), Locale('fa')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D9FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        lang: _lang,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String lang;
  final Function(String) onLanguageChanged;

  const HomeScreen({
    super.key,
    required this.lang,
    required this.onLanguageChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<String> _history = [];

  String t(String key) => AppStrings.get(key, widget.lang);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> _saveToHistory(String entry) async {
    final prefs = await SharedPreferences.getInstance();
    _history.insert(0, entry);
    if (_history.length > 50) _history.removeLast();
    await prefs.setStringList('history', _history);
    setState(() {});
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    setState(() => _history.clear());
  }

  void _haptic() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A0E21), Color(0xFF1A1A2E), Color(0xFF16213E)],
              ),
            ),
          ),
          // Background Animation 1
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFF00D9FF).withOpacity(0.3), Colors.transparent],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat())
             .move(begin: const Offset(0, 0), end: const Offset(20, 30), duration: 4.seconds)
             .then()
             .move(begin: const Offset(20, 30), end: const Offset(0, 0), duration: 4.seconds),
          ),
          // Background Animation 2
          Positioned(
            bottom: -100, left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFFFF00FF).withOpacity(0.3), Colors.transparent],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat())
             .move(begin: const Offset(0, 0), end: const Offset(-20, -30), duration: 5.seconds)
             .then()
             .move(begin: const Offset(-20, -30), end: const Offset(0, 0), duration: 5.seconds),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      BasicCalculator(onResult: _saveToHistory, lang: widget.lang, onHaptic: _haptic),
                      ScientificCalculator(onResult: _saveToHistory, lang: widget.lang, onHaptic: _haptic),
                      ProgrammerCalculator(lang: widget.lang, onHaptic: _haptic),
                      GraphingCalculator(lang: widget.lang),
                      UnitConverter(lang: widget.lang, onHaptic: _haptic),
                      DateCalculator(lang: widget.lang, onHaptic: _haptic),
                    ],
                  ),
                ),
                _buildBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final isRTL = widget.lang == 'fa';
    final titleFont = isRTL ? GoogleFonts.vazirmatn : GoogleFonts.orbitron;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              t('appTitle'),
              style: titleFont(
                fontSize: isRTL ? 20 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: const Color(0xFF00D9FF), blurRadius: 15)],
              ),
              overflow: TextOverflow.ellipsis,
            ).animate().fadeIn(duration: 500.ms).slideX(begin: isRTL ? 0.2 : -0.2, end: 0),
          ),
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: _showLanguageSheet,
          ).animate().fadeIn(delay: 200.ms),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: _showHistorySheet,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final isRTL = widget.lang == 'fa';
    final bodyFont = isRTL ? GoogleFonts.vazirmatn : GoogleFonts.robotoMono;
    final items = [
      {'icon': Icons.calculate, 'label': t('basic')},
      {'icon': Icons.science, 'label': t('scientific')},
      {'icon': Icons.code, 'label': t('programmer')},
      {'icon': Icons.show_chart, 'label': t('graph')},
      {'icon': Icons.swap_horiz, 'label': t('convert')},
      {'icon': Icons.calendar_today, 'label': t('date')},
    ];
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = _currentIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _haptic();
                setState(() => _currentIndex = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF00D9FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: active ? [BoxShadow(color: const Color(0xFF00D9FF).withOpacity(0.5), blurRadius: 15)] : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i]['icon'] as IconData, color: active ? Colors.black : Colors.white70, size: 18),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        items[i]['label'] as String,
                        style: bodyFont(
                          color: active ? Colors.black : Colors.white70,
                          fontSize: 8,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showLanguageSheet() {
    final titleFont = widget.lang == 'fa' ? GoogleFonts.vazirmatn : GoogleFonts.orbitron;
    final bodyFont = widget.lang == 'fa' ? GoogleFonts.vazirmatn : GoogleFonts.robotoMono;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t('language'), style: titleFont(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 20),
            _langButton('English', 'en', Icons.language, bodyFont),
            const SizedBox(height: 10),
            _langButton('فارسی', 'fa', Icons.translate, bodyFont),
          ],
        ),
      ),
    );
  }

  Widget _langButton(String label, String lang, IconData icon, TextStyle Function({Color? color}) font) {
    final isSelected = widget.lang == lang;
    return InkWell(
      onTap: () {
        widget.onLanguageChanged(lang);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D9FF).withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? const Color(0xFF00D9FF) : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00D9FF) : Colors.white70),
            const SizedBox(width: 15),
            Text(label, style: font(color: Colors.white).copyWith(fontSize: 16)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF00D9FF)),
          ],
        ),
      ),
    );
  }

  void _showHistorySheet() {
    final bodyFont = widget.lang == 'fa' ? GoogleFonts.vazirmatn : GoogleFonts.robotoMono;
    final titleFont = widget.lang == 'fa' ? GoogleFonts.vazirmatn : GoogleFonts.orbitron;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(t('history'), style: titleFont(fontSize: 18, color: Colors.white)),
                const Spacer(),
                if (_history.isNotEmpty)
                  TextButton(
                    onPressed: () { _clearHistory(); Navigator.pop(context); },
                    child: Text(t('clearAll'), style: const TextStyle(color: Colors.redAccent)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: _history.isEmpty
                ? Center(child: Text(t('noHistory'), style: const TextStyle(color: Colors.white54)))
                : ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(_history[index], style: bodyFont(color: Colors.white))),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18, color: Color(0xFF00D9FF)),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _history[index]));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('copied'))));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ BASIC CALCULATOR ============
class BasicCalculator extends StatefulWidget {
  final Function(String) onResult;
  final String lang;
  final VoidCallback onHaptic;
  const BasicCalculator({super.key, required this.onResult, required this.lang, required this.onHaptic});

  @override
  State<BasicCalculator> createState() => _BasicCalculatorState();
}

class _BasicCalculatorState extends State<BasicCalculator> {
  String _expression = '';
  String _result = '0';
  final Parser _parser = Parser();
  final ContextModel _cm = ContextModel();

  void _onKeyPressed(String value) {
    widget.onHaptic();
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _evaluate();
        }
      } else if (value == '=') {
        _evaluate();
        if (_result != 'Error' && _expression.isNotEmpty) {
          widget.onResult('$_expression = $_result');
        }
        _expression = _result;
      } else {
        _expression += value;
        _evaluate();
      }
    });
  }

  void _evaluate() {
    try {
      String evalExpr = _expression.replaceAll('×', '*').replaceAll('÷', '/');
      Expression exp = _parser.parse(evalExpr);
      double eval = exp.evaluate(EvaluationType.REAL, _cm);
      setState(() {
        _result = eval.toStringAsFixed(8).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
        if (_result.endsWith('.')) _result = _result.substring(0, _result.length - 1);
      });
    } catch (e) {
      setState(() => _result = _expression.isEmpty ? '0' : '...');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.lang == 'fa';
    final numFont = isRTL ? GoogleFonts.vazirmatn : GoogleFonts.orbitron;
    final exprFont = isRTL ? GoogleFonts.vazirmatn : GoogleFonts.robotoMono;
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_expression.isEmpty ? ' ' : _expression,
                    textAlign: isRTL ? TextAlign.left : TextAlign.right,
                    style: exprFont(fontSize: 32, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(_result,
                    textAlign: isRTL ? TextAlign.left : TextAlign.right,
                    style: numFont(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white,
                      shadows: [Shadow(color: const Color(0xFF00D9FF), blurRadius: 20)]),
                  ).animate().scaleXY(begin: 1, end: 1.05, duration: 100.ms).then().scaleXY(begin: 1.05, end: 1, duration: 100.ms),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(child: Row(children: [
                  _buildButton('C', Colors.redAccent),
                  _buildButton('⌫', Colors.orange),
                  _buildButton('%', Colors.orange),
                  _buildButton('÷', const Color(0xFF00D9FF)),
                ])),
                Expanded(child: Row(children: [
                  _buildButton('7', const Color(0xFF1E1E2E)),
                  _buildButton('8', const Color(0xFF1E1E2E)),
                  _buildButton('9', const Color(0xFF1E1E2E)),
                  _buildButton('×', const Color(0xFF00D9FF)),
                ])),
                Expanded(child: Row(children: [
                  _buildButton('4', const Color(0xFF1E1E2E)),
                  _buildButton('5', const Color(0xFF1E1E2E)),
                  _buildButton('6', const Color(0xFF1E1E2E)),
                  _buildButton('-', const Color(0xFF00D9FF)),
                ])),
                Expanded(child: Row(children: [
                  _buildButton('1', const Color(0xFF1E1E2E)),
                  _buildButton('2', const Color(0xFF1E1E2E)),
                  _buildButton('3', const Color(0xFF1E1E2E)),
                  _buildButton('+', const Color(0xFF00D9FF)),
                ])),
                Expanded(child: Row(children: [
                  _buildButton('0', const Color(0xFF1E1E2E), flex: 2),
                  _buildButton('.', const Color(0xFF1E1E2E)),
                  _buildButton('=', const Color(0xFF00FF88)),
                ])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String label, Color color, {int flex = 1}) {
    final isRTL = widget.lang == 'fa';
    final font = isRTL ? GoogleFonts.vazirmatn : GoogleFonts.orbitron;
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _onKeyPressed(label),
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.5), width: 1),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, spreadRadius: 1),
                ],
              ),
              child: Center(
                child: Text(label,
                  style: font(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: color, blurRadius: 10)]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============ SCIENTIFIC CALCULATOR ============
class ScientificCalculator extends StatefulWidget {
  final Function(String) onResult;
  final String lang;
  final VoidCallback onHaptic;
  const ScientificCalculator({super.key, required this.onResult, required this.lang, required this.onHaptic});

  @override
  State<ScientificCalculator> createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  String _expression = '';
  String _result = '0';
  final Parser _parser = Parser();
  final ContextModel _cm = ContextModel();

  void _onKeyPressed(String value) {
    widget.onHaptic();
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _evaluate();
        }
      } else if (value == '=') {
        _evaluate();
        if (_result != 'Error' && _expression.isNotEmpty) {
          widget.onResult('$_expression = $_result');
        }
        _expression = _result;
      } else {
        _expression += value;
        _evaluate();
      }
    });
  }

  void _evaluate() {
    try {
      String evalExpr = _expression
        .replaceAll('×', '*').replaceAll('÷', '/')
        .replaceAll('π', '3.1415926535897932')
        .replaceAll('e', '2.7182818284590452')
        .replaceAll('√(', 'sqrt(');
      Expression exp = _parser.parse(evalExpr);
      double eval = exp.evaluate(EvaluationType.REAL, _cm);
      setState(() {
        _result = eval.toStringAsFixed(8).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
        if (_result.endsWith('.')) _result = _result.substring(0, _result.length - 1);
      });
    } catch (e) {
      setState(() => _result = _expression.isEmpty ? '0' : '...');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.lang == 'fa';
    final numFont = isRTL ? GoogleFonts.vazirmatn : GoogleFonts.orbitron;
    final exprFont = isRTL ? GoogleFonts.vazirmatn : GoogleFonts.robotoMono;
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_expression.isEmpty ? ' ' : _expression,
                  textAlign: isRTL ? TextAlign.left : TextAlign.right,
                  style: exprFont(fontSize: 24, color: Colors.white70)),
                const SizedBox(height: 8),
                Text(_result,
                  textAlign: isRTL ? TextAlign.left : TextAlign.right,
                  style: numFont(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white,
                    shadows: [Shadow(color: const Color(0xFFFF00FF), blurRadius: 20)])),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(child: Row(children: [
                  _sBtn('sin(', const Color(0xFF9C27B0)),
                  _sBtn('cos(', const Color(0xFF9C27B0)),
                  _sBtn('tan(', const Color(0xFF9C27B0)),
                  _sBtn('log(', const Color(0xFF9C27B0)),
                  _sBtn('ln(', const Color(0xFF9C27B0)),
                ])),
                Expanded(child: Row(children: [
                  _sBtn('√(', const Color(0xFF9C27B0)),
                  _sBtn('^', const Color(0xFF9C27B0)),
                  _sBtn('π', const Color(0xFF9C27B0)),
                  _sBtn('e', const Color(0xFF9C27B0)),
                  _sBtn('(', const Color(0xFF9C27B0)),
                  _sBtn(')', const Color(0xFF9C27B0)),
                ])),
                Expanded(child: Row(children: [
                  _sBtn('C', Colors.redAccent),
                  _sBtn('⌫', Colors.orange),
                  _sBtn('%', Colors.orange),
                  _sBtn('÷', const Color(0xFFFF00FF)),
                ])),
                Expanded(child: Row(children: [
                  _sBtn('7', const Color(0xFF1E1E2E)),
                  _sBtn('8', const Color(0xFF1E1E2E)),
                  _sBtn('9', const Color(0xFF1E1E2E)),
                  _sBtn('×', const Color(0xFFFF00FF)),
                ])),
                Expanded(child: Row(children: [
                  _sBtn('4', const Color(0xFF1E1E2E)),
                  _sBtn('5', const Color(0xFF1E1E2E)),
                  _sBtn('6', const Color(0xFF1E1E2E)),
                  _sBtn('-', const Color(0xFFFF00FF)),
                ])),
                Expanded(child: Row(children: [
                  _sBtn('1', const Color(0xFF1E1E2E)),
                  _sBtn('2', const Color(0xFF1E1E2E)),
                  _sBtn('3', const Color(0xFF1E1E2E)),
                  _sBtn('+', const Color(0xFFFF00FF)),
                ])),
                Expanded(child: Row(children: [
                  _sBtn('0', const Color(0xFF1E1E2E), flex: 2),
                  _sBtn('.', const Color(0xFF1E1E2E)),
                  _sBtn('=', const Color(0xFF00FF88)),
                ])),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sBtn(String label, Color color, {int flex = 1}) {
    final font = GoogleFonts.robotoMono;
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _onKeyPressed(label),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.5)),
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)],
            ),
            child: Center(
              child: Text(label,
                style: font(fontSize: label.length > 2 ? 13 : 18, color: Colors.white, fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: color, blurRadius: 8)])),
            ),
          ),
        ),
      ),
    );
  }
}

// ============ PROGRAMMER CALCULATOR ============
class ProgrammerCalculator extends StatefulWidget {
  final String lang;
  final VoidCallback onHaptic;
  const ProgrammerCalculator({super.key, required this.lang, required this.onHaptic});

  @override
  State<ProgrammerCalculator> createState() => _ProgrammerCalculatorState();
}

class _ProgrammerCalculatorState extends State<ProgrammerCalculator> {
  int _decimalValue = 0;
  String _input = '';
  int _base = 10;

  void _updateValue(String digit) {
    widget.onHaptic();
    setState(() {
      _input += digit;
      try {
        _decimalValue = int.parse(_input, radix: _base);
      } catch (e) {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }

  void _clear() {
    widget.onHaptic();
    setState(() { _input = ''; _decimalValue = 0; });
  }

  String _convert(int value, int base) {
    try {
      return value.toRadixString(base).toUpperCase();
    } catch (e) {
      return '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3)),
              boxShadow: [BoxShadow(color: const Color(0xFF00D9FF).withOpacity(0.2), blurRadius: 20)],
            ),
            child: Column(
              children: [
                _baseRow('BIN', 2, const Color(0xFFFF5722)),
                _baseRow('OCT', 8, const Color(0xFFFF9800)),
                _baseRow('DEC', 10, const Color(0xFF00D9FF)),
                _baseRow('HEX', 16, const Color(0xFF4CAF50)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                ...['A','B','C','D','E','F'].map((h) => _hexBtn(h)),
                _numBtn('C', Colors.redAccent, () => _clear()),
                _numBtn('⌫', Colors.orange, () {
                  widget.onHaptic();
                  setState(() {
                    if (_input.isNotEmpty) {
                      _input = _input.substring(0, _input.length - 1);
                      if (_input.isEmpty) _decimalValue = 0;
                      else _decimalValue = int.tryParse(_input, radix: _base) ?? 0;
                    }
                  });
                }),
                ...['1','2','3','4','5','6','7','8','9','0'].map((n) => _numBtn(n, const Color(0xFF1E1E2E), () => _updateValue(n))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _baseRow(String label, int base, Color color) {
    final isSelected = _base == base;
    return GestureDetector(
      onTap: () {
        widget.onHaptic();
        setState(() {
          _base = base;
          _input = _decimalValue.toRadixString(base).toUpperCase();
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(isSelected ? 1 : 0.3)),
        ),
        child: Row(
          children: [
            Text(label, style: GoogleFonts.orbitron(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
            const Spacer(),
            Expanded(
              child: Text(
                _convert(_decimalValue, base),
                textAlign: TextAlign.right,
                style: GoogleFonts.robotoMono(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numBtn(String label, Color color, VoidCallback onTap) {
    bool disabled = false;
    if (_base == 2 && !['0','1'].contains(label)) disabled = true;
    if (_base == 8 && !['0','1','2','3','4','5','6','7'].contains(label)) disabled = true;
    if (_base == 10 && !['0','1','2','3','4','5','6','7','8','9'].contains(label)) disabled = true;

    return Opacity(
      opacity: disabled ? 0.3 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)],
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _hexBtn(String label) {
    final disabled = _base != 16;
    return Opacity(
      opacity: disabled ? 0.3 : 1,
      child: InkWell(
        onTap: disabled ? null : () => _updateValue(label),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.5)),
            boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.3), blurRadius: 10)],
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

// ============ GRAPHING CALCULATOR ============
class GraphingCalculator extends StatefulWidget {
  final String lang;
  const GraphingCalculator({super.key, required this.lang});

  @override
  State<GraphingCalculator> createState() => _GraphingCalculatorState();
}

class _GraphingCalculatorState extends State<GraphingCalculator> {
  final TextEditingController _controller = TextEditingController(text: 'sin(x)');
  List<FlSpot> _points = [];
  double _minY = -2, _maxY = 2;

  String t(String key) => AppStrings.get(key, widget.lang);

  @override
  void initState() {
    super.initState();
    _updateGraph();
  }

  void _updateGraph() {
    final parser = Parser();
    final cm = ContextModel();
    final points = <FlSpot>[];
    double minY = double.infinity, maxY = double.negativeInfinity;

    try {
      for (double x = -10; x <= 10; x += 0.2) {
        cm.bindVariable(Variable('x'), Number(x));
        final exp = parser.parse(_controller.text
          .replaceAll('sin', 'sin').replaceAll('cos', 'cos').replaceAll('tan', 'tan')
          .replaceAll('π', '3.14159').replaceAll('sqrt', 'sqrt'));
        final y = exp.evaluate(EvaluationType.REAL, cm) as double;
        if (y.isFinite && y.abs() < 1000) {
          points.add(FlSpot(x, y));
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
      if (minY == double.infinity) { minY = -2; maxY = 2; }
      setState(() {
        _points = points;
        _minY = minY - 1;
        _maxY = maxY + 1;
      });
    } catch (e) {
      setState(() => _points = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.lang == 'fa';
    final font = isRTL ? GoogleFonts.vazirmatn : GoogleFonts.orbitron;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF00FF).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text('f(x) = ', style: font(color: const Color(0xFFFF00FF), fontWeight: FontWeight.bold)),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'sin(x)', hintStyle: TextStyle(color: Colors.white24)),
                    onSubmitted: (_) => _updateGraph(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFFFF00FF)),
                  onPressed: _updateGraph,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: ['sin(x)', 'cos(x)', 'tan(x)', 'x^2', 'sqrt(x)', '1/x', 'log(x)'].map((f) {
                return ActionChip(
                  label: Text(f, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  backgroundColor: const Color(0xFF9C27B0).withOpacity(0.3),
                  onPressed: () { _controller.text = f; _updateGraph(); },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF00FF).withOpacity(0.3)),
              ),
              child: _points.isEmpty
                ? Center(child: Text(t('enterFunction'), style: const TextStyle(color: Colors.white54)))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1),
                        getDrawingVerticalLine: (v) => FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: -10, maxX: 10,
                      minY: _minY, maxY: _maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _points,
                          isCurved: true,
                          color: const Color(0xFFFF00FF),
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFFFF00FF).withOpacity(0.2),
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

// ============ UNIT CONVERTER ============
class UnitConverter extends StatefulWidget {
  final String lang;
  final VoidCallback onHaptic;
  const UnitConverter({super.key, required this.lang, required this.onHaptic});

  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  String _category = 'Length';
  String _from = 'Meter';
  String _to = 'Kilometer';
  final TextEditingController _input = TextEditingController(text: '1');

  String t(String key) => AppStrings.get(key, widget.lang);

  final Map<String, Map<String, double>> _data = {
    'Length': {
      'Millimeter': 0.001, 'Centimeter': 0.01, 'Meter': 1.0,
      'Kilometer': 1000.0, 'Inch': 0.0254, 'Foot': 0.3048, 'Mile': 1609.34,
    },
    'Weight': {
      'Milligram': 0.001, 'Gram': 1.0, 'Kilogram': 1000.0,
      'Ton': 1000000.0, 'Ounce': 28.3495, 'Pound': 453.592,
    },
    'Temperature': {'Celsius': 1, 'Fahrenheit': 2, 'Kelvin': 3},
  };

  String _localizeCategory(String cat) {
    if (widget.lang == 'fa') {
      if (cat == 'Length') return 'طول';
      if (cat == 'Weight') return 'وزن';
      if (cat == 'Temperature') return 'دما';
    }
    return cat;
  }

  double _convert() {
    final v = double.tryParse(_input.text) ?? 0;
    if (_category == 'Temperature') {
      double c = v;
      if (_from == 'Fahrenheit') c = (v - 32) * 5 / 9;
      else if (_from == 'Kelvin') c = v - 273.15;
      
      if (_to == 'Celsius') return c;
      if (_to == 'Fahrenheit') return c * 9 / 5 + 32;
      return c + 273.15;
    }
    final fromFactor = _data[_category]![_from]!;
    final toFactor = _data[_category]![_to]!;
    return v * fromFactor / toFactor;
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.lang == 'fa';
    final font = isRTL ? GoogleFonts.vazirmatn : GoogleFonts.orbitron;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Length', 'Weight', 'Temperature'].map((c) {
                final sel = _category == c;
                return GestureDetector(
                  onTap: () {
                    widget.onHaptic();
                    setState(() {
                      _category = c;
                      _from = _data[c]!.keys.first;
                      _to = _data[c]!.keys.last;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFF00FF88) : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(_localizeCategory(c), style: TextStyle(color: sel ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: isRTL ? 13 : 14)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          _dropdown('From', _from, (v) => setState(() => _from = v!)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TextField(
              controller: _input,
              keyboardType: TextInputType.number,
              style: font(fontSize: 32, color: Colors.white),
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 10),
          const Icon(Icons.arrow_downward, color: Color(0xFF00FF88), size: 30)
            .animate(onPlay: (c) => c.repeat()).moveY(begin: -5, end: 5, duration: 1.seconds).then().moveY(begin: 5, end: -5, duration: 1.seconds),
          const SizedBox(height: 10),
          _dropdown('To', _to, (v) => setState(() => _to = v!)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [const Color(0xFF00FF88).withOpacity(0.2), const Color(0xFF00D9FF).withOpacity(0.2)]),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5)),
              boxShadow: [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.3), blurRadius: 25)],
            ),
            child: Column(
              children: [
                Text(t('result'), style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
                const SizedBox(height: 10),
                Text(
                  _convert().toStringAsFixed(6).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), ""),
                  style: font(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white,
                    shadows: [Shadow(color: const Color(0xFF00FF88), blurRadius: 20)]),
                ),
                Text(_to, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ).animate().scaleXY(begin: 1, end: 1.02, duration: 500.ms).then().scaleXY(begin: 1.02, end: 1, duration: 500.ms),
        ],
      ),
    );
  }

  Widget _dropdown(String label, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A2E),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00FF88)),
          style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white),
          items: _data[_category]!.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ============ DATE CALCULATOR ============
class DateCalculator extends StatefulWidget {
  final String lang;
  final VoidCallback onHaptic;
  const DateCalculator({super.key, required this.lang, required this.onHaptic});

  @override
  State<DateCalculator> createState() => _DateCalculatorState();
}

class _DateCalculatorState extends State<DateCalculator> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  int _daysDiff = 30;

  String t(String key) => AppStrings.get(key, widget.lang);

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    setState(() {
      _daysDiff = _endDate.difference(_startDate).inDays;
    });
  }

  String _toPersianNum(String input) {
    const english = ['0','1','2','3','4','5','6','7','8','9'];
    const persian = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], persian[i]);
    }
    return input;
  }

  String _formatDate(DateTime date) {
    final str = '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    return widget.lang == 'fa' ? _toPersianNum(str) : str;
  }

  Future<void> _pickStart() async {
    widget.onHaptic();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _calculate();
      });
    }
  }

  Future<void> _pickEnd() async {
    widget.onHaptic();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _calculate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = widget.lang == 'fa';
    
    // ایجاد یک تابع واسط برای حل مشکل Signature فونت‌ها
    TextStyle myFont({Color? color, double? fontSize, FontWeight? fontWeight, List<Shadow>? shadows}) {
      if (isRTL) return GoogleFonts.vazirmatn(color: color, fontSize: fontSize, fontWeight: fontWeight, shadows: shadows);
      return GoogleFonts.orbitron(color: color, fontSize: fontSize, fontWeight: fontWeight, shadows: shadows);
    }

    TextStyle bodyFont({Color? color, double? fontSize}) {
      if (isRTL) return GoogleFonts.vazirmatn(color: color, fontSize: fontSize);
      return GoogleFonts.robotoMono(color: color, fontSize: fontSize);
    }
    
    final years = (_daysDiff / 365.25).floor();
    final months = ((_daysDiff % 365.25) / 30.44).floor();
    final days = (_daysDiff - (years * 365) - (months * 30)).abs();

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _dateCard(t('startDate'), _formatDate(_startDate), Icons.calendar_today, const Color(0xFF00D9FF), _pickStart, myFont),
          const SizedBox(height: 15),
          const Icon(Icons.arrow_downward, color: Color(0xFF00FF88), size: 30)
            .animate(onPlay: (c) => c.repeat()).moveY(begin: -5, end: 5, duration: 1.seconds).then().moveY(begin: 5, end: -5, duration: 1.seconds),
          const SizedBox(height: 15),
          _dateCard(t('endDate'), _formatDate(_endDate), Icons.event, const Color(0xFFFF00FF), _pickEnd, myFont),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00D9FF).withOpacity(0.2),
                  const Color(0xFFFF00FF).withOpacity(0.2),
                  const Color(0xFF00FF88).withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5)),
              boxShadow: [BoxShadow(color: const Color(0xFF00FF88).withOpacity(0.3), blurRadius: 25)],
            ),
            child: Column(
              children: [
                Text(t('daysDifference'), style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
                const SizedBox(height: 15),
                Text(
                  '${widget.lang == 'fa' ? _toPersianNum('$_daysDiff') : '$_daysDiff'} ${t('days')}',
                  style: myFont(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white,
                    shadows: [Shadow(color: const Color(0xFF00FF88), blurRadius: 20)]),
                ).animate().scaleXY(begin: 1, end: 1.05, duration: 300.ms).then().scaleXY(begin: 1.05, end: 1, duration: 300.ms),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoBox(widget.lang == 'fa' ? _toPersianNum('$years') : '$years', t('years'), const Color(0xFF00D9FF), myFont, bodyFont),
                      _infoBox(widget.lang == 'fa' ? _toPersianNum('$months') : '$months', t('months'), const Color(0xFFFF00FF), myFont, bodyFont),
                      _infoBox(widget.lang == 'fa' ? _toPersianNum('$days') : '$days', t('days'), const Color(0xFF00FF88), myFont, bodyFont),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateCard(String label, String date, IconData icon, Color color, VoidCallback onTap, TextStyle Function({Color? color, double? fontSize, FontWeight? fontWeight, List<Shadow>? shadows}) font) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 5),
                Text(date, style: font(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String value, String label, Color color, TextStyle Function({Color? color, double? fontSize, FontWeight? fontWeight, List<Shadow>? shadows}) font, TextStyle Function({Color? color, double? fontSize}) bodyFont) {
    return Column(
      children: [
        Text(value, style: font(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: bodyFont(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

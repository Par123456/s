import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

void main() {
  runApp(const UltimateCalculatorApp());
}

class UltimateCalculatorApp extends StatelessWidget {
  const UltimateCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ultimate Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D9FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _history = [];

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
                      BasicCalculator(onResult: _saveToHistory),
                      ScientificCalculator(onResult: _saveToHistory),
                      ProgrammerCalculator(onResult: _saveToHistory),
                      const GraphingCalculator(),
                      const UnitConverter(),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            'ULTIMATE CALC',
            style: GoogleFonts.orbitron(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: const Color(0xFF00D9FF), blurRadius: 15)],
            ),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2, end: 0),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: _showHistorySheet,
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.5, 0.5)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.calculate, 'label': 'Basic'},
      {'icon': Icons.science, 'label': 'Scientific'},
      {'icon': Icons.code, 'label': 'Programmer'},
      {'icon': Icons.show_chart, 'label': 'Graph'},
      {'icon': Icons.swap_horiz, 'label': 'Convert'},
    ];
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  Text(
                    items[i]['label'] as String,
                    style: TextStyle(color: active ? Colors.black : Colors.white70, fontSize: 9, fontWeight: active ? FontWeight.bold : FontWeight.normal),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showHistorySheet() {
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
                Text('History', style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white)),
                const Spacer(),
                if (_history.isNotEmpty)
                  TextButton(
                    onPressed: () { _clearHistory(); Navigator.pop(context); },
                    child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: _history.isEmpty
                ? const Center(child: Text('No history yet', style: TextStyle(color: Colors.white54)))
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
                          Expanded(child: Text(_history[index], style: GoogleFonts.robotoMono(color: Colors.white))),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18, color: Color(0xFF00D9FF)),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _history[index]));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
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
  const BasicCalculator({super.key, required this.onResult});

  @override
  State<BasicCalculator> createState() => _BasicCalculatorState();
}

class _BasicCalculatorState extends State<BasicCalculator> {
  String _expression = '';
  String _result = '0';
  final Parser _parser = Parser();
  final ContextModel _cm = ContextModel();

  void _onKeyPressed(String value) {
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
                    textAlign: TextAlign.right,
                    style: GoogleFonts.robotoMono(fontSize: 32, color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Text(_result,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.orbitron(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white,
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
                  style: GoogleFonts.orbitron(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold,
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
  const ScientificCalculator({super.key, required this.onResult});

  @override
  State<ScientificCalculator> createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  String _expression = '';
  String _result = '0';
  final Parser _parser = Parser();
  final ContextModel _cm = ContextModel();

  void _onKeyPressed(String value) {
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
                  textAlign: TextAlign.right,
                  style: GoogleFonts.robotoMono(fontSize: 24, color: Colors.white70)),
                const SizedBox(height: 8),
                Text(_result,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.orbitron(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white,
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
                style: GoogleFonts.orbitron(fontSize: label.length > 2 ? 13 : 18, color: Colors.white, fontWeight: FontWeight.bold,
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
  final Function(String) onResult;
  const ProgrammerCalculator({super.key, required this.onResult});

  @override
  State<ProgrammerCalculator> createState() => _ProgrammerCalculatorState();
}

class _ProgrammerCalculatorState extends State<ProgrammerCalculator> {
  int _decimalValue = 0;
  String _input = '';
  int _base = 10;

  void _updateValue(String digit) {
    setState(() {
      _input += digit;
      try {
        _decimalValue = int.parse(_input, radix: _base);
      } catch (e) {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }

  void _clear() => setState(() { _input = ''; _decimalValue = 0; });

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
  const GraphingCalculator({super.key});

  @override
  State<GraphingCalculator> createState() => _GraphingCalculatorState();
}

class _GraphingCalculatorState extends State<GraphingCalculator> {
  final TextEditingController _controller = TextEditingController(text: 'sin(x)');
  List<FlSpot> _points = [];
  double _minY = -2, _maxY = 2;

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
        cm.bindVariable(Name('x'), Number(x));
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
                Text('f(x) = ', style: GoogleFonts.orbitron(color: const Color(0xFFFF00FF), fontWeight: FontWeight.bold)),
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
                  label: Text(f, style: TextStyle(color: Colors.white, fontSize: 11)),
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
                ? const Center(child: Text('Enter a function', style: TextStyle(color: Colors.white54)))
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
  const UnitConverter({super.key});

  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  String _category = 'Length';
  String _from = 'Meter';
  String _to = 'Kilometer';
  final TextEditingController _input = TextEditingController(text: '1');

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
                  onTap: () => setState(() {
                    _category = c;
                    _from = _data[c]!.keys.first;
                    _to = _data[c]!.keys.last;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFF00FF88) : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(c, style: TextStyle(color: sel ? Colors.black : Colors.white70, fontWeight: FontWeight.bold)),
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
              style: GoogleFonts.orbitron(fontSize: 32, color: Colors.white),
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
                const Text('RESULT', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
                const SizedBox(height: 10),
                Text(
                  _convert().toStringAsFixed(6).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), ""),
                  style: GoogleFonts.orbitron(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white,
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

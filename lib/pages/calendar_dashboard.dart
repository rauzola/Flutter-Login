import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:telalogin/models/ensalamento.dart';

class CalendarDashboard extends StatefulWidget {
  const CalendarDashboard({Key? key}) : super(key: key);

  @override
  State<CalendarDashboard> createState() => _CalendarDashboardState();
}

class _CalendarDashboardState extends State<CalendarDashboard> {
  final supabase = Supabase.instance.client;

  bool _loading = true;
  String? _error;

  Map<DateTime, List<Ensalamento>> _events = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadEnsalamentos();
  }

Future<void> _loadEnsalamentos() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final dataList = await supabase
        .from('ensalamento')
        .select('id, data, horario, turma_id, sala_id, professor_id, turma(nome), sala(nome), professor(name)');

    final rows = dataList as List<dynamic>;

    List<Ensalamento> ensalamentos = rows.map((e) => Ensalamento.fromJoin(e)).toList();

    Map<DateTime, List<Ensalamento>> events = {};
    for (var e in ensalamentos) {
      final day = DateTime.utc(e.data.year, e.data.month, e.data.day);
      events.putIfAbsent(day, () => []).add(e);
    }

    setState(() {
      _events = events;
      _loading = false;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
      _loading = false;
    });
  }
}


  List<Ensalamento> _getEventsForDay(DateTime day) {
    final d = DateTime.utc(day.year, day.month, day.day);
    return _events[d] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final events = _getEventsForDay(selectedDay);
    if (events.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum ensalamento para este dia.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ensalamento em ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final e = events[index];
              return ListTile(
                title: Text('${e.turmaNome} - Sala: ${e.salaNome}'),
                subtitle: Text('Professor: ${e.professorNome}\nHorário: ${e.horario}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Erro: $_error'));
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: TableCalendar<Ensalamento>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) =>
            _selectedDay != null &&
            day.year == _selectedDay!.year &&
            day.month == _selectedDay!.month &&
            day.day == _selectedDay!.day,
        eventLoader: _getEventsForDay,
        onDaySelected: _onDaySelected,
        calendarStyle: const CalendarStyle(
          markerDecoration: BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/reservations/controllers/reservations_controller.dart';
import 'package:front_bars_flutter/core/utils/extensions.dart';

/// Formulario para crear una nueva reserva (cliente)
class ReservationFormScreen extends ConsumerStatefulWidget {
  final String? barId;

  const ReservationFormScreen({super.key, this.barId});

  @override
  ConsumerState<ReservationFormScreen> createState() =>
      _ReservationFormScreenState();
}

class _ReservationFormScreenState
    extends ConsumerState<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _commentsController = TextEditingController();

  String? _selectedBarId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _numberOfPeople = 2;

  @override
  void initState() {
    super.initState();
    _selectedBarId = widget.barId;
    
    // Cargar lista de bares si no hay uno preseleccionado
    if (widget.barId == null) {
      Future.microtask(() {
        ref.read(barsControllerProvider.notifier).loadAllBars();
      });
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barsState = ref.watch(barsControllerProvider);
    final reservationsState = ref.watch(reservationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Reserva'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Selección de bar (si no viene preseleccionado)
            if (widget.barId == null) ...[
              const Text(
                'Selecciona un bar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBarId,
                decoration: InputDecoration(
                  hintText: 'Selecciona un bar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.storefront),
                ),
                items: barsState.bars.map((bar) {
                  return DropdownMenuItem(
                    value: bar.id,
                    child: Text(bar.nameBar),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBarId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona un bar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ],

            // Fecha
            const Text(
              'Fecha de reserva',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Selecciona una fecha'
                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: TextStyle(
                    color: _selectedDate == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Hora
            const Text(
              'Hora de reserva',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectTime,
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.access_time),
                ),
                child: Text(
                  _selectedTime == null
                      ? 'Selecciona una hora'
                      : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: _selectedTime == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Número de personas
            const Text(
              'Número de personas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _numberOfPeople > 1
                      ? () {
                          setState(() {
                            _numberOfPeople--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: const Color(0xFF6366F1),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_numberOfPeople ${_numberOfPeople == 1 ? 'persona' : 'personas'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _numberOfPeople < 20
                      ? () {
                          setState(() {
                            _numberOfPeople++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFF6366F1),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Datos del cliente
            const Text(
              'Tus datos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                hintText: 'Tu nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerPhoneController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                hintText: '123-456-7890',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu teléfono';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Comentarios opcionales
            TextFormField(
              controller: _commentsController,
              decoration: InputDecoration(
                labelText: 'Comentarios (opcional)',
                hintText: 'Alergias, preferencias, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.comment),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Botón de enviar
            ElevatedButton(
              onPressed: reservationsState.isLoading ? null : _submitReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: reservationsState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Crear Reserva',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = DateTime(now.year + 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      context.showErrorSnackBar('Por favor selecciona una fecha');
      return;
    }

    if (_selectedTime == null) {
      context.showErrorSnackBar('Por favor selecciona una hora');
      return;
    }

    if (_selectedBarId == null) {
      context.showErrorSnackBar('Por favor selecciona un bar');
      return;
    }

    // Combinar fecha y hora
    final reservationDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final data = {
      'barId': _selectedBarId,
      'reservationDate': reservationDateTime.toIso8601String(),
      'numberOfPeople': _numberOfPeople,
      'customerName': _customerNameController.text.trim(),
      'customerPhone': _customerPhoneController.text.trim(),
      if (_commentsController.text.isNotEmpty)
        'comments': _commentsController.text.trim(),
    };

    final success = await ref
        .read(reservationsControllerProvider.notifier)
        .createReservation(data);

    if (success && mounted) {
      context.showSuccessSnackBar('Reserva creada exitosamente');
      context.pop();
    } else if (mounted) {
      final errorMessage = ref.read(reservationsControllerProvider).errorMessage;
      context.showErrorSnackBar(
        errorMessage ?? 'Error al crear la reserva',
      );
    }
  }
}

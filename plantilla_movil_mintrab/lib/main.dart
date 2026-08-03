import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plantilla_movil_mintrab/config/app_theme.dart';
import 'package:plantilla_movil_mintrab/core/storage/secure_storage.dart';
import 'package:plantilla_movil_mintrab/presentation/layout/main_layout.dart';
import 'package:plantilla_movil_mintrab/presentation/screens/home_screen.dart';
import 'package:plantilla_movil_mintrab/presentation/screens/login_screen.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/button.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/custom_alert_dialog.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/custom_checkbox.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/custom_input_number.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/custom_radio_group.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/custom_input_date.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/custom_input_text.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/custom_input_text_area.dart';
import 'package:plantilla_movil_mintrab/utils/cui_validator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mintrab Template',
      debugShowCheckedModeBanner: false,
      theme: AppTheme(selectedColorIndex: 0).theme(),
      home: FutureBuilder<String?>(
        future: SecureStorage.instance.getAccessToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final hasToken = snapshot.data != null;
          return hasToken ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();
  final _numberController = TextEditingController();
  final _dpiController = TextEditingController();
  final _textAreaController = TextEditingController();
  DateTime? _selectedDate;
  bool _isAccepted = false;
  String? _selectedOption;

  static const _radioOptions = [
    RadioOption(value: 'A', label: 'Opcion A'),
    RadioOption(value: 'B', label: 'Opcion B'),
    RadioOption(value: 'C', label: 'Opcion C'),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _textAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Notificacion de campo',
      subTitle: 'Componentes UI',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomInputText(value: _textController, label: 'Texto normal'),
          const SizedBox(height: 16),
          CustomInputNumber(
            value: _numberController,
            label: 'Numero',
            maxLength: 8,
            placeholder: 'Ingrese un numero...',
          ),
          const SizedBox(height: 16),
          CustomInputNumber(
            value: _dpiController,
            label: 'DPI',
            maxLength: 13,
            placeholder: 'Ingrese un DPI...',
            validator: (value) =>
                CuiValidator.validateDPI(value) ? 'Todo bien' : 'DPI invalido',
          ),
          const SizedBox(height: 16),
          CustomInputTextArea(
            value: _textAreaController,
            label: 'Descripcion',
            placeholder: 'Ingrese una descripcion...',
            maxLength: 200,
          ),
          const SizedBox(height: 16),
          CustomInputDate(
            selectedDate: _selectedDate,
            label: 'Selecciona la fecha',
            mode: DatePickerModeType.dayMonthYear,
            onDateSelected: (date) => setState(() => _selectedDate = date),
          ),
          const SizedBox(height: 8),
          CustomCheckbox(
            value: _isAccepted,
            label: 'Acepto los terminos y condiciones',
            onChanged: (v) => setState(() => _isAccepted = v ?? false),
          ),
          const SizedBox(height: 8),
          CustomRadioGroup<String>(
            label: 'Selecciona una opcion',
            options: _radioOptions,
            groupValue: _selectedOption,
            onChanged: (v) => setState(() => _selectedOption = v),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Button(
                  label: 'Info',
                  icon: Icons.info_outline,
                  onPressed: () => CustomAlertDialog.show(
                    context: context,
                    type: AlertType.info,
                    title: 'Informacion',
                    message:
                        'There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which dont look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isnt anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Button(
                  label: 'Exito',
                  icon: Icons.check_circle_outline,
                  onPressed: () => CustomAlertDialog.show(
                    context: context,
                    type: AlertType.success,
                    title: 'Exito',
                    message: 'La operacion se completo correctamente.',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Button(
                  label: 'Advertencia',
                  icon: Icons.warning_amber,
                  onPressed: () => CustomAlertDialog.show(
                    context: context,
                    type: AlertType.warning,
                    title: 'Advertencia',
                    message: 'Esta accion no se puede deshacer.',
                    cancelLabel: 'Cancelar',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Button(
                  label: 'Error',
                  icon: Icons.error_outline,
                  onPressed: () => CustomAlertDialog.show(
                    context: context,
                    type: AlertType.danger,
                    title: 'Error',
                    message: 'Ocurrio un error inesperado.',
                    cancelLabel: 'Cerrar',
                  ),
                ),
              ),
            ],
          ),
          
        ],
      ),
    );
  }
}

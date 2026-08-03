# Manual Flutter — de Vue/Dart a esta plantilla (Keycloak + APIs)

Escrito para alguien que ya sabe Dart y Vue, y tiene pocas horas para ponerse
productivo en Flutter. Cada sección tiene el concepto, el equivalente en Vue
(cuando aplica) y un ejemplo que puedes copiar directo a la plantilla.

---

## 0. Estado de la plantilla — qué se corrigió hoy

| # | Problema | Archivo | Estado |
|---|----------|---------|--------|
| 1 | Bypass de certificado SSL (`badCertificateCallback => true`) | `auth_service.dart` | ✅ Eliminado |
| 2 | `.env` commiteado en git con URL/IP internas reales | `.env` | ✅ Sacado del tracking, agregado a `.gitignore` |
| 3 | `print()` de usuario, contraseña y JWT decodificado | `login_screen.dart`, `secure_storage.dart`, `main.dart` | ✅ Eliminados |
| 4 | `dotenv.load()` nunca se llamaba → el `.env` real nunca se leía | `main.dart` | ✅ Agregado en `main()` |
| 5 | `test.json` y `otherMain.dart` sueltos en la raíz (con un JWT real de ejemplo) | raíz del repo | ✅ Eliminados |

Pendiente (decisión tuya, cubierto como guía en este manual, no aplicado
automáticamente):

- No hay gestor de estado ni capa de repositorio → sección 3 y 4.
- Login usa ROPC (usuario/contraseña directo) en vez de Authorization Code +
  PKCE → decidiste quedarte con ROPC por ahora; sección 6 explica cómo
  reforzarlo y cuándo migrar.
- `logout()` solo borra tokens locales, no invalida la sesión en Keycloak →
  ejemplo de fix en sección 6.4.

**Importante:** como `.env` ya estaba commiteado en un commit anterior
(`f4e0342`), sigue existiendo en el *historial* de git aunque ya no esté en el
HEAD actual. Si este repo tiene remoto compartido, avísame y vemos si vale la
pena reescribir historia (`git filter-repo`) — normalmente no vale la pena si
no había secretos reales (client secret, contraseñas), solo URLs/IPs internas.

---

## 1. Mapa mental: de Vue a Flutter

No estás empezando de cero. Casi todo tiene un equivalente directo:

| Vue | Flutter | Nota |
|---|---|---|
| Componente `.vue` | `Widget` (clase Dart) | Todo en Flutter es un widget, hasta el padding |
| `<template>` | método `build()` | Se re-ejecuta cada vez que el widget se "re-renderiza" |
| `ref()` / `reactive()` | `setState(() {...})` (local) o `Riverpod` (global) | Ver sección 4 |
| `computed()` | getter de Dart, o `ref.watch(provider.select(...))` en Riverpod | |
| Pinia store | `Provider`/`Notifier` de Riverpod | Sección 4 |
| `props` | parámetros del constructor | `const MyWidget({required this.title})` |
| `slots` | parámetro `Widget child` o `Widget? trailing` | |
| `v-if` | operador ternario o `if` dentro de una lista de children | |
| `v-for` | `.map((x) => Widget(...)).toList()` o `ListView.builder` | |
| `onMounted` | `initState()` | |
| `onUnmounted` | `dispose()` | **Obligatorio** liberar `TextEditingController`, streams, etc. |
| `vue-router` | `Navigator` (o `go_router` para rutas nombradas/deep links) | |
| `axios` + interceptors | `Dio` + `Interceptor` (ya lo tienes en `dio_client.dart`) | |
| `watch()` | `ref.listen()` en Riverpod, o `didUpdateWidget` | |

La diferencia mental más grande: en Vue el DOM se actualiza solo con
reactividad fina (un `ref` cambia → solo ese nodo se repinta). En Flutter,
`setState()` reconstruye **todo el subárbol** de ese widget hacia abajo — por
eso la estructura en widgets pequeños y la elección de gestor de estado
importan tanto para rendimiento como para mantenibilidad.

---

## 2. Los 20% de Flutter que usas el 80% del tiempo

### 2.1 Stateless vs Stateful

```dart
// Sin estado propio — como un componente Vue puramente de "props"
class Saludo extends StatelessWidget {
  final String nombre;
  const Saludo({super.key, required this.nombre});

  @override
  Widget build(BuildContext context) => Text('Hola, $nombre');
}

// Con estado propio — como un componente con ref() interno
class Contador extends StatefulWidget {
  const Contador({super.key});
  @override
  State<Contador> createState() => _ContadorState();
}

class _ContadorState extends State<Contador> {
  int _valor = 0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => setState(() => _valor++), // dispara rebuild
      child: Text('Valor: $_valor'),
    );
  }
}
```

Regla práctica: si el widget no cambia por sí mismo (solo recibe datos),
`StatelessWidget`. Si necesita recordar algo entre rebuilds (texto de un
input, si está cargando, etc.), `StatefulWidget` — o mejor, saca ese estado a
Riverpod (sección 4) en cuanto lo necesite otra pantalla.

### 2.2 Layout: los 6 widgets que resuelven el 90% de las pantallas

```dart
Column(              // como flex-direction: column
  children: [
    Row(              // como flex-direction: row
      children: [
        Expanded(child: Text('ocupa el espacio disponible')), // flex: 1
        Icon(Icons.star),
      ],
    ),
    Stack(            // como position: absolute dentro de un contenedor
      children: [Image.network('...'), Positioned(top: 8, right: 8, child: Icon(Icons.favorite))],
    ),
    SizedBox(height: 16), // como margin/gap
    Container(padding: EdgeInsets.all(12), child: Text('con padding/color/border')),
  ],
)
```

### 2.3 Listas — nunca uses `Column` para listas largas

```dart
// Mal para listas grandes: construye TODOS los items de una vez (como v-for sin virtualización)
Column(children: items.map((i) => ItemTile(i)).toList())

// Bien: solo construye lo que está en pantalla (virtualización automática)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemTile(items[index]),
)
```

### 2.4 Async + `BuildContext`: el error más común

En Vue no piensas en esto porque el componente no se puede "desmontar a
mitad de un await" de la misma forma. En Flutter, si el usuario navega hacia
atrás mientras tu `await` sigue esperando la API, el widget ya no existe y
usar `context` truena. Por eso este patrón (que ya usas en `login_screen.dart`)
es obligatorio siempre:

```dart
Future<void> _cargar() async {
  final data = await repo.getAlgo();
  if (!mounted) return; // <- SIEMPRE después de un await, antes de usar context/setState
  setState(() => _data = data);
}
```

### 2.5 `FutureBuilder` / `StreamBuilder`

Ya los usas en `main.dart` y `home_screen.dart` para pintar UI basada en un
`Future`. Es el equivalente a un `v-if="loading"` con datos async, pero
declarativo: le das el `Future` y un `builder` que recibe el `AsyncSnapshot`.
Bien para casos puntuales; para estado que varias pantallas comparten, usa
Riverpod (sección 4) en vez de repetir `FutureBuilder` por todos lados.

---

## 3. Arquitectura recomendada — para que sea reutilizable de verdad

Ahora mismo la plantilla separa por **tipo técnico**
(`presentation/screens`, `presentation/widgets`, `core/network`), lo cual
está bien para un proyecto chico. Cuando crezca (más de ~4-5 features), te
conviene separar también por **feature**, con capas dentro de cada una:

```
lib/
├── core/                        # Todo lo transversal, sin lógica de negocio
│   ├── network/
│   │   ├── api_client.dart      # Dio genérico y reutilizable (sección 5.1)
│   │   ├── auth_interceptor.dart
│   │   └── api_exception.dart   # Errores tipados (sección 5.3)
│   ├── storage/
│   │   └── secure_storage.dart
│   └── config/
│       └── env.dart             # Wrapper tipado sobre dotenv (sección 5.4)
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart      # Habla con Keycloak vía Dio
│   │   │   └── models/user_session.dart  # DTO: parsea el JWT a un objeto tipado
│   │   ├── domain/
│   │   │   └── auth_state.dart           # Riverpod Notifier (sección 4)
│   │   └── presentation/
│   │       └── login_screen.dart
│   │
│   └── packages/                # Ejemplo: tu PackageService actual
│       ├── data/
│       │   ├── package_repository.dart
│       │   └── models/package.dart
│       ├── domain/
│       │   └── packages_provider.dart
│       └── presentation/
│           └── packages_screen.dart
│
├── presentation/
│   └── widgets/ui/              # Tus componentes reutilizables (button, inputs...)
│                                 # Estos SÍ se quedan compartidos, no van en features/
└── main.dart
```

**Regla simple para decidir dónde va algo:**
- ¿Lo usan 2+ features y no sabe nada de negocio? → `core/`
- ¿Es específico de una pantalla o flujo de negocio? → `features/<nombre>/`
- ¿Es un componente visual puro y reutilizable (botón, input, modal)? →
  `presentation/widgets/ui/` (ya lo tienes bien ahí, no lo muevas)

Dentro de cada feature, las 3 capas:
- **data**: sabe hablar HTTP/JSON. Es la única capa que importa `Dio`.
- **domain**: la lógica de negocio y el estado (Riverpod). No sabe de widgets.
- **presentation**: solo widgets. Nunca llama a `Dio` directamente — siempre
  a través de `domain`.

Esto es exactamente lo que en Vue harías separando `services/`, `stores/`
(Pinia) y `components/` — mismo principio, nombres distintos.

---

## 4. Gestión de estado con Riverpod

`setState` está bien para estado que vive y muere en una sola pantalla (un
formulario, un toggle). En cuanto el estado lo necesita más de una pantalla
— como "¿hay sesión activa?" — necesitas algo como Pinia. En Flutter, el
estándar actual es **Riverpod**.

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.6.1
```

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: MyApp())); // como el app.use(pinia) de Vue
}
```

Ejemplo real: reemplazar el `FutureBuilder` de sesión en `main.dart` por un
estado de auth centralizado que cualquier pantalla puede leer:

```dart
// features/auth/domain/auth_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../core/storage/secure_storage.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  const AuthState(this.status);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AuthState(AuthStatus.loading)) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final token = await SecureStorage.instance.getAccessToken();
    state = AuthState(token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated);
  }

  Future<void> login(String username, String password) async {
    await _repo.login(username: username, password: password);
    state = const AuthState(AuthStatus.authenticated);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(AuthStatus.unauthenticated);
  }
}

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
```

```dart
// main.dart — MyApp ahora "escucha" el provider, como un computed de Pinia
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return MaterialApp(
      home: switch (auth.status) {
        AuthStatus.loading => const Scaffold(body: Center(child: CircularProgressIndicator())),
        AuthStatus.authenticated => const HomeScreen(),
        AuthStatus.unauthenticated => const LoginScreen(),
      },
    );
  }
}
```

```dart
// login_screen.dart — usar el provider en vez de instanciar AuthService directo
class LoginScreen extends ConsumerStatefulWidget { ... }

// dentro del State:
await ref.read(authProvider.notifier).login(usuario, password);
```

Con esto, **cualquier** pantalla puede hacer `ref.watch(authProvider)` y
reaccionar a login/logout sin pasar callbacks manualmente — igual que
`useAuthStore()` en Pinia.

### 4.1 ¿Y el paquete `provider`? ¿Es importante saberlo usar?

Vas a encontrarlo en casi todo tutorial y proyecto Flutter anterior a 2023,
así que sí conviene reconocerlo, aunque para código nuevo recomiendo
Riverpod (arriba). Son del mismo autor — Riverpod es literalmente la
segunda versión de `provider`, corrigiendo sus limitaciones.

| | `provider` | `Riverpod` |
|---|---|---|
| Cómo se lee el estado | `context.watch<T>()` — necesita `BuildContext` | `ref.watch(provider)` — no necesita `context` |
| Si te falta el provider arriba en el árbol | Explota en **runtime** (`ProviderNotFoundException`) | Imposible — lo atrapa el compilador |
| Se puede leer fuera de widgets (para tests, otro provider, etc.) | Difícil | Directo |
| Curva de aprendizaje | Un poco más simple al inicio | Un poco más de "magia" al inicio (`ref`, generación de código opcional) |
| Estado del paquete | Estable, mantenimiento, no crecimiento | El que se sigue desarrollando activamente |

**Mi recomendación para tu plantilla:** usa Riverpod (sección 4). Pero si en
algún momento heredas un proyecto o sigues un tutorial que usa `provider`,
así se ve el mismo ejemplo de `AuthNotifier` con `provider` para que lo
reconozcas:

```yaml
# pubspec.yaml
dependencies:
  provider: ^6.1.2
```

```dart
// features/auth/domain/auth_notifier.dart
// Con provider, tu estado extiende ChangeNotifier en vez de StateNotifier
class AuthNotifier extends ChangeNotifier {
  final AuthRepository _repo;
  AuthNotifier(this._repo) {
    _checkSession();
  }

  AuthStatus status = AuthStatus.loading;

  Future<void> _checkSession() async {
    final token = await SecureStorage.instance.getAccessToken();
    status = token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners(); // <- avisa manualmente a quien esté escuchando (Riverpod lo hace solo)
  }

  Future<void> login(String username, String password) async {
    await _repo.login(username: username, password: password);
    status = AuthStatus.authenticated;
    notifyListeners();
  }
}
```

```dart
// main.dart — se registra "arriba" del árbol con un widget, no con un provider global
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthNotifier(AuthRepository()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>(); // necesita context, a diferencia de ref.watch
    return MaterialApp(
      home: switch (auth.status) {
        AuthStatus.loading => const Scaffold(body: Center(child: CircularProgressIndicator())),
        AuthStatus.authenticated => const HomeScreen(),
        AuthStatus.unauthenticated => const LoginScreen(),
      },
    );
  }
}
```

```dart
// login_screen.dart
await context.read<AuthNotifier>().login(usuario, password);
// read() en vez de watch(): dispara la acción sin "suscribirse" a rebuilds
```

La trampa más común de `provider` para quien viene de Vue: `context.watch`
solo funciona dentro de `build()`. Si lo llamas dentro de un callback
(`onPressed: () => context.watch<...>()`) truena — ahí siempre usas
`context.read<...>()`. Riverpod no tiene esta distinción tan delicada.

---

## 5. Consumo de APIs de forma limpia

### 5.1 Un `ApiClient` genérico en vez de repetir `_buildClient`

Ahora mismo `dio_client.dart` crea **un solo** Dio global (`useApi`) atado a
`API_URL_BASE`. El día que necesites hablar con un segundo servicio (otro
microservicio del Ministerio, por ejemplo), vas a querer poder crear más de
uno sin copiar/pegar. Hazlo una función reutilizable:

```dart
// core/network/api_client.dart
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient({
    required String baseUrl,
    List<Interceptor> interceptors = const [],
    Duration connectTimeout = const Duration(seconds: 5),
    Duration receiveTimeout = const Duration(seconds: 8),
  }) : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          responseType: ResponseType.json,
        )) {
    dio.interceptors.addAll(interceptors);
    assert(() {
      // LogInterceptor solo en debug — nunca en release (evita fugas de datos en logs)
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
      return true;
    }());
  }
}
```

```dart
// core/network/service_locator.dart (uno por backend que consumas)
final apiPrincipal = ApiClient(
  baseUrl: dotenv.env['API_URL_BASE']!,
  interceptors: [AuthInterceptor(AuthService())],
).dio;

final apiReportes = ApiClient(
  baseUrl: dotenv.env['API_REPORTES_BASE']!,
  interceptors: [AuthInterceptor(AuthService())], // mismo token si comparten Keycloak
).dio;
```

`assert(() {...}())` es un truco de Dart: ese bloque **solo corre en modo
debug** (los `assert` se eliminan por completo en `flutter build --release`),
así que es la forma correcta de tener logging verboso sin arriesgarte a que
se cuele a producción — a diferencia de los `print()` que quitamos hoy.

### 5.2 Repository pattern — la pantalla nunca debe llamar a `Dio` directo

```dart
// features/packages/data/models/package.dart
class PackageModel {
  final String name;
  final String version;
  const PackageModel({required this.name, required this.version});

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
        name: json['name'] as String,
        version: json['version'] as String,
      );
}

// features/packages/data/package_repository.dart
class PackageRepository {
  final Dio _dio;
  PackageRepository(this._dio);

  Future<List<PackageModel>> getPackages({int page = 1}) async {
    final res = await _dio.get('/packages', queryParameters: {'page': page});
    final list = res.data['packages'] as List<dynamic>;
    return list.map((e) => PackageModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
```

La pantalla solo conoce `PackageRepository`, nunca `Dio` ni la URL. Esto es
lo que te permite:
- Reusar la misma pantalla con datos mockeados en tests.
- Cambiar de Dio a otra librería sin tocar UI.
- Tener un solo lugar donde vive el "shape" de los datos (el DTO).

### 5.3 Errores tipados — no dejes que `DioException` llegue a la UI

```dart
// core/network/api_exception.dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    final backendMsg = data is Map ? data['error_description'] ?? data['message'] : null;
    return ApiException(
      backendMsg as String? ?? 'No se pudo completar la operación',
      statusCode: e.response?.statusCode,
    );
  }
}
```

```dart
// en el repository, envuelve las llamadas:
try {
  final res = await _dio.get('/packages');
  ...
} on DioException catch (e) {
  throw ApiException.fromDio(e);
}
```

Así la pantalla hace `catch (e) { if (e is ApiException) show(e.message) }`
sin conocer nada de Dio — igual que envolver `axios` en un `try/catch` con un
`error.response.data.message` centralizado en tu capa de servicios de Vue.

### 5.4 `.env` tipado en vez de `dotenv.env['X']` repartido por el código

```dart
// core/config/env.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get clientId => dotenv.env['CLIENT_ID'] ?? (throw Exception('Falta CLIENT_ID en .env'));
  static String get realm => dotenv.env['REALM'] ?? (throw Exception('Falta REALM en .env'));
  static String get keycloakBase => dotenv.env['KEYCLOAK_BASE'] ?? (throw Exception('Falta KEYCLOAK_BASE en .env'));
  static String get apiUrlBase => dotenv.env['API_URL_BASE'] ?? (throw Exception('Falta API_URL_BASE en .env'));
}
```

Beneficio real: si falta una variable, truena **al arrancar la app** con un
mensaje claro, en vez de silenciosamente pegarle a `localhost:8080` como pasa
hoy con los `?? 'localhost:8080'` (que además fue lo que ocultó el bug del
`dotenv.load()` faltante — con esto no se hubiera podido esconder).

---

## 6. Keycloak — reforzando ROPC (decisión actual) y qué viene después

### 6.1 Cómo funciona el flujo que ya tienes (Resource Owner Password Credentials)

```
App                                Keycloak
 │  POST /realms/Interno/protocol/openid-connect/token
 │  grant_type=password&client_id=igt-client&username=...&password=...
 ├──────────────────────────────────────────────────────>│
 │                                    access_token (JWT, ~5-15 min)
 │                                    refresh_token (horas/días)
 │<──────────────────────────────────────────────────────┤
 │  Guarda ambos en flutter_secure_storage (Keychain/Keystore) │
```

Es el flujo más simple de implementar (por eso lo tienes), pero tu app ve la
contraseña en texto plano y no hay soporte nativo para MFA. Como ya
decidiste quedarte con esto (el client de Keycloak del backend probablemente
ya está fijo así), estos son los refuerzos que sí dependen de ti:

### 6.2 Checklist de hardening para ROPC (aplicable ya)

- ✅ **HTTPS siempre** — tu `KEYCLOAK_BASE` ya usa `https://`, y ya quitamos
  el bypass de certificado, así que ahora si el certificado del servidor no
  es válido, la conexión falla en vez de aceptarlo silenciosamente. Eso es
  lo correcto.
- ✅ **Nunca loggear password/token** — ya quitado hoy.
- **Verifica expiración del token, no solo su presencia.** Ahora mismo
  `main.dart` solo revisa si hay un `access_token` guardado, no si ya
  expiró. Decodifica el `exp` del JWT y compáralo con la hora actual:

  ```dart
  bool isExpired(String jwt) {
    final parts = jwt.split('.');
    final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
    final exp = payload['exp'] as int;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= exp;
  }
  ```

  Si expiró, intenta `refreshAccessToken()` antes de decidir si mandas al
  usuario a `LoginScreen` — hoy solo el interceptor de un request fallido
  (401) dispara el refresh; la pantalla inicial no lo hace.
- **No captures el `TextEditingController` de la contraseña más tiempo del
  necesario.** Ya lo dispones bien (`dispose()` en login), solo ten cuidado
  de no guardar `password` en ningún log de crash reporting (Sentry,
  Crashlytics) si lo agregas más adelante — filtra ese campo explícitamente.

### 6.3 Client público, no confidencial

Confirma en el admin de Keycloak que `igt-client` es **público**
(`Access Type: public`, sin `client secret`). Un client secret **nunca**
debe vivir dentro de una app móvil — cualquiera puede descompilar el APK y
extraerlo. Como tu `.env` no trae `CLIENT_SECRET`, probablemente ya está
bien configurado así; solo confírmalo.

### 6.4 `logout()` hoy no cierra sesión en el servidor

```dart
// Actual: solo borra tokens del dispositivo.
// El refresh_token sigue siendo válido en Keycloak hasta que expire solo.
Future<void> logout() => SecureStorage.instance.clearTokens();
```

Mejora recomendada — revocar también del lado del servidor:

```dart
Future<void> logout() async {
  final refreshToken = await SecureStorage.instance.getRefreshToken();
  if (refreshToken != null) {
    try {
      await _dio.post(
        '$_keycloakBase/realms/$_realm/protocol/openid-connect/logout',
        data: {'client_id': _clientId, 'refresh_token': refreshToken},
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );
    } catch (_) {
      // si falla la llamada de red, igual limpiamos localmente
    }
  }
  await SecureStorage.instance.clearTokens();
}
```

Esto importa en un caso concreto: si un dispositivo se pierde o se comparte,
"cerrar sesión" localmente no evita que ese refresh_token siga siendo
canjeable por quien lo tenga.

### 6.5 Cuándo migrar a Authorization Code + PKCE

Vale la pena moverse a PKCE cuando:
- Necesiten login social o MFA administrado por Keycloak.
- Quieran que la app nunca vea la contraseña (útil para auditorías de
  seguridad gubernamentales).

Se hace con el paquete [`flutter_appauth`](https://pub.dev/packages/flutter_appauth):
abre el navegador/webview del sistema, el usuario mete su contraseña ahí (no
en tu app), y Keycloak te regresa un código que canjeas por tokens. Requiere
que el client en Keycloak tenga configurado un `redirect_uri` tipo
`com.example.plantilla://callback`. Cuando llegue el momento, pídeme el
ejemplo completo — no lo desarrollo aquí para no invertir horas en algo que
no vas a usar todavía.

---

## 7. Checklist de seguridad — repásalo antes de cada release

- [ ] `.env` no está en git (`git ls-files | grep .env` no debe mostrar
      `.env`, solo `.env.template`)
- [ ] Cero `print()` con datos sensibles (usuario, password, token, JWT
      decodificado) — usa un logger que se desactive en release si necesitas
      debug (`if (kDebugMode) print(...)`)
- [ ] Cero bypass de certificados (`badCertificateCallback`) en ningún
      `HttpClient`
- [ ] Todas las URLs de backend usan `https://`, nunca `http://` en
      producción (ojo: tu `API_URL_BASE` actual en `.env` es `http://` a una
      IP interna — válido si es una red interna/VPN cerrada del Ministerio,
      pero verifícalo)
- [ ] `flutter_secure_storage` (ya usado) en vez de `SharedPreferences` para
      tokens — correcto, no cambiar
- [ ] El cliente de Keycloak es `public`, sin `client_secret` embebido
- [ ] `logout()` revoca también en el servidor (sección 6.4)
- [ ] Nunca commitear archivos de ejemplo con tokens/JWTs reales
      (como el `test.json` que se eliminó)

---

## 8. Para practicar ya con lo que tienes en la plantilla

1. Corre la app tal cual quedó (`flutter run`) y confirma que el login
   contra Keycloak sigue funcionando — el `.env` local no se tocó, solo se
   dejó de trackear en git.
2. Implementa `PackageRepository` (sección 5.2) usando el `PackageService`
   que ya existe como referencia, y consúmelo desde una pantalla nueva con
   `ListView.builder` (sección 2.3).
3. Agrega Riverpod (sección 4) y migra el `FutureBuilder` de sesión en
   `main.dart` a `authProvider`.
4. Implementa la verificación de expiración del token (sección 6.2) antes de
   decidir `HomeScreen` vs `LoginScreen`.
5. Cuando tengas un segundo endpoint que consumir, usa `ApiClient` (sección
   5.1) en vez de copiar `dio_client.dart` — esa es la prueba de que la capa
   quedó realmente reutilizable.

## 9. Referencias rápidas

- Flutter widgets catalog: https://docs.flutter.dev/ui/widgets
- Riverpod docs: https://riverpod.dev
- Dio (interceptors, errores): https://pub.dev/packages/dio
- Keycloak Token Endpoint: https://www.keycloak.org/docs/latest/securing_apps/#token-endpoint
- flutter_appauth (para cuando migren a PKCE): https://pub.dev/packages/flutter_appauth

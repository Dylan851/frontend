# AnimalGO - RPG educativo de animales

Flutter + Bonfire 3.16 · Landscape · mapas Tiled JSON.

---

## Ejecutar en local paso a paso

Esta es la forma recomendada para arrancar el frontend contra el backend local.

### 1. Levantar primero el backend

Desde el repositorio `backend`, arranca la API en:

```text
http://localhost:8000
```

En esta configuracion, el backend corre en local pero sigue usando la base de
datos y la autenticacion en la nube.

### 2. Comprobar Flutter

```bash
flutter doctor
```

### 3. Descargar dependencias

```bash
flutter pub get
```

### 4. Lanzar el frontend segun el dispositivo

#### Web

```bash
flutter run -d chrome --web-port 8080 --dart-define=API_BASE_URL=http://localhost:8000
```

#### Android Emulator

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

#### Movil fisico

```bash
flutter run --dart-define=API_BASE_URL=http://IP_DEL_PC:8000
```

Sustituye `IP_DEL_PC` por la IP local del ordenador donde corre el backend.

### 5. Variables opcionales

Solo hacen falta si quieres probar login con Google / Supabase o Stripe desde
el frontend:

```bash
--dart-define=SUPABASE_URL=...
--dart-define=SUPABASE_ANON_KEY=...
--dart-define=STRIPE_PUBLISHABLE_KEY=...
```

### 6. Nota importante sobre CORS

Para web local, usa preferiblemente `--web-port 8080`, porque el backend ya
acepta ese origen por defecto.

---

## Ejecucion rapida

```bash
flutter pub get
flutter run
```

### Android

Si necesitas deshabilitar Impeller, anade esto en
`android/app/src/main/AndroidManifest.xml` dentro de `<application>`:

```xml
<meta-data
  android:name="io.flutter.embedding.android.EnableImpeller"
  android:value="false"/>
```

### Web

```bash
flutter build web --web-renderer=canvaskit
```

---

## Estructura del proyecto

```text
animalgo_game/
├── assets/
│   ├── images/
│   │   ├── player/
│   │   ├── tiles/
│   │   ├── animals/
│   │   └── backgrounds/
│   ├── audio/
│   │   └── animals/
│   └── maps/
└── lib/
    ├── main.dart
    ├── router/app_router.dart
    ├── data/
    ├── screens/
    ├── services/
    ├── theme/
    └── game/
```

---

## Tests

```bash
flutter test
```

Suites destacadas:

- `test/router/app_router_test.dart`
- `test/services/stripe_payment_service_test.dart`
- `test/data/`
- `test/widgets/`

---

## Dependencias clave

```yaml
bonfire: ^3.16.1
flame: ^1.32.0
shared_preferences: ^2.2.2
flutter_stripe: ^11.5.0
supabase_flutter: ^2.8.0
```

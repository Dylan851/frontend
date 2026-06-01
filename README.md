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

### 7. Prueba de pagos con Stripe

Para probar la compra de monedas o diamantes en entorno local, el backend debe
estar arrancado en `http://localhost:8000` y el frontend en `http://localhost:8080`.

El backend debe tener configuradas las claves de Stripe en modo prueba dentro de
`backend/.env`:

```env
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
FRONTEND_URL=http://localhost:8080
```

Para que Stripe confirme la compra al backend local y se actualicen las monedas
o diamantes, ejecuta Stripe CLI en otra terminal:

```bash
stripe listen --forward-to localhost:8000/stripe/webhook
```

Stripe mostrara un valor parecido a `whsec_...`. Ese valor debe copiarse en
`STRIPE_WEBHOOK_SECRET` y despues reiniciar el backend.

En Stripe Checkout se puede usar cualquier correo de prueba, por ejemplo:

```text
test@animalgo.com
```

Tarjeta de prueba para pago correcto:

```text
Numero: 4242 4242 4242 4242
Fecha: 12/34
CVC: 123
Nombre: Test AnimalGO
Codigo postal: 28001
```

No usar tarjetas reales. Esta tarjeta solo funciona con claves de prueba
`sk_test_...` y `pk_test_...`.

---

## Ejecucion rapida

```bash
flutter pub get
flutter run
```


## Crear APK Android

Antes de crear el APK, descarga las dependencias:

```bash
flutter pub get
```

### APK de prueba

Genera un APK de prueba con:

```bash
flutter build apk --debug
```

El archivo generado queda en:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

### APK de release

Genera un APK optimizado con:

```bash
flutter build apk --release
```

El archivo generado queda en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### APK conectado al backend local

Si el APK se va a probar contra el backend local, hay que indicar la URL correcta del backend al compilar.

Para Android Emulator:

```bash
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Para movil fisico conectado a la misma red que el ordenador:

```bash
flutter build apk --debug --dart-define=API_BASE_URL=http://IP_DEL_PC:8000
```

Sustituye `IP_DEL_PC` por la IP local del ordenador donde esta arrancado el backend.

### Instalar el APK en un dispositivo

Con un dispositivo Android conectado por USB o un emulador abierto:

```bash
flutter install
```

Tambien se puede instalar manualmente el archivo `.apk` generado desde la carpeta `build/app/outputs/flutter-apk/`.

Si necesitas Stripe dentro del APK, compila anadiendo tambien la clave publica de Stripe en modo prueba:

```bash
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000 --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
```

---
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

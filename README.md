# SecureNotes — Proyecto Final U2

Aplicación móvil Flutter con Firebase y consulta de clima en tiempo real.

## Funcionalidades
- Login / Registro con Firebase Authentication (credenciales reales)
- Notas almacenadas en Firestore, separadas por usuario
- Editar y eliminar notas, con recordatorio opcional
- Pantalla de clima para Durango, Coahuila y Nuevo León (OpenWeatherMap)

---

## Requisitos previos
- Flutter SDK instalado
- Cuenta de Firebase (gratuita)
- API Key de OpenWeatherMap (gratuita, sin tarjeta)

---

## Pasos para correr el proyecto

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Configurar Firebase Authentication
En la consola de Firebase (console.firebase.google.com):
1. Ve a **Authentication → Sign-in method**
2. Activa **Email/Password**

Firestore ya está configurado en tu proyecto.
Las reglas de Firestore deben permitir lectura/escritura autenticada:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/notes/{noteId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. Obtener API Key de OpenWeatherMap (gratis, sin tarjeta)
1. Regístrate en https://openweathermap.org/api
2. Ve a **My API Keys** y copia tu key
3. Abre `lib/services/weather_service.dart`
4. Reemplaza `'TU_API_KEY_AQUI'` con tu key

### 4. Correr la app
```bash
flutter run
```

---

## Credenciales de prueba
Puedes crear una cuenta directamente desde la pantalla de Login tocando **"¿No tienes cuenta? Regístrate"**.

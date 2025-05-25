#include <WiFi.h>
#include <WebServer.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <ArduinoJson.h>

// WiFi credentials
const char* ssid = "DALAY ANAHI_PLANTA ALTA";
const char* password = "0705640969";

// Dirección de tu backend (debe tener SSL válido)
const char* backend_url = "http://192.168.1.194:5000"; // sin HTTPS si es local

const int LED_VERDE = 2;
const int LED_ROJO  = 23;

WebServer server(80);

void apagarLEDs() {
  delay(2000);
  digitalWrite(LED_VERDE, LOW);
  digitalWrite(LED_ROJO, LOW);
}

bool validarConServidor(String llave, String usuario_id) {
  HTTPClient http;
  String endpoint = String(backend_url) + "/validar-llave";
  http.begin(endpoint);  // sin cliente SSL

  http.addHeader("Content-Type", "application/json");

  String jsonPayload = "{\"llave\": \"" + llave + "\", \"usuario_id\": \"" + usuario_id + "\"}";
  int httpResponseCode = http.POST(jsonPayload);

  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println("🔐 Respuesta validación: " + response);
    http.end();
    return response.indexOf("autorizado") != -1;
  } else {
    Serial.println("❌ Error en conexión HTTP");
    http.end();
    return false;
  }
}

void registrarEvento(String usuario_id, String estado) {
  HTTPClient http;
  String endpoint = String(backend_url) + "/registrar-evento";
  http.begin(endpoint);  // sin cliente SSL

  http.addHeader("Content-Type", "application/json");

  String jsonPayload = "{\"usuario_id\": \"" + usuario_id + "\", \"estado\": \"" + estado + "\"}";
  int httpResponseCode = http.POST(jsonPayload);

  if (httpResponseCode > 0) {
    String response = http.getString();
    Serial.println("📝 Evento registrado: " + response);
  } else {
    Serial.println("❌ Error al registrar evento");
  }

  http.end();
}

void handleRecibirOTP() {
  if (!server.hasArg("plain")) {
    server.send(400, "text/plain", "Solicitud inválida: sin cuerpo JSON.");
    return;
  }

  String body = server.arg("plain");
  StaticJsonDocument<256> doc;
  DeserializationError error = deserializeJson(doc, body);

  if (error) {
    server.send(400, "application/json", "{\"estado\": \"error_parseo\"}");
    return;
  }

  String llave = doc["llave"];
  String usuario_id = doc["usuario_id"];

  Serial.println("📩 OTP recibida: " + llave + " del usuario " + usuario_id);

  bool autorizado = validarConServidor(llave, usuario_id);

  if (autorizado) {
    digitalWrite(LED_VERDE, HIGH);
    digitalWrite(LED_ROJO, LOW);
    server.send(200, "application/json", "{\"estado\": \"autorizado\"}");
    Serial.println("✅ Acceso autorizado");
    registrarEvento(usuario_id, "autorizado");
  } else {
    digitalWrite(LED_VERDE, LOW);
    digitalWrite(LED_ROJO, HIGH);
    server.send(200, "application/json", "{\"estado\": \"denegado\"}");
    Serial.println("❌ Acceso denegado");
    registrarEvento(usuario_id, "denegado");
  }

  apagarLEDs();
}

void setup() {
  Serial.begin(115200);

  pinMode(LED_VERDE, OUTPUT);
  pinMode(LED_ROJO, OUTPUT);
  digitalWrite(LED_VERDE, LOW);
  digitalWrite(LED_ROJO, LOW);

  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\n✅ Conectado a WiFi.");
  Serial.print("📡 IP del ESP32: ");
  Serial.println(WiFi.localIP());

  server.on("/recibir-otp", HTTP_POST, handleRecibirOTP);
  server.begin();
  Serial.println("🌐 Servidor HTTP iniciado en /recibir-otp");
}

void loop() {
  server.handleClient();
}

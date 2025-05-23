#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>

const char* ssid = "DALAY ANAHI_PLANTA ALTA";
const char* password = "0705640969";
const String OTP_VALIDO = "123456";

const int LED_VERDE = 2;  // Pin GPIO16
const int LED_ROJO  = 23;  // Pin GPIO17


WebServer server(80);  // Puerto 80 por defecto

void handleRecibirOTP() {
  if (server.hasArg("plain") == false) {
    server.send(400, "text/plain", "Solicitud inválida: sin cuerpo JSON.");
    return;
  }

  String body = server.arg("plain");
  StaticJsonDocument<200> json;
  DeserializationError error = deserializeJson(json, body);

  if (error) {
    server.send(400, "application/json", "{\"estado\": \"error_parseo\"}");
    return;
  }

  String llave = json["llave"];
  String usuario_id = json["usuario_id"];

  Serial.println("📩 OTP recibida: " + llave + " del usuario " + usuario_id);

  if (llave == OTP_VALIDO) {
    digitalWrite(LED_VERDE, HIGH);  // ✅ LED verde ON
    digitalWrite(LED_ROJO, LOW);   // ❌ LED rojo OFF
    server.send(200, "application/json", "{\"estado\": \"autorizado\"}");
    Serial.println("✅ OTP válida");
  } else {
    digitalWrite(LED_VERDE, LOW);   // ✅ LED verde OFF
    digitalWrite(LED_ROJO, HIGH);   // ❌ LED rojo ON
    server.send(200, "application/json", "{\"estado\": \"denegado\"}");
    Serial.println("❌ OTP inválida");
  }
  // ⏱ Apagar LEDs tras 3 segundos
  delay(2000);
  digitalWrite(LED_VERDE, LOW);
  digitalWrite(LED_ROJO, LOW);
}

void setup() {
  Serial.begin(115200);

  pinMode(LED_VERDE, OUTPUT);
  pinMode(LED_ROJO, OUTPUT);
  digitalWrite(LED_VERDE, LOW);
  digitalWrite(LED_ROJO, LOW);

  WiFi.begin(ssid, password);
  Serial.print("Conectando a WiFi...");

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

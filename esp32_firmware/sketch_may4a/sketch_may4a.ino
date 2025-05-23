#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

BLECharacteristic *pCharacteristic;
bool deviceConnected = false;

// UUIDs personalizados para el servicio y característica
#define SERVICE_UUID        "12345678-1234-5678-1234-56789abcdef0"
#define CHARACTERISTIC_UUID "12345678-1234-5678-1234-56789abcdef1"

void setup() {
  Serial.begin(115200);
  BLEDevice::init("ESP32_Device");  // Nombre del dispositivo BLE
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  
  // Crear servicio BLE
  BLEService *pService = pServer->createService(SERVICE_UUID);
  
  // Crear característica BLE
  pCharacteristic = pService->createCharacteristic(
                       CHARACTERISTIC_UUID,
                       BLECharacteristic::PROPERTY_READ |
                       BLECharacteristic::PROPERTY_WRITE
                     );
  pCharacteristic->setValue("Initial Value");

  // Iniciar servicio BLE
  pService->start();
  
  // Iniciar publicidad BLE para permitir que la app se conecte
  BLEAdvertising *pAdvertising = pServer->getAdvertising();
  pAdvertising->start();
  Serial.println("Esperando conexiones...");
}

void loop() {
  if (deviceConnected) {
    // Aquí puedes hacer algo con la llave OTP recibida
    String otpKey = pCharacteristic->getValue().c_str();
    Serial.println("Llave OTP recibida: " + otpKey);
  }
  delay(1000);
}

// Clase para manejar las conexiones del servidor BLE
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
  }

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
  }
};


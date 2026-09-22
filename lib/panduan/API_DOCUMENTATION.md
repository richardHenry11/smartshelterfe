# 📡 Dokumentasi Lengkap API, WebSocket & MQTT — Smart Shelter

Dokumentasi ini dibuat sebagai panduan integrasi bagi tim pengembang **Web Frontend / Dashboard** dengan backend Smart Shelter.

---

## 📑 Daftar Isi
1. [Konfigurasi Host & Base URL](#1-konfigurasi-host--base-url)
2. [Arsitektur Multi-Tenant & Entitas Data](#2-arsitektur-multi-tenant--entitas-data)
3. [REST API Endpoints](#3-rest-api-endpoints)
   - [3.1 Autentikasi: Registrasi User](#31-post-register)
   - [3.2 Autentikasi: Login](#32-post-login)
   - [3.3 Shelter: Mendapatkan Daftar Shelter](#33-get-shelters)
   - [3.4 Shelter: Update Lokasi, Geofence & Nama](#34-put-sheltersid)
   - [3.5 Sensor: Riwayat Grafik Sensor (Historical 30-Menit)](#35-get-sensorhistorysensor_type)
   - [3.6 User: Upload Foto Profil](#36-post-useravatar)
   - [3.7 User: Hapus Foto Profil](#37-delete-useravatar)
   - [3.8 Admin: Trigger Agregasi Manual](#38-post-adminaggregate)
   - [3.9 Static Asset: URL Foto Profil](#39-static-files-url-foto-profil)
4. [Realtime WebSocket (Sensors & Actuators)](#4-realtime-websocket)
   - [Koneksi WebSocket](#koneksi-websocket)
   - [Format Data Telemetri Masuk (Server -> Web)](#format-data-telemetri-masuk-server---web)
   - [Format Perintah Kontrol Keluar (Web -> Server)](#format-perintah-kontrol-keluar-web---server)
5. [MQTT Protocol & Topics (IoT Layer)](#5-mqtt-protocol--topics-iot-layer)
   - [Topik Sensor Telemetri](#topik-sensor-telemetri-perangkat---server)
   - [Topik Perintah Aktuator](#topik-perintah-aktuator-server---perangkat)
6. [Contoh Integrasi JavaScript / TypeScript](#6-contoh-integrasi-javascript--typescript)

---

## 1. Konfigurasi Host & Base URL

| Lingkungan | Protokol HTTP (REST API) | Protokol WebSocket |
| :--- | :--- | :--- |
| **Production (Domain)** | `https://shelter.cbinstrument.com` | `wss://shelter.cbinstrument.com` |
| **Local / Direct LAN** | `http://192.168.1.76:1104` | `ws://192.168.1.76:1104` |

**MQTT Broker:**
- Host: `shelter.cbinstrument.com` (atau `localhost` di sisi server)
- Port: `1883` (TCP Plain) / `8883` (jika TLS aktif)

---

## 2. Arsitektur Multi-Tenant & Entitas Data

1. **Tenant (`tenants`)**: Perusahaan / penyewa shelter (contoh: `TENANT-01`, `TENANT-02`).
2. **User (`users`)**: Akun pengguna terikat ke 1 Tenant dan memiliki Role (`admin` atau `user`).
3. **Shelter (`shelters`)**: Fasilitas fisik yang dipantau (contoh: `SHELTER-01`, `SHELTER-02`), terikat ke 1 Tenant.
4. **Sensor**: Parameter pengukuran (contoh: `temperature`, `humidity`, `nh4`, `o2`, `co2`, `door`, `pump`, `fan`, `light`).

---

## 3. REST API Endpoints

### 3.1 `POST /register`
Digunakan untuk mendaftarkan akun user baru ke database server.

- **URL:** `/register`
- **Method:** `POST`
- **Headers:** `Content-Type: application/json`
- **Request Body:**
```json
{
  "username": "operator1",
  "password": "mypassword123",
  "role": "user",
  "tenant_id": "TENANT-01"
}
```
> Catatan: Jika `role` tidak diisi, default adalah `"user"`. Jika `tenant_id` tidak diisi, default adalah `"TENANT-01"`. Panjang username dan password minimal 3 karakter.

- **Response Success (`201 Created` / `200 OK`):**
```json
{
  "message": "User registered successfully",
  "username": "operator1",
  "tenant_id": "TENANT-01"
}
```

- **Response Error Duplicate (`400 Bad Request`):**
```json
{
  "detail": "Username already exists"
}
```

---

### 3.2 `POST /login`
Digunakan untuk autentikasi user ke sistem.

- **URL:** `/login`
- **Method:** `POST`
- **Headers:** `Content-Type: application/json`
- **Request Body:**
```json
{
  "username": "coki",
  "password": "c123"
}
```

- **Response Success (`200 OK`):**
```json
{
  "message": "Login successful happy adventure :)",
  "role": "admin",
  "tenant_id": "TENANT-01",
  "foto_profile": "/uploads/avatars/coki_1727000000.jpg",
  "shelters": [
    {
      "id": "SHELTER-01",
      "tenant_id": "TENANT-01",
      "name": "Shelter PT. Cakra",
      "latitude": -6.9024,
      "longitude": 107.6187,
      "geofence_radius": 100
    },
    {
      "id": "SHELTER-02",
      "tenant_id": "TENANT-01",
      "name": "Shelter Site Beta",
      "latitude": -6.914744,
      "longitude": 107.60981,
      "geofence_radius": 150
    }
  ]
}
```

- **Response Error (`401 Unauthorized`):**
```json
{
  "detail": "Invalid username or password"
}
```

---

### 3.2 `GET /shelters`
Mengambil daftar shelter yang tersedia. Dapat difilter berdasarkan `tenant_id`.

- **URL:** `/shelters`
- **Method:** `GET`
- **Query Params:**
  - `tenant_id` *(opsional)*: Filter shelter untuk tenant tertentu (contoh: `?tenant_id=TENANT-01`). Jika tidak diisi, backend mengembalikan seluruh shelter.

- **Response (`200 OK`):**
```json
{
  "shelters": [
    {
      "id": "SHELTER-01",
      "tenant_id": "TENANT-01",
      "name": "Shelter PT. Cakra",
      "latitude": -6.9024,
      "longitude": 107.6187,
      "geofence_radius": 100
    },
    {
      "id": "SHELTER-02",
      "tenant_id": "TENANT-02",
      "name": "Shelter PT. Leuwitex Indojaya",
      "latitude": -6.914744,
      "longitude": 107.60981,
      "geofence_radius": 150
    }
  ]
}
```

---

### 3.3 `PUT /shelters/:id`
Memperbarui konfigurasi shelter (Nama, Koordinat GPS, atau Radius Geofence).

- **URL:** `/shelters/:id` (contoh: `/shelters/SHELTER-01`)
- **Method:** `PUT`
- **Headers:** `Content-Type: application/json`
- **Request Body (semua field opsional):**
```json
{
  "name": "Shelter PT. Cakra",
  "latitude": -6.9024,
  "longitude": 107.6187,
  "geofence_radius": 150.0
}
```

- **Response Success (`200 OK`):**
```json
{
  "message": "Shelter location updated successfully",
  "shelter": {
    "id": "SHELTER-01",
    "tenant_id": "TENANT-01",
    "name": "Shelter PT. Cakra",
    "latitude": -6.9024,
    "longitude": 107.6187,
    "geofence_radius": 150
  }
}
```

---

### 3.4 `GET /sensor/history/:sensor_type`
Mengambil data historis rata-rata sensor per 30 menit (dari tabel agregasi `average_value`) untuk keperluan grafik/chart garis.

- **URL:**
  - `/sensor/history/:sensor_type` (Query param: `shelter_id`)
  - atau `/shelter/:shelter_id/sensor/history/:sensor_type`
- **Method:** `GET`
- **URL Params:**
  - `:sensor_type`: Nama sensor (contoh: `nh4`, `o2`, `temperature`, `humidity`, `co2`).
- **Query Params:**
  - `shelter_id` *(opsional, default: `SHELTER-01`)*: ID Shelter target.
  - `limit` *(opsional, default: `24`)*: Jumlah titik riwayat data.
  - `interval_minutes` *(opsional, default: `30`)*.

- **Response (`200 OK`):**
```json
{
  "shelter_id": "SHELTER-01",
  "sensor_type": "nh4",
  "interval_minutes": 30,
  "source": "average_value",
  "history": [
    {
      "value": 4.82,
      "created_at": "2026-09-22 09:30:00"
    },
    {
      "value": 4.96,
      "created_at": "2026-09-22 10:00:00"
    },
    {
      "value": 5.01,
      "created_at": "2026-09-22 10:30:00"
    }
  ]
}
```
*(Catatan: Urutan data `history` diurutkan secara kronologis dari terlama ke terbaru).*

---

### 3.5 `POST /user/avatar`
Upload foto profil user. File akan disimpan di storage backend dan URL-nya disimpan ke database user.

- **URL:** `/user/avatar`
- **Method:** `POST`
- **Headers:** `Content-Type: multipart/form-data`
- **Form Data:**
  - `username`: Nama user (contoh: `coki`).
  - `avatar` (atau `file`): File gambar binary (`.jpg`, `.jpeg`, `.png`, atau `.webp`).

- **Response Success (`200 OK`):**
```json
{
  "message": "Foto profil berhasil diunggah",
  "foto_profile": "/uploads/avatars/coki_1727000000.jpg"
}
```

---

### 3.6 `DELETE /user/avatar`
Menghapus foto profil user (mengosongkan field di database ke `NULL`).

- **URL:** `/user/avatar?username=coki`
- **Method:** `DELETE`
- **Query Params:**
  - `username`: Username target.

- **Response Success (`200 OK`):**
```json
{
  "message": "Foto profil berhasil dihapus dari database"
}
```

---

### 3.7 `POST /admin/aggregate`
Menjalankan agregasi rata-rata 30-menit sensor secara manual (biasanya otomatis berjalan setiap 30 menit).

- **URL:** `/admin/aggregate`
- **Method:** `POST`
- **Headers:** `Content-Type: application/json`
- **Request Body (opsional):**
```json
{
  "interval_minutes": 30
}
```
- **Response (`200 OK`):**
```json
{
  "status": "success",
  "message": "Aggregation completed"
}
```

---

### 3.8 Static Files (URL Foto Profil)
Foto profil yang telah di-upload dapat diakses langsung oleh browser atau tag `<img>` melalui:
```
https://shelter.cbinstrument.com/uploads/avatars/{filename}
```
*Contoh:* `https://shelter.cbinstrument.com/uploads/avatars/coki_1727000000.jpg`

---

## 4. Realtime WebSocket

WebSocket digunakan untuk **menerima data sensor secara langsung (live telemetri)** dan **mengirim instruksi kontrol aktuator (saklar pompa, kipas, lampu, smart lock)**.

### Koneksi WebSocket
- **URL Endpoint:**
  ```
  wss://shelter.cbinstrument.com/ws/sensors/{shelter_id}
  ```
- *Contoh:* `wss://shelter.cbinstrument.com/ws/sensors/SHELTER-01`

---

### Format Data Telemetri Masuk (Server -> Web)
Setiap kali simulator atau sensor IoT mengirimkan pembacaan ke MQTT, backend akan mem-broadcast paket JSON ini ke semua koneksi WebSocket di shelter tersebut:

```json
{
  "type": "sensor",
  "shelter_id": "SHELTER-01",
  "data": {
    "nh4": 4.96,
    "o2": 19.4,
    "temperature": 29.3,
    "humidity": 65.8,
    "co2": 420.0,
    "door": 0,
    "pump": 1,
    "fan": 0,
    "light": 1
  }
}
```

---

### Format Perintah Kontrol Keluar (Web -> Server)
Ketika tombol di dashboard web ditekan (misal menyalakan pompa atau membuka pintu), kirim pesan teks JSON melalui koneksi WebSocket:

```json
{
  "type": "command",
  "command": "<NAMA_PERINTAH>"
}
```

#### Daftar Perintah (`command`) yang Didukung:
| Perangkat | Perintah Menyalakan (ON) | Perintah Mematikan (OFF) | Keterangan |
| :--- | :--- | :--- | :--- |
| **Pompa Air (Pump)** | `"on_pump"` | `"off_pump"` | Mengontrol relay pompa |
| **Kipas (Fan)** | `"on_fan"` | `"off_fan"` | Mengontrol blower/exhaust |
| **Lampu (Light)** | `"on_light"` | `"off_light"` | Mengontrol penerangan shelter |
| **Smart Lock Pintu** | `"unlock"` | `"lock"` | Kunci / Buka kunci pintu |

Backend akan otomatis meneruskan perintah ini ke MQTT Topic:
`shelter/{shelter_id}/command` untuk dieksekusi oleh mikrokontroler/hardware di lokasi shelter.

---

## 5. MQTT Protocol & Topics (IoT Layer)

Backend bertindak sebagai jembatan antara protokol IoT (MQTT) dengan aplikasi Web/Mobile.

### Topik Sensor Telemetri (Perangkat -> Server)
- **Topic Pattern:** `shelter/{shelter_id}/sensors`
- **Contoh Topic:** `shelter/SHELTER-01/sensors`
- **Payload Format:** JSON
```json
{
  "nh4": 4.96,
  "o2": 19.4,
  "temperature": 29.3,
  "humidity": 65.8
}
```

### Topik Perintah Aktuator (Server -> Perangkat)
- **Topic Pattern:** `shelter/{shelter_id}/command`
- **Contoh Topic:** `shelter/SHELTER-01/command`
- **Payload Format:** JSON
```json
{
  "command": "on_pump"
}
```

---

## 6. Contoh Integrasi JavaScript / TypeScript

### A. Contoh Koneksi WebSocket & Handler (React / Vue / Vanilla JS)
```javascript
const shelterId = "SHELTER-01";
const wsUrl = `wss://shelter.cbinstrument.com/ws/sensors/${shelterId}`;
const socket = new WebSocket(wsUrl);

socket.onopen = () => {
  console.log("Terhubung ke WebSocket Smart Shelter:", shelterId);
};

socket.onmessage = (event) => {
  const payload = JSON.parse(event.data);
  if (payload.type === "sensor") {
    console.log("Data Telemetri Realtime:", payload.data);
    // Update state tampilan dashboard web:
    // setTemperature(payload.data.temperature);
    // setNh4(payload.data.nh4);
  }
};

socket.onclose = () => {
  console.warn("WebSocket terputus. Mencoba reconnect...");
};

// Fungsi Mengirim Kontrol Aktuator (Pompa / Kipas / Lampu)
function sendActuatorCommand(device, turnOn) {
  if (socket.readyState === WebSocket.OPEN) {
    const action = turnOn ? "on" : "off";
    const commandName = `${action}_${device.toLowerCase()}`; // contoh: 'on_pump'
    
    socket.send(JSON.stringify({
      type: "command",
      command: commandName
    }));
    console.log("Perintah terkirim:", commandName);
  }
}
```

### B. Contoh Upload Avatar via Axios
```javascript
import axios from 'axios';

async function uploadUserAvatar(username, fileInput) {
  const formData = new FormData();
  formData.append('username', username);
  formData.append('avatar', fileInput);

  try {
    const response = await axios.post(
      'https://shelter.cbinstrument.com/user/avatar',
      formData,
      { headers: { 'Content-Type': 'multipart/form-data' } }
    );
    console.log("Avatar path:", response.data.foto_profile);
    return response.data.foto_profile;
  } catch (error) {
    console.error("Gagal upload avatar:", error.response?.data || error.message);
  }
}
```

### C. Contoh Fetch Riwayat Grafik Sensor
```javascript
async function fetchChartHistory(sensorType = "nh4", shelterId = "SHELTER-01") {
  const res = await fetch(
    `https://shelter.cbinstrument.com/sensor/history/${sensorType}?shelter_id=${shelterId}&limit=24`
  );
  const data = await res.json();
  // Format data.history: [{ value: 4.96, created_at: "2026-09-22 10:00:00" }, ...]
  return data.history;
}
```

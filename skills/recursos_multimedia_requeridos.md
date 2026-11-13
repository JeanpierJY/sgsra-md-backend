# 📦 INVENTARIO DE RECURSOS MULTIMEDIA Y ACTIVOS REQUERIDOS (SGSRA-MD)

Guía oficial para la preparación, carga y despliegue de recursos gráficos, fotografías de catálogo, logotipos y códigos QR para el sistema SGSRA-MD (Master Drilling Perú S.A.).

---

## 1. Especificaciones Técnicas y Parámetros del Servidor

- **Peso Máximo por Archivo:** Menor a **5 MB** (Validación estricta en `LocalStorageServiceImpl.java` y `RF32 Ex3`).
- **Formatos Aceptados:** `.png`, `.jpg`, `.jpeg`.
- **Rutas de Almacenamiento:**
  - **Recursos Nativos / Estáticos de la App (Empaquetados en APK):** `sgsra_mobile/assets/images/` y `sgsra_mobile/assets/icons/`.
  - **Imágenes Dinámicas de Catálogo (Subidas al Servidor Spring Boot):** Directorio local `./uploads/imagenes/` expuesto vía Spring MVC como `/uploads/**`.
- **Modo Fallback Offline:** Si un ítem no tiene foto cargada o si se pierde la red en socavón, Flutter debe renderizar un contenedor con ícono vectorial corporativo (`Icons.precision_manufacturing_outlined` para repuestos, `Icons.build_outlined` para herramientas) mediante el manejador `errorBuilder` de `Image.network`.

---

## 2. Identidad Visual y Recursos de la Aplicación Móvil (`assets/`)

| Recurso | Archivo Sugerido | Dimensiones Recomendadas | Uso en la Aplicación |
| :--- | :--- | :--- | :--- |
| **Logo Oficial Master Drilling** | `assets/images/logo_master_drilling.png` | 512 x 512 px (PNG transparente) | Pantalla de Login, Splash Screen y barra superior (AppBar) |
| **Logo Isotipo / Marca Reducida** | `assets/images/isotipo_md.png` | 256 x 256 px (PNG transparente) | Header del Drawer lateral y marca de agua en reportes |
| **Ícono de la Aplicación Android** | `android/app/src/main/res/mipmap-*/ic_launcher.png` | Adaptativo (MDPI a XXXHDPI) | Ícono en el launcher de los teléfonos Android de los operarios |
| **Ilustración Estado Vacío** | `assets/images/empty_box.png` | 300 x 300 px (Vector / PNG) | Pantallas de historial vacío, carrito vacío o sin notificaciones |
| **Avatar por Defecto** | `assets/images/avatar_placeholder.png` | 200 x 200 px (PNG transparente) | Pestaña "Mi Perfil" para Mecánicos, Almacenistas y Administrador |

---

## 3. Catálogo Maestro de Repuestos (Fotografías Dinámicas)

Para poblar el catálogo de repuestos homologados en el servidor Spring Boot (`POST /api/v1/catalogo/{codParte}/imagen`), se requieren las siguientes fotografías reales o representativas (resolución recomendada: 800 x 600 px):

| Código de Parte | Nombre del Repuesto | Categoría Técnica | Descripción / Tipo de Foto Requerida |
| :--- | :--- | :--- | :--- |
| **P-REX-024** | Bomba Hidráulica Principal Rexroth | Hidráulico | Bomba de pistones axiales para perforadora Raise Boring |
| **P-REX-025** | Válvula Proporcional Direccional 4WRZ | Válvulas | Válvula electrohidráulica modular de mando central |
| **P-PAR-101** | Filtro de Alta Presión Serie 15P | Filtros | Cartucho cilíndrico metálico para circuito de alta presión |
| **P-DON-502** | Filtro de Aire Donaldson Duralite | Filtros | Filtro de admisión de aire para compresor y motor diésel |
| **P-CAT-330** | Inyector Diésel Common Rail C9 | Motor | Inyector de combustible de alta precisión Caterpillar |
| **P-CAT-331** | Turbocompresor Garrett MD-90 | Motor | Turbo cargador para equipo de perforación pesada |
| **P-FES-010** | Cilindro Neumático Doble Efecto DNC | Neumático | Actuador cilíndrico de aluminio para mandos neumáticos |
| **P-MAN-088** | Manguera Hidráulica 4 Mallas 1 pulgada | Mangueras | Tramo de manguera reforzada con terminales prensados |
| **P-SKF-222** | Rodamiento de Rodillos Cónicos SKF | Rodamientos | Rodamiento para cabezal de rotación subterránea |
| **P-DAN-045** | Motor Hidráulico Orbital Danfoss OMT | Hidráulico | Motor hidráulico de alto torque para avance de máquina |

---

## 4. Pañol de Herramientas Calibradas (Fotografías Dinámicas)

Para el alta de herramientas en el pañol (`POST /api/v1/inventario/herramientas/{codHerramienta}/imagen`), se requieren fotografías claras sobre fondo neutro para verificación visual rápida durante el escaneo QR:

| Código de Activo | Nombre de la Herramienta | Categoría | Tipo de Foto Requerida |
| :--- | :--- | :--- | :--- |
| **HER-TOR-004** | Torquímetro Digital Calibrado 1/2 pulgada | Manuales | Llave dinamométrica digital con display y certificado visible |
| **HER-TOR-005** | Torquímetro Zafre Mecánico 3/4 pulgada | Manuales | Torquímetro de quiebre para ajuste de pernos de corte |
| **HER-PIS-012** | Pistola de Impacto Neumática 1 pulgada | Neumáticas | Llave de impacto industrial para torque pesado de brocas |
| **HER-FLU-001** | Multímetro Digital Industrial Fluke 87V | Eléctricas | Multímetro con pinzas de prueba y display encendido |
| **HER-ENE-008** | Gato Hidráulico Tipo Botella 50 Toneladas | Hidráulicas | Cilindro hidráulico Enerpac con bomba manual acoplada |
| **HER-PIN-003** | Pinza Amperimétrica True RMS 1000A | Eléctricas | Pinza de gancho para medición de corriente en CCM de socavón |
| **HER-AMO-007** | Amoladora Angular Industrial 7 pulgadas | Eléctricas | Esmeril angular con guarda de seguridad y disco de corte |
| **HER-COM-015** | Compresor de Aire Portátil 5.5 HP | Neumáticas | Unidad portátil para pruebas neumáticas en taller |
| **HER-CAL-002** | Calibrador Pie de Rey Digital Mitutoyo | Manuales | Calibrador vernier para medición de desgaste de ejes |
| **HER-EXT-020** | Extractor Hidráulico de Rodamientos 3 Brazos | Hidráulicas | Conjunto de garras con pistón hidráulico central |

---

## 5. Códigos QR / Barras de Prueba para Escaneo Físico en Taller

Para probar el escáner óptico móvil con la cámara trasera de los celulares (`mobile_scanner`), imprime o proyecta en pantalla los siguientes textos exactos en un generador de QR (ej. [qr-code-generator.com](https://www.qr-code-generator.com/) o similar):

```text
1. QR Herramienta Disponible (Préstamo directo):
   HER-TOR-004

2. QR Herramienta de Alto Torque (Neumática):
   HER-PIS-012

3. QR Herramienta Eléctrica:
   HER-FLU-001

4. QR Herramienta Hidráulica:
   HER-ENE-008

5. QR Herramienta Mecánica Manual:
   HER-CAL-002
```

> **Comportamiento en la App Móvil:**  
> Al enfocar cualquiera de estos códigos con la cámara del celular desde la vista del Almacenista:
> - Si el código coincide con una herramienta **Disponible** $\rightarrow$ Abre automáticamente el modal *"Registrar Préstamo"* pre-cargando la herramienta.
> - Si coincide con una herramienta **Prestada** $\rightarrow$ Abre directamente el modal *"Registrar Devolución e Inspección Física"* (RF38 - RF40).


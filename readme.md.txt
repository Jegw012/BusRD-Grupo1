# Proyecto Base de Datos: Sistema BusRD
**Entrega Final Integrada**

## Integrantes
- Jose Enrique Grullon Walters A00143826
- Freilyn Rodríguez A00142647
- Elianna Francheska Ramírez Frías  A00151495
- Franklin Soriano A00165151

## Datos Asignados
- **Grupo:** 1
- **Viaje Asignado (C1):** 16000
- **Cédula Cliente (C2):** 40200001000 (ClienteID = 1000)

## Orden de Ejecución de los Scripts
1. 01_integridad.sql: Limpieza de anomalías, definición de claves foráneas, restricciones CHECK/UNIQUE e índice único filtrado.
2. 02_sp_VenderBoleto.sql: Implementación del procedimiento almacenado transaccional con bloqueos UPDLOCK/HOLDLOCK.
3. 03_sp_AnularBoleto.sql: Procedimiento transaccional de anulación y reverso contable en pagos.
4. 04_demo_concurrencia_sesionA.sql: Simulación de venta con retraso de 10s (Sesión A).
5. 05_demo_concurrencia_sesionB.sql: Intento simultáneo de venta del mismo asiento (Sesión B).
6. 06_indices_y_consultas_optimizadas.sql: Creación de índices cubridores y reescritura sargable de C1, C2 y C3.
7. 07_seguridad.sql: Vistas de seguridad, definición de roles (`rol_taquilla`, `rol_reportes`, `rol_admin`) y usuarios WITHOUT LOGIN.
8. 08_respaldo_y_restauracion.sql: Cadena de backups (FULL, DIFF, LOG, TAIL-LOG) y restauración en base paralela con STOPAT.

## Carpeta de Evidencias
Contiene las capturas numeradas que respaldan los planes de ejecución, estadísticas de I/O y tiempos, validaciones de seguridad y recuperación en el tiempo.
-- RFC1

SELECT L.localidad,
COUNT(*) AS cantidad_solicitudes
FROM Solicitudes S
INNER JOIN Lugares L
ON S.punto_recogida = L.punto_recogida
WHERE S.fecha_solicitud >= TO_DATE('01/09/2026', 'DD/MM/YYYY')
AND S.fecha_solicitud < TO_DATE('01/12/2026', 'DD/MM/YYYY')
GROUP BY L.localidad
ORDER BY L.localidad;


-- RFC2

SELECT L.localidad,
SUM(V.tarifa) AS ingresos_estimados
FROM Solicitudes S
INNER JOIN Viajes V
ON S.placa = V.placa
AND S.fecha = V.fecha
AND S.hora_salida = V.hora_salida
INNER JOIN Lugares L
ON S.punto_recogida = L.punto_recogida
WHERE S.estado_solicitud = 'Aceptada'
AND V.estado IN ('Programado', 'En curso', 'Completado')
AND V.fecha >= TO_DATE('01/09/2026', 'DD/MM/YYYY')
AND V.fecha < TO_DATE('01/12/2026', 'DD/MM/YYYY')
GROUP BY L.localidad
ORDER BY L.localidad;


-- RFC3

SELECT E.documento_identidad,
E.nombre,
E.apellidos,
TO_CHAR(V.fecha, 'YYYY-MM') AS mes,
COUNT(*) AS cantidad_viajes
FROM Viajes V
INNER JOIN Vehiculos Ve
ON V.placa = Ve.placa
INNER JOIN Estudiantes E
ON Ve.documento_conductor = E.documento_identidad
WHERE V.estado = 'Completado'
AND V.fecha >= TO_DATE('01/09/2026', 'DD/MM/YYYY')
AND V.fecha < TO_DATE('01/12/2026', 'DD/MM/YYYY')
AND E.documento_identidad = 1000000001
AND EXISTS (
SELECT *
FROM Paradas P
INNER JOIN Lugares L
ON P.punto_recogida = L.punto_recogida
WHERE P.placa = V.placa
AND P.fecha = V.fecha
AND P.hora_salida = V.hora_salida
AND L.localidad = 'Usaquen'
)
GROUP BY E.documento_identidad,
E.nombre,
E.apellidos,
TO_CHAR(V.fecha, 'YYYY-MM')
ORDER BY E.documento_identidad, mes;

-- RFA1: resumen de viajes completados de un conductor.
-- Documento de ejemplo: 1000000001.
SELECT NVL(SUM(s.total_pasajeros), 0) AS total_pasajeros,
       NVL(SUM(v.tarifa * NVL(s.total_pasajeros, 0)), 0) AS total_ingresos,
       NVL(SUM(v.distancia), 0) AS distancia_total_km,
       NVL(SUM(v.duracion), 0) AS tiempo_total_minutos
FROM Viajes v
JOIN Vehiculos veh ON veh.placa = v.placa
LEFT JOIN (
    SELECT placa, fecha, hora_salida, COUNT(*) AS total_pasajeros
    FROM Solicitudes
    WHERE estado_solicitud = 'Aceptada'
    GROUP BY placa, fecha, hora_salida
) s ON s.placa = v.placa
   AND s.fecha = v.fecha
   AND s.hora_salida = v.hora_salida
WHERE veh.documento_conductor = 1000000001
  AND v.estado = 'Completado';

-- RFA2: resumen de viajes completados de un pasajero.
-- Documento de ejemplo: 1000000021.
SELECT COUNT(*) AS viajes_tomados,
       NVL(SUM(v.tarifa), 0) AS total_gastos,
       NVL(AVG(v.distancia), 0) AS promedio_distancia_km,
       NVL(AVG(v.duracion), 0) AS promedio_tiempo_minutos
FROM Solicitudes s
JOIN Viajes v ON v.placa = s.placa
             AND v.fecha = s.fecha
             AND v.hora_salida = s.hora_salida
WHERE s.doc_pasajero = 1000000021
  AND s.estado_solicitud = 'Aceptada'
  AND v.estado = 'Completado';

-- Zona mas solicitada por el pasajero, incluyendo todos los estados.
SELECT NVL((
    SELECT localidad
    FROM (
        SELECT l.localidad, COUNT(*) AS total_solicitudes
        FROM Solicitudes s
        JOIN Lugares l ON l.punto_recogida = s.punto_recogida
        WHERE s.doc_pasajero = 1000000021
        GROUP BY l.localidad
        ORDER BY total_solicitudes DESC, l.localidad
    )
    WHERE ROWNUM = 1
), 'Sin solicitudes aun') AS zona_mas_solicitada
FROM dual;

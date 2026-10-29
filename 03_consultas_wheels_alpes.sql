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
SELECT
    NVL(SUM(S.total_pasajeros), 0) AS total_pasajeros,
    NVL(SUM(V.tarifa * NVL(S.total_pasajeros, 0)), 0) AS total_ingresos,
    NVL(SUM(V.distancia), 0) AS distancia_total_km,
    NVL(SUM(V.duracion), 0) AS tiempo_total_minutos
FROM Viajes V
INNER JOIN Vehiculos VEH
  ON VEH.placa = V.placa
LEFT JOIN (
SELECT placa,fecha,hora_salida,
COUNT(*) AS total_pasajeros
FROM Solicitudes
WHERE estado_solicitud = 'Aceptada'
GROUP BY placa, fecha, hora_salida
) S
ON S.placa = V.placa
AND S.fecha = V.fecha
AND S.hora_salida = V.hora_salida
WHERE VEH.documento_conductor = :G_DOCUMENTO_USUARIO
  AND V.estado = 'Completado';
  
  
  
SELECT
COUNT(*) AS viajes_tomados,
NVL(SUM(V.tarifa), 0) AS total_gastos,
ROUND(NVL(AVG(V.distancia), 0), 1) AS promedio_distancia_km,
ROUND(NVL(AVG(V.duracion), 0), 1) AS promedio_tiempo_minutos
FROM Solicitudes S
INNER JOIN Viajes V
ON V.placa = S.placa
AND V.fecha = S.fecha
AND V.hora_salida = S.hora_salida
WHERE S.doc_pasajero = :G_DOCUMENTO_USUARIO
AND S.estado_solicitud = 'Aceptada'
AND V.estado = 'Completado';
    
    
    
SELECT L.localidad AS zona_mas_solicitada,
COUNT(*) AS total_solicitudes
FROM Solicitudes S
INNER JOIN Lugares L
  ON L.punto_recogida = S.punto_recogida
WHERE S.doc_pasajero = :G_DOCUMENTO_USUARIO
GROUP BY L.localidad
ORDER BY COUNT(*) DESC, L.localidad
FETCH FIRST 1 ROW ONLY;
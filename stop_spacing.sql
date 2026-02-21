CREATE OR REPLACE VIEW excel_route_map AS

SELECT 
    r.route_short_name,
    t.direction_id,
    st.stop_sequence,
    s.stop_name,
    s.stop_lat,
    s.stop_lon
FROM routes r
JOIN trips t ON r.route_id = t.route_id
JOIN stop_times st ON t.trip_id = st.trip_id
JOIN stops s ON st.stop_id = s.stop_id
WHERE r.route_type = 3 -- BUS ONLY
  AND t.trip_id IN (

    SELECT MIN(trip_id) 
    FROM trips t2
    JOIN routes r2 ON t2.route_id = r2.route_id
    WHERE t2.service_id = '1' 
      AND r2.route_type = 3 
    GROUP BY t2.route_id, t2.direction_id
)
ORDER BY r.route_short_name, t.direction_id, st.stop_sequence;

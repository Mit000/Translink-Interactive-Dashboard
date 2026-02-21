CREATE OR REPLACE VIEW excel_advanced_metrics AS

SELECT 
    r.route_short_name,
    t.direction_id, 
    t.trip_headsign,
    
    -- 1. STOP COUNTS
    COUNT(DISTINCT st.stop_id) AS num_stops,

    -- 2. TOTAL VOLUME
    COUNT(DISTINCT t.trip_id) AS total_trips,

    -- 3. PEAK vs OFF-PEAK BREAKDOWN
    SUM(CASE WHEN st.departure_time >= '07:00:00' AND st.departure_time < '09:00:00' THEN 1 ELSE 0 END) AS trips_peak_am,
    SUM(CASE WHEN st.departure_time >= '11:00:00' AND st.departure_time < '14:00:00' THEN 1 ELSE 0 END) AS trips_midday,
    SUM(CASE WHEN st.departure_time >= '16:00:00' AND st.departure_time < '19:00:00' THEN 1 ELSE 0 END) AS trips_peak_pm

FROM routes r
JOIN trips t ON r.route_id = t.route_id
JOIN stop_times st ON t.trip_id = st.trip_id
WHERE t.service_id = '1'   -- Weekday
  AND r.route_type = 3     -- BUS ONLY
  AND st.stop_sequence = 1 -- Only count start of trips
GROUP BY r.route_short_name, t.direction_id, t.trip_headsign
ORDER BY r.route_short_name, t.direction_id;

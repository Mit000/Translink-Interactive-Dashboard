CREATE OR REPLACE VIEW excel_rider_experience AS

WITH Trip_Times AS (
    SELECT 
        t.route_id,
        t.trip_id,
        MIN(st.departure_time) as trip_start,
        MAX(st.arrival_time) as trip_end
    FROM stop_times st
    JOIN trips t ON st.trip_id = t.trip_id
    JOIN routes r ON t.route_id = r.route_id -- Joined routes here to filter
    WHERE t.service_id = '1' -- Weekday
      AND r.route_type = 3   -- BUS ONLY
    GROUP BY t.route_id, t.trip_id
)

SELECT 
    r.route_short_name,
    r.route_long_name,
    
    -- METRIC 1: SERVICE SPAN
    MIN(tt.trip_start) AS first_bus_departure,
    -- Normalizes "25:00" times to "01:00" for Excel
    STR_TO_DATE(
        CONCAT(
            LPAD(CAST(SUBSTRING_INDEX(MAX(tt.trip_end), ':', 1) AS UNSIGNED) % 24, 2, '0'), 
            SUBSTR(MAX(tt.trip_end), INSTR(MAX(tt.trip_end), ':'))
        ), '%H:%i:%s'
    ) AS last_bus_arrival_excel_ready,
    
    ROUND((TIME_TO_SEC(MAX(tt.trip_end)) - TIME_TO_SEC(MIN(tt.trip_start))) / 3600, 1) AS service_span_hours,

    -- METRIC 2: VOLUME
    COUNT(tt.trip_id) AS total_daily_trips,
    
    -- METRIC 3: WAIT TIME
    ROUND(((TIME_TO_SEC(MAX(tt.trip_end)) - TIME_TO_SEC(MIN(tt.trip_start))) / 60) / COUNT(tt.trip_id), 1) AS avg_wait_time_minutes

FROM Trip_Times tt
JOIN routes r ON tt.route_id = r.route_id
GROUP BY r.route_short_name, r.route_long_name
ORDER BY total_daily_trips DESC;

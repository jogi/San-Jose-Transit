# Query Baseline (Pre-GRDB Migration)

This file captures all database queries currently used by the app and tests before migration to `GTFSModels + GRDB`.

## Production Queries

### Route.swift

1. `Route.routes()`
- SQLite.swift:
```swift
routes.order(CAST(route_short_name AS INTEGER).asc, route_short_name.asc)
```
- Equivalent SQL:
```sql
SELECT *
FROM routes
ORDER BY CAST(route_short_name AS INTEGER) ASC, route_short_name ASC;
```
- Intent: load all routes sorted numerically by short name when possible.

2. `Route.route(byId:)`
- SQLite.swift:
```swift
routes.filter(route_id == ?)
```
- Equivalent SQL:
```sql
SELECT *
FROM routes
WHERE route_id = ?;
```
- Intent: route lookup by primary key.

### Stop.swift

3. `Stop.stops()`
- SQLite.swift:
```swift
stops
```
- Equivalent SQL:
```sql
SELECT *
FROM stops;
```
- Intent: full stop list for map and route-stop flows.

4. `Stop.stop(byId:)`
- SQLite.swift:
```swift
stops.filter(stop_id == ?)
```
- Equivalent SQL:
```sql
SELECT stop_id, stop_name, routes
FROM stops
WHERE stop_id = ?;
```
- Intent: stop lookup for favorites and detail displays.

### Calendar.swift

5. `Calendar.isServiceActive(_:serviceId:)`
- SQLite.swift:
```swift
calendar.filter(
  service_id == ? &&
  start_date <= ? &&
  end_date >= ? &&
  <weekday_column> == 1
).count
```
- Equivalent SQL:
```sql
SELECT COUNT(*)
FROM calendar
WHERE service_id = ?
  AND start_date <= ?
  AND end_date >= ?
  AND <weekday_column> = 1;
```
- Intent: determine if a service runs on a specific date.

### Trip.swift

6. `Trip.trips(_:activeOn:)`
- SQLite.swift:
```swift
trips.select(trip_id, service_id).filter(route_id IN (? ...))
```
Then in Swift for each row:
- call `Calendar.isServiceActive(activeOn, serviceId:)`
- keep `trip_id` when active.
- Equivalent SQL shape today:
```sql
SELECT trip_id, service_id
FROM trips
WHERE route_id IN (? ...);
```
- Intent: active trip IDs for one or more routes.

7. `Trip.trips(_:directionId:activeOn:)`
- SQLite.swift:
```swift
trips.select(trip_id, service_id)
     .filter(route_id IN (? ...) AND direction_id = ?)
```
Then per row calendar check in Swift.
- Equivalent SQL shape today:
```sql
SELECT trip_id, service_id
FROM trips
WHERE route_id IN (? ...)
  AND direction_id = ?;
```
- Intent: active trip IDs constrained by direction.

### StopTime.swift

8. `StopTime.stopTimes(stopId, afterTime, tripIds)`
- SQLite.swift:
```swift
stop_times
  .select(MIN(arrival_time), trips.route_id, routes.route_short_name, trips.direction_id, trips.trip_headsign)
  .join(trips, stop_times.trip_id == trips.trip_id)
  .join(routes, trips.route_id == routes.route_id)
  .filter(stop_times.stop_id == ?
      && stop_times.trip_id IN (? ...)
      && stop_times.arrival_time >= ?
      && stop_times.is_laststop == false)
  .group(trips.route_id)
  .order(trips.route_id, stop_times.arrival_time)
```
- Equivalent SQL:
```sql
SELECT MIN(st.arrival_time) AS arrival_time,
       t.route_id,
       r.route_short_name,
       t.direction_id,
       t.trip_headsign
FROM stop_times st
JOIN trips t ON st.trip_id = t.trip_id
JOIN routes r ON t.route_id = r.route_id
WHERE st.stop_id = ?
  AND st.trip_id IN (? ...)
  AND st.arrival_time >= ?
  AND st.is_laststop = 0
GROUP BY t.route_id
ORDER BY t.route_id, st.arrival_time;
```
- Intent: next arrival per route at a stop.

9. `StopTime.stopTimes(stopId, routeId, tripIds, afterTime)`
- SQLite.swift:
```swift
stop_times
  .select(arrival_time, trips.trip_headsign, trips.trip_id, trips.shape_id, trips.direction_id)
  .join(trips, stop_times.trip_id == trips.trip_id)
  .filter(stop_times.stop_id == ?
      && trips.route_id == ?
      && stop_times.trip_id IN (? ...)
      && stop_times.arrival_time >= ?
      && stop_times.is_laststop == false)
  .order(stop_times.arrival_time)
```
- Equivalent SQL:
```sql
SELECT st.arrival_time, t.trip_headsign, t.trip_id, t.shape_id, t.direction_id
FROM stop_times st
JOIN trips t ON st.trip_id = t.trip_id
WHERE st.stop_id = ?
  AND t.route_id = ?
  AND st.trip_id IN (? ...)
  AND st.arrival_time >= ?
  AND st.is_laststop = 0
ORDER BY st.arrival_time;
```
- Intent: detailed upcoming arrivals for one stop + route.

10. `StopTime.stopTimes(tripId)`
- SQLite.swift:
```swift
stop_times
  .select(arrival_time, stop_id, stop_sequence, stops.stop_name, stops.stop_lat, stops.stop_lon, stops.routes)
  .join(stops, stop_times.stop_id == stops.stop_id)
  .filter(stop_times.trip_id == ?)
  .order(stop_times.stop_sequence)
```
- Equivalent SQL:
```sql
SELECT st.arrival_time,
       st.stop_id,
       st.stop_sequence,
       s.stop_name,
       s.stop_lat,
       s.stop_lon,
       s.routes
FROM stop_times st
JOIN stops s ON st.stop_id = s.stop_id
WHERE st.trip_id = ?
ORDER BY st.stop_sequence;
```
- Intent: full stop sequence for a trip.

11. `StopTime.trip(routeId, directionId, afterTime)`
- First obtains active trip IDs from `Trip.trips([routeId], directionId, afterTime)`.
- SQLite.swift:
```swift
stop_times
  .select(trip_id)
  .filter(trip_id IN (? ...)
      && stop_sequence == 1
      && arrival_time >= ?)
  .order(arrival_time)
  .limit(1)
```
- Equivalent SQL:
```sql
SELECT trip_id
FROM stop_times
WHERE trip_id IN (? ...)
  AND stop_sequence = 1
  AND arrival_time >= ?
ORDER BY arrival_time
LIMIT 1;
```
- Intent: next departing trip for route+direction after time cutoff.

### Shape.swift

12. `Shape.shapes(forShape:)`
- SQLite.swift:
```swift
shapes.select(shape_pt_lat, shape_pt_lon, shape_pt_sequence)
      .filter(shape_id == ?)
      .order(shape_pt_sequence)
```
- Equivalent SQL:
```sql
SELECT shape_pt_lat, shape_pt_lon, shape_pt_sequence
FROM shapes
WHERE shape_id = ?
ORDER BY shape_pt_sequence;
```
- Intent: ordered polyline points by shape ID.

13. `Shape.shapes(forTrip:)`
- SQLite.swift:
```swift
shapes.select(shapes.shape_pt_lat, shapes.shape_pt_lon, shapes.shape_pt_sequence)
      .join(trips, shapes.shape_id == trips.shape_id)
      .filter(trips.trip_id == ?)
      .order(shapes.shape_pt_sequence)
```
- Equivalent SQL:
```sql
SELECT s.shape_pt_lat, s.shape_pt_lon, s.shape_pt_sequence
FROM shapes s
JOIN trips t ON s.shape_id = t.shape_id
WHERE t.trip_id = ?
ORDER BY s.shape_pt_sequence;
```
- Intent: route geometry for a trip.

### Favorite.swift (favorites DB)

14. `Favorite.favorites()`
- SQLite.swift:
```swift
favorites.select(fav_id, sort_order, fav_type, fav_type_id)
         .order(sort_order)
```
- Equivalent SQL:
```sql
SELECT fav_id, sort_order, fav_type, fav_type_id
FROM favorites
ORDER BY sort_order;
```
- Intent: ordered favorites list, then app does per-row lookups in `stops/routes` DB.

15. `Favorite.isFavorite(type, typeId)`
- SQLite.swift:
```swift
favorites.filter(fav_type_id == ? && fav_type == ?).count
```
- Equivalent SQL:
```sql
SELECT COUNT(*)
FROM favorites
WHERE fav_type_id = ?
  AND fav_type = ?;
```
- Intent: existence check.

16. `Favorite.addFavorite(type, typeId)`
- SQLite.swift insert:
```swift
favorites.insert(fav_type_id <- ?, fav_type <- ?)
```
- Equivalent SQL:
```sql
INSERT INTO favorites (fav_type_id, fav_type)
VALUES (?, ?);
```
- Intent: create favorite.

17. `Favorite.deleteFavorite(favoriteId)`
- SQLite.swift delete:
```swift
favorites.filter(fav_id == ?).delete()
```
- Equivalent SQL:
```sql
DELETE FROM favorites
WHERE fav_id = ?;
```

18. `Favorite.deleteFavorite(type, typeId)`
- SQLite.swift delete:
```swift
favorites.filter(fav_type_id == ? && fav_type == ?).delete()
```
- Equivalent SQL:
```sql
DELETE FROM favorites
WHERE fav_type_id = ?
  AND fav_type = ?;
```

19. `Favorite.updateFavorites(_:)`
- SQLite.swift update per row:
```swift
favorites.filter(fav_id == ?)
         .update(sort_order <- ?, fav_type <- ?, fav_type_id <- ?)
```
- Equivalent SQL:
```sql
UPDATE favorites
SET sort_order = ?, fav_type = ?, fav_type_id = ?
WHERE fav_id = ?;
```

20. `Favorite.createFavoritesIfRequred()`
- SQLite.swift schema creation:
```swift
favorites.create(ifNotExists: true) {
  fav_id INTEGER PRIMARY KEY AUTOINCREMENT,
  fav_type INTEGER,
  fav_type_id TEXT,
  sort_order INTEGER
}
```
- Equivalent SQL:
```sql
CREATE TABLE IF NOT EXISTS favorites (
  fav_id INTEGER PRIMARY KEY AUTOINCREMENT,
  fav_type INTEGER,
  fav_type_id TEXT,
  sort_order INTEGER
);
```

## Test-Only Queries

21. `TestDBSupport.ensureGTFSInstalled()`
```sql
SELECT COUNT(*) FROM routes;
```

22. `diagnoseDatabase()` counts
```sql
SELECT COUNT(*) FROM routes;
SELECT COUNT(*) FROM stops;
SELECT COUNT(*) FROM trips;
SELECT COUNT(*) FROM stop_times;
SELECT COUNT(*) FROM calendar;
```

23. `CalendarQueryTests.serviceId(forTripId:)`
```sql
SELECT service_id
FROM trips
WHERE trip_id = ?
LIMIT 1;
```

24. `CalendarQueryTests.calendarWindow(forService:)`
```sql
SELECT *
FROM calendar
WHERE service_id = ?
LIMIT 1;
```

## Observed High-Risk Inefficiencies (for migration focus)

1. `Trip.trips` does N+1 calendar lookups (one query per candidate trip).
2. `Favorite.favorites` does N+1 lookups into stops/routes after reading favorites.
3. `StopTime.trip` builds large in-memory `tripIds` list, then IN-filter query.
4. Several `SELECT *` scans pull unneeded columns.
5. No explicit index management in app-owned favorites DB.
6. Time comparisons use text fields; correctness/perf depend on normalized `HH:mm:ss` strings.

import Foundation
import GRDB
import GTFSModel

struct StopRouteSummary: Hashable {
    let arrivalTime: Date
    let routeIdentifier: String
    let routeShortName: String?
    let routeLongName: String?
    let tripIdentifier: String
    let tripHeadsign: String?
    let directionIdentifier: Int?
    let shapeIdentifier: String?
    let stopIdentifier: String
    let stopName: String?
    let stopLatitude: Double
    let stopLongitude: Double
    let stopRoutes: String?
}

struct TripStopSummary: Hashable {
    let arrivalTime: Date
    let stopSequence: Int
    let stopIdentifier: String
    let stopName: String?
    let stopLatitude: Double
    let stopLongitude: Double
    let stopRoutes: String?
}

private struct TripSnapshot: Decodable, FetchableRecord {
    let tripIdentifier: String
    let routeIdentifier: String
    let tripHeadsign: String?
    let directionIdentifier: Int?
    let shapeIdentifier: String?

    enum CodingKeys: String, CodingKey {
        case tripIdentifier = "trip_id"
        case routeIdentifier = "route_id"
        case tripHeadsign = "trip_headsign"
        case directionIdentifier = "direction_id"
        case shapeIdentifier = "shape_id"
    }
}

private struct StopSnapshot: Decodable, FetchableRecord {
    let identifier: String
    let name: String?
    let latitude: Double
    let longitude: Double
    let routes: String?

    enum CodingKeys: String, CodingKey {
        case identifier = "stop_id"
        case name = "stop_name"
        case latitude = "stop_lat"
        case longitude = "stop_lon"
        case routes
    }
}

private struct RouteSnapshot: Decodable, FetchableRecord {
    let identifier: String
    let shortName: String?
    let longName: String?

    enum CodingKeys: String, CodingKey {
        case identifier = "route_id"
        case shortName = "route_short_name"
        case longName = "route_long_name"
    }
}

private struct StopTimeSnapshot: Decodable, FetchableRecord {
    let tripIdentifier: String
    let stopIdentifier: String
    let arrivalTime: String
    let stopSequence: Int
    let isLastStop: Int?

    enum CodingKeys: String, CodingKey {
        case tripIdentifier = "trip_id"
        case stopIdentifier = "stop_id"
        case arrivalTime = "arrival_time"
        case stopSequence = "stop_sequence"
        case isLastStop = "is_laststop"
    }
}

private struct StopRouteSummaryRow: Decodable, FetchableRecord {
    let arrivalTime: String
    let routeIdentifier: String
    let routeShortName: String?
    let routeLongName: String?
    let tripIdentifier: String
    let tripHeadsign: String?
    let directionIdentifier: Int?
    let shapeIdentifier: String?
    let stopIdentifier: String
    let stopName: String?
    let stopLatitude: Double
    let stopLongitude: Double
    let stopRoutes: String?

    enum CodingKeys: String, CodingKey {
        case arrivalTime = "arrival_time"
        case routeIdentifier = "route_id"
        case routeShortName = "route_short_name"
        case routeLongName = "route_long_name"
        case tripIdentifier = "trip_id"
        case tripHeadsign = "trip_headsign"
        case directionIdentifier = "direction_id"
        case shapeIdentifier = "shape_id"
        case stopIdentifier = "stop_id"
        case stopName = "stop_name"
        case stopLatitude = "stop_lat"
        case stopLongitude = "stop_lon"
        case stopRoutes = "routes"
    }

    var summary: StopRouteSummary? {
        guard let parsedArrivalTime = DateFormatter.SQLTimeFormatter.date(from: arrivalTime.sanitizedTimeString) else {
            return nil
        }

        return StopRouteSummary(
            arrivalTime: parsedArrivalTime,
            routeIdentifier: routeIdentifier,
            routeShortName: routeShortName,
            routeLongName: routeLongName,
            tripIdentifier: tripIdentifier,
            tripHeadsign: tripHeadsign,
            directionIdentifier: directionIdentifier,
            shapeIdentifier: shapeIdentifier,
            stopIdentifier: stopIdentifier,
            stopName: stopName,
            stopLatitude: stopLatitude,
            stopLongitude: stopLongitude,
            stopRoutes: stopRoutes
        )
    }
}

enum TransitStore {
    static func routes() -> [Route] {
        guard let dbQueue = Database.connection else {
            return []
        }

        do {
            return try dbQueue.read { db in
                try Route
                    .order(sql: "CAST(\(Route.CodingKeys.shortName.rawValue) AS INTEGER) ASC, \(Route.CodingKeys.shortName.rawValue) ASC")
                    .fetchAll(db)
            }
        } catch {
            return []
        }
    }

    static func route(identifier: String) -> Route? {
        guard let dbQueue = Database.connection else {
            return nil
        }

        do {
            return try dbQueue.read { db in
                try Route
                    .filter { $0.identifier == identifier }
                    .fetchOne(db)
            }
        } catch {
            return nil
        }
    }

    static func stops() -> [Stop] {
        guard let dbQueue = Database.connection else {
            return []
        }

        do {
            return try dbQueue.read { db in
                try Stop.fetchAll(db)
            }
        } catch {
            return []
        }
    }

    static func stop(identifier: String) -> Stop? {
        guard let dbQueue = Database.connection else {
            return nil
        }

        do {
            return try dbQueue.read { db in
                try Stop
                    .filter { $0.identifier == identifier }
                    .fetchOne(db)
            }
        } catch {
            return nil
        }
    }

    static func isServiceActive(on date: Date, serviceIdentifier: String) -> Bool {
        guard let dbQueue = Database.connection else {
            return false
        }

        let dateString = DateFormatter.PSTDateFormatterDate.string(from: date)
        let weekdayColumn = weekdayColumn(for: date)

        do {
            return try dbQueue.read { db in
                let count = try GTFSModel.Calendar
                    .filter { $0.serviceIdentifier == serviceIdentifier }
                    .filter { $0.startDate <= dateString }
                    .filter { $0.endDate >= dateString }
                    .filter(weekdayColumn == 1)
                    .fetchCount(db)
                return count > 0
            }
        } catch {
            return false
        }
    }

    static func tripIdentifiers(routeIdentifiers: [String], activeOn date: Date, directionIdentifier: Int? = nil) -> [String] {
        guard routeIdentifiers.isEmpty == false else {
            return []
        }
        guard let dbQueue = Database.connection else {
            return []
        }

        do {
            return try dbQueue.read { db in
                let activeServiceIdentifiers = try activeServiceIdentifiers(on: date, in: db)
                guard activeServiceIdentifiers.isEmpty == false else {
                    return []
                }

                var request = Trip
                    .filter { routeIdentifiers.contains($0.routeIdentifier) }
                    .filter { activeServiceIdentifiers.contains($0.serviceIdentifier) }
                    .select(Trip.Columns.identifier)

                if let directionIdentifier {
                    request = request.filter { $0.directionIdentifier == directionIdentifier }
                }

                return try request.asRequest(of: String.self).fetchAll(db)
            }
        } catch {
            return []
        }
    }

    static func routeSummaries(stopIdentifier: String, routeIdentifiers: [String], afterTime: Date) -> [StopRouteSummary] {
        guard routeIdentifiers.isEmpty == false else {
            return []
        }
        guard let dbQueue = Database.connection else {
            return []
        }

        let dateString = DateFormatter.PSTDateFormatterDate.string(from: afterTime)
        let timeString = DateFormatter.SQLTimeFormatter.string(from: afterTime)
        let weekdayColumn = weekdayColumnName(for: afterTime)
        let placeholders = routeIdentifiers.map { _ in "?" }.joined(separator: ",")

        let sql = """
            WITH candidates AS (
                SELECT
                    st.arrival_time,
                    t.trip_id,
                    t.route_id,
                    t.trip_headsign,
                    t.direction_id,
                    t.shape_id,
                    r.route_short_name,
                    r.route_long_name,
                    s.stop_id,
                    s.stop_name,
                    s.stop_lat,
                    s.stop_lon,
                    s.routes,
                    ROW_NUMBER() OVER (
                        PARTITION BY t.route_id
                        ORDER BY st.arrival_time ASC, t.trip_id ASC
                    ) AS row_number
                FROM stop_times st
                JOIN trips t ON st.trip_id = t.trip_id
                JOIN routes r ON t.route_id = r.route_id
                JOIN stops s ON st.stop_id = s.stop_id
                JOIN calendar c ON c.service_id = t.service_id
                WHERE st.stop_id = ?
                  AND t.route_id IN (\(placeholders))
                  AND st.arrival_time >= ?
                  AND COALESCE(st.is_laststop, 0) = 0
                  AND c.start_date <= ?
                  AND c.end_date >= ?
                  AND c.\(weekdayColumn) = 1
            )
            SELECT
                arrival_time,
                trip_id,
                route_id,
                trip_headsign,
                direction_id,
                shape_id,
                route_short_name,
                route_long_name,
                stop_id,
                stop_name,
                stop_lat,
                stop_lon,
                routes
            FROM candidates
            WHERE row_number = 1
            ORDER BY CAST(route_short_name AS INTEGER) ASC, route_short_name ASC, arrival_time ASC
            """

        do {
            return try dbQueue.read { db in
                var arguments: [DatabaseValueConvertible?] = [stopIdentifier]
                arguments.append(contentsOf: routeIdentifiers)
                arguments.append(timeString)
                arguments.append(dateString)
                arguments.append(dateString)

                let rows = try StopRouteSummaryRow.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
                return rows.compactMap(\.summary)
            }
        } catch {
            return []
        }
    }

    static func routeStopTimes(stopIdentifier: String, routeIdentifier: String, afterTime: Date) -> [StopRouteSummary] {
        guard let dbQueue = Database.connection else {
            return []
        }

        let dateString = DateFormatter.PSTDateFormatterDate.string(from: afterTime)
        let timeString = DateFormatter.SQLTimeFormatter.string(from: afterTime)
        let weekdayColumn = weekdayColumnName(for: afterTime)

        let sql = """
            SELECT
                st.arrival_time,
                t.trip_id,
                t.route_id,
                t.trip_headsign,
                t.direction_id,
                t.shape_id,
                r.route_short_name,
                r.route_long_name,
                s.stop_id,
                s.stop_name,
                s.stop_lat,
                s.stop_lon,
                s.routes
            FROM stop_times st
            JOIN trips t ON st.trip_id = t.trip_id
            JOIN routes r ON t.route_id = r.route_id
            JOIN stops s ON st.stop_id = s.stop_id
            JOIN calendar c ON c.service_id = t.service_id
            WHERE st.stop_id = ?
              AND t.route_id = ?
              AND st.arrival_time >= ?
              AND COALESCE(st.is_laststop, 0) = 0
              AND c.start_date <= ?
              AND c.end_date >= ?
              AND c.\(weekdayColumn) = 1
            ORDER BY st.arrival_time ASC
            """

        do {
            return try dbQueue.read { db in
                let rows = try StopRouteSummaryRow.fetchAll(
                    db,
                    sql: sql,
                    arguments: [stopIdentifier, routeIdentifier, timeString, dateString, dateString]
                )
                return rows.compactMap(\.summary)
            }
        } catch {
            return []
        }
    }

    static func tripStopTimes(tripIdentifier: String) -> [TripStopSummary] {
        guard let dbQueue = Database.connection else {
            return []
        }

        let sql = """
            SELECT
                st.arrival_time,
                st.stop_sequence,
                s.stop_id,
                s.stop_name,
                s.stop_lat,
                s.stop_lon,
                s.routes
            FROM stop_times st
            JOIN stops s ON st.stop_id = s.stop_id
            WHERE st.trip_id = ?
            ORDER BY st.stop_sequence ASC
            """

        do {
            return try dbQueue.read { db in
                let rows = try Row.fetchAll(db, sql: sql, arguments: [tripIdentifier])
                return rows.compactMap { row in
                    guard let arrivalTimeString = row["arrival_time"] as String?,
                          let arrivalTime = DateFormatter.SQLTimeFormatter.date(from: arrivalTimeString.sanitizedTimeString),
                          let stopSequenceRaw = row["stop_sequence"] as Int64?,
                          let stopIdentifier = row["stop_id"] as String?,
                          let stopLatitude = row["stop_lat"] as Double?,
                          let stopLongitude = row["stop_lon"] as Double? else {
                        return nil
                    }

                    return TripStopSummary(
                        arrivalTime: arrivalTime,
                        stopSequence: Int(stopSequenceRaw),
                        stopIdentifier: stopIdentifier,
                        stopName: row["stop_name"],
                        stopLatitude: stopLatitude,
                        stopLongitude: stopLongitude,
                        stopRoutes: row["routes"]
                    )
                }
            }
        } catch {
            return []
        }
    }

    static func nextTripIdentifier(routeIdentifier: String, directionIdentifier: Int, afterTime: Date) -> String? {
        guard let dbQueue = Database.connection else {
            return nil
        }

        let dateString = DateFormatter.PSTDateFormatterDate.string(from: afterTime)
        let timeString = DateFormatter.SQLTimeFormatter.string(from: afterTime)
        let weekdayColumn = weekdayColumnName(for: afterTime)

        let sql = """
            SELECT st.trip_id
            FROM stop_times st
            JOIN trips t ON st.trip_id = t.trip_id
            JOIN calendar c ON c.service_id = t.service_id
            WHERE t.route_id = ?
              AND t.direction_id = ?
              AND st.stop_sequence = 1
              AND st.arrival_time >= ?
              AND c.start_date <= ?
              AND c.end_date >= ?
              AND c.\(weekdayColumn) = 1
            ORDER BY st.arrival_time ASC
            LIMIT 1
            """

        do {
            return try dbQueue.read { db in
                try String.fetchOne(
                    db,
                    sql: sql,
                    arguments: [routeIdentifier, directionIdentifier, timeString, dateString, dateString]
                )
            }
        } catch {
            return nil
        }
    }

    static func shapes(shapeIdentifier: String) -> [Shape] {
        guard let dbQueue = Database.connection else {
            return []
        }

        do {
            return try dbQueue.read { db in
                try Shape
                    .filter { $0.identifier == shapeIdentifier }
                    .order(Shape.Columns.sequence)
                    .fetchAll(db)
            }
        } catch {
            return []
        }
    }

    static func shapes(tripIdentifier: String) -> [Shape] {
        guard let dbQueue = Database.connection else {
            return []
        }

        do {
            return try dbQueue.read { db in
                guard let shapeIdentifier = try Trip
                    .filter(Trip.Columns.identifier == tripIdentifier)
                    .select(Trip.Columns.shapeIdentifier)
                    .asRequest(of: String.self)
                    .fetchOne(db) else {
                    return []
                }

                return try Shape
                    .filter { $0.identifier == shapeIdentifier }
                    .order(Shape.Columns.sequence)
                    .fetchAll(db)
            }
        } catch {
            return []
        }
    }

    private static func activeServiceIdentifiers(on date: Date, in db: GRDB.Database) throws -> [String] {
        let dateString = DateFormatter.PSTDateFormatterDate.string(from: date)
        let weekdayColumn = weekdayColumn(for: date)

        return try GTFSModel.Calendar
            .filter { $0.startDate <= dateString }
            .filter { $0.endDate >= dateString }
            .filter(weekdayColumn == 1)
            .select(GTFSModel.Calendar.Columns.serviceIdentifier)
            .asRequest(of: String.self)
            .fetchAll(db)
    }

    private static func weekdayColumn(for date: Date) -> Column {
        switch DateFormatter.PSTDateFormatterDay.string(from: date).lowercased() {
        case "monday":
            return GTFSModel.Calendar.Columns.monday
        case "tuesday":
            return GTFSModel.Calendar.Columns.tuesday
        case "wednesday":
            return GTFSModel.Calendar.Columns.wednesday
        case "thursday":
            return GTFSModel.Calendar.Columns.thursday
        case "friday":
            return GTFSModel.Calendar.Columns.friday
        case "saturday":
            return GTFSModel.Calendar.Columns.saturday
        default:
            return GTFSModel.Calendar.Columns.sunday
        }
    }

    private static func weekdayColumnName(for date: Date) -> String {
        switch DateFormatter.PSTDateFormatterDay.string(from: date).lowercased() {
        case "monday":
            return "monday"
        case "tuesday":
            return "tuesday"
        case "wednesday":
            return "wednesday"
        case "thursday":
            return "thursday"
        case "friday":
            return "friday"
        case "saturday":
            return "saturday"
        default:
            return "sunday"
        }
    }

}

extension Int {
    var transitDirectionDescription: String {
        switch self {
        case 0:
            return "Outbound"
        case 1:
            return "Inbound"
        default:
            return "Direction \(self)"
        }
    }
}

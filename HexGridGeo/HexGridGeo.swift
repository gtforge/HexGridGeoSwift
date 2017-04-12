import Foundation

import Morton
import HexGrid

// TODO: port region functionality

private let EarthCircumference: Double = 40075016.685578488
private let EarthMetersPerDegree: Double = 111319.49079327358

public struct Point {
    public let lon: Double
    public let lat: Double

    public init(lon: Double, lat: Double) {
        self.lon = lon
        self.lat = lat
    }
}

public protocol Projection {
    func geoToPoint(geoPoint: Point) -> HexGrid.Point
    func pointToGeo(point: HexGrid.Point) -> Point
}

public class ProjectionNoOp: Projection {
    public init() {
    }
    
    public func geoToPoint(geoPoint: Point) -> HexGrid.Point {
        return HexGrid.Point(x: geoPoint.lon, y: geoPoint.lat)
    }

    public func pointToGeo(point: HexGrid.Point) -> Point {
        return Point(lon: point.x, lat: point.y)
    }
}

public class ProjectionSin: Projection {
    public init() {
    }
    
    public func geoToPoint(geoPoint: Point) -> HexGrid.Point {
        let λ: Double = (geoPoint.lon + 180) * (M_PI / 180)
        let φ: Double = geoPoint.lat * (M_PI / 180)
        let x: Double = (λ * cos(φ)) * ((EarthCircumference / 2) / M_PI)
        let y: Double = φ * ((EarthCircumference / 2) / M_PI)
        return HexGrid.Point(x: x, y: y)
    }

    public func pointToGeo(point: HexGrid.Point) -> Point {
        let φ: Double = point.y / ((EarthCircumference / 2) / M_PI)
        let λ: Double = point.x / (cos(φ) * ((EarthCircumference / 2) / M_PI))
        let lon: Double = (λ / (M_PI / 180)) - 180
        let lat: Double = φ / (M_PI / 180)
        return Point(lon: lon, lat: lat)
    }
}

public class ProjectionAEP: Projection {
    public init() {
    }

    public func geoToPoint(geoPoint: Point) -> HexGrid.Point {
        let θ: Double = geoPoint.lon * (M_PI / 180)
        let ρ: Double = M_PI / 2 - (geoPoint.lat * (M_PI / 180))
        let x: Double = ρ * sin(θ)
        let y: Double = -ρ * cos(θ)
        return HexGrid.Point(x: x, y: y)
    }

    public func pointToGeo(point: HexGrid.Point) -> Point {
        let θ: Double = atan2(point.x, -point.y)
        let ρ: Double = point.x / sin(θ)
        let lat: Double = (M_PI / 2 - ρ) / (M_PI / 180)
        let lon: Double = θ / (M_PI / 180)
        return Point(lon: lon, lat: lat)
    }
}

public class ProjectionSM: Projection {
    public init() {
    }

    public func geoToPoint(geoPoint: Point) -> HexGrid.Point {
        let latR: Double = geoPoint.lat * (M_PI / 180)
        let x: Double = geoPoint.lon * EarthMetersPerDegree
        let y: Double = ((log(tan(latR) + (1 / cos(latR)))) / M_PI) * (EarthCircumference / 2)
        return HexGrid.Point(x: x, y: y)
    }

    public func pointToGeo(point: HexGrid.Point) -> Point {
        let lon: Double = point.x / EarthMetersPerDegree
        let lat: Double = asin(tanh((point.y / (EarthCircumference / 2)) * M_PI)) * (180 / M_PI)
        return Point(lon: lon, lat: lat)
    }
}

public class Grid {
    let hexgrid: HexGrid.Grid
    let projection: Projection

    public init(orientation: Orientation, size: Double, projection: Projection) {
        self.hexgrid = HexGrid.Grid(
            orientation: orientation,
            origin: HexGrid.Point(x: 0.0, y: 0.0),
            size: HexGrid.Point(x: size, y: size),
            mort: try! Morton64(dimensions: 2, bits: 32)
        )
        self.projection = projection
    }

    public func hexToCode(hex: Hex) throws -> Int64 {
        return try hexgrid.hexToCode(hex)
    }

    public func hexFromCode(code: Int64) -> Hex {
        return hexgrid.hexFromCode(code)
    }

    public func hexAt(geoPoint: Point) -> Hex {
        return hexgrid.hexAt(projection.geoToPoint(geoPoint))
    }

    public func hexCenter(hex: Hex) -> Point {
        return projection.pointToGeo(hexgrid.hexCenter(hex))
    }

    public func hexCorners(hex: Hex) -> [Point] {
        return hexgrid.hexCorners(hex).map(projection.pointToGeo)
    }

    public func hexNeighbors(hex: Hex, layers: Int64) -> [Hex] {
        return hexgrid.hexNeighbors(hex, layers: layers)
    }
}

import Foundation

import Quick
import Nimble

import HexGrid
import HexGridGeo

final class HexGridGeoSpec: QuickSpec {
    override func spec() {
        func doComparePoints(expected: HexGrid.Point, got: HexGrid.Point, precision: Double) {
            it("should have close enough points") {
                expect(abs(expected.x - got.x)).to(beLessThan(precision))
                expect(abs(expected.y - got.y)).to(beLessThan(precision))
            }
        }

        func doCompareGeoPoints(expected: HexGridGeo.Point, got: HexGridGeo.Point, precision: Double) {
            it("should have close enough geo points") {
                expect(abs(expected.lon - got.lon)).to(beLessThan(precision))
                expect(abs(expected.lat - got.lat)).to(beLessThan(precision))
            }
        }

        describe("projection noop") {
            let projection: Projection = ProjectionNoOp()
            let geoPoint: HexGridGeo.Point = HexGridGeo.Point(lon: -73.0, lat: 40.0)
            let point: HexGrid.Point = projection.geoToPoint(geoPoint)
            let recodedGeoPoint: HexGridGeo.Point = projection.pointToGeo(point)
            doComparePoints(HexGrid.Point(x: -73.0, y: 40.0), got: point, precision: 0.00001)
            doCompareGeoPoints(geoPoint, got: recodedGeoPoint, precision: 0.00001)
        }

        describe("projection sin") {
            let projection: Projection = ProjectionSin()
            let geoPoint: HexGridGeo.Point = HexGridGeo.Point(lon: -73.0, lat: 40.0)
            let point: HexGrid.Point = projection.geoToPoint(geoPoint)
            let recodedGeoPoint: HexGridGeo.Point = projection.pointToGeo(point)
            doComparePoints(HexGrid.Point(x: 9124497.47463, y: 4452779.63173), got: point, precision: 0.00001)
            doCompareGeoPoints(geoPoint, got: recodedGeoPoint, precision: 0.00001)
        }

        describe("projection aep") {
            let projection: Projection = ProjectionAEP()
            let geoPoint: HexGridGeo.Point = HexGridGeo.Point(lon: -73.0, lat: 40.0)
            let point: HexGrid.Point = projection.geoToPoint(geoPoint)
            let recodedGeoPoint: HexGridGeo.Point = projection.pointToGeo(point)
            doComparePoints(HexGrid.Point(x: -0.83453, y: -0.25514), got: point, precision: 0.00001)
            doCompareGeoPoints(geoPoint, got: recodedGeoPoint, precision: 0.00001)
        }

        describe("projection sm") {
            let projection: Projection = ProjectionSM()
            let geoPoint: HexGridGeo.Point = HexGridGeo.Point(lon: -73.0, lat: 40.0)
            let point: HexGrid.Point = projection.geoToPoint(geoPoint)
            let recodedGeoPoint: HexGridGeo.Point = projection.pointToGeo(point)
            doComparePoints(HexGrid.Point(x: -8126322.82791, y: 4865942.27950), got: point, precision: 0.00001)
            doCompareGeoPoints(geoPoint, got: recodedGeoPoint, precision: 0.00001)
        }

        describe("simple") {
            let grid: HexGridGeo.Grid = HexGridGeo.Grid(orientation: OrientationFlat, size: 500, projection: ProjectionSM())
            let corners: [HexGridGeo.Point] = grid.hexCorners(grid.hexAt(HexGridGeo.Point(lon: -73.0, lat: 40.0)))
            let expectedCorners: [HexGridGeo.Point] = [
              HexGridGeo.Point(lon: -72.99485, lat: 39.99877), HexGridGeo.Point(lon: -72.99710, lat: 40.00175),
              HexGridGeo.Point(lon: -73.00159, lat: 40.00175), HexGridGeo.Point(lon: -73.00384, lat: 39.99877),
              HexGridGeo.Point(lon: -73.00159, lat: 39.99579), HexGridGeo.Point(lon: -72.99710, lat: 39.99579)]
            var i: Int = 0
            while i < 6 {
                doCompareGeoPoints(expectedCorners[i], got: corners[i], precision: 0.00001)
                i += 1
            }
        }
    }
}

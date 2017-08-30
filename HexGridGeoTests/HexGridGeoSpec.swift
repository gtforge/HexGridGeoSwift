import Foundation

import Quick
import Nimble

import HexGrid
import HexGridGeo

final class HexGridGeoSpec: QuickSpec {
    override func spec() {
        func doComparePoints(_ expected: HexGrid.Point, got: HexGrid.Point, precision: Double) {
            it("should have close enough points") {
                expect(got.x).to(beCloseTo(expected.x, within: precision))
                expect(got.y).to(beCloseTo(expected.y, within: precision))
            }
        }

        func doCompareGeoPoints(_ expected: HexGridGeo.Point, got: HexGridGeo.Point, precision: Double) {
            it("should have close enough geo points") {
                expect(got.lon).to(beCloseTo(expected.lon, within: precision))
                expect(got.lat).to(beCloseTo(expected.lat, within: precision))
            }
        }

        describe("projection noop") {
            let projection = ProjectionNoOp()
            let geoPoint = HexGridGeo.Point(lon: -73.0, lat: 40.0)
            let point = projection.geoToPoint(geoPoint)
            let recodedGeoPoint = projection.pointToGeo(point)
            doComparePoints(HexGrid.Point(x: -73.0, y: 40.0), got: point, precision: 0.00001)
            doCompareGeoPoints(geoPoint, got: recodedGeoPoint, precision: 0.00001)
        }

        describe("projection sin") {
            let projection = ProjectionSin()
            let geoPoint = HexGridGeo.Point(lon: -73.0, lat: 40.0)
            let point = projection.geoToPoint(geoPoint)
            let recodedGeoPoint = projection.pointToGeo(point)
            doComparePoints(HexGrid.Point(x: 9124497.47463, y: 4452779.63173), got: point, precision: 0.00001)
            doCompareGeoPoints(geoPoint, got: recodedGeoPoint, precision: 0.00001)
        }

        describe("projection aep") {
            let projection = ProjectionAEP()
            let geoPoint = HexGridGeo.Point(lon: -73.0, lat: 40.0)
            let point  = projection.geoToPoint(geoPoint)
            let recodedGeoPoint = projection.pointToGeo(point)
            doComparePoints(HexGrid.Point(x: -0.83453, y: -0.25514), got: point, precision: 0.00001)
            doCompareGeoPoints(geoPoint, got: recodedGeoPoint, precision: 0.00001)
        }

        describe("projection sm") {
            let projection = ProjectionSM()
            let geoPoint = HexGridGeo.Point(lon: -73.0, lat: 40.0)
            let point = projection.geoToPoint(geoPoint)
            let recodedGeoPoint = projection.pointToGeo(point)
            doComparePoints(HexGrid.Point(x: -8126322.82791, y: 4865942.27950), got: point, precision: 0.00001)
            doCompareGeoPoints(geoPoint, got: recodedGeoPoint, precision: 0.00001)
        }

        describe("simple") {
            let grid = HexGridGeo.Grid(orientation: OrientationFlat, size: 500, projection: ProjectionSM())
            let corners = grid.hexCorners(grid.hexAt(HexGridGeo.Point(lon: -73.0, lat: 40.0)))
            let expectedCorners = [
                HexGridGeo.Point(lon: -72.99485, lat: 39.99877), HexGridGeo.Point(lon: -72.99710, lat: 40.00175),
                HexGridGeo.Point(lon: -73.00159, lat: 40.00175), HexGridGeo.Point(lon: -73.00384, lat: 39.99877),
                HexGridGeo.Point(lon: -73.00159, lat: 39.99579), HexGridGeo.Point(lon: -72.99710, lat: 39.99579)
            ]
            (0..<6).forEach {
                doCompareGeoPoints(expectedCorners[$0], got: corners[$0], precision: 0.00001)
            }
        }
    }
}

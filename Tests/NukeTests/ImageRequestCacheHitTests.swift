import XCTest
@testable import Nuke

class ImageRequestCacheHitTests: XCTestCase {
    var pipeline: ImagePipeline!
    var dataLoader: MockDataLoader!
    var dataCache: MockDataCache!

    override func setUp() {
        super.setUp()
        dataLoader = MockDataLoader()
        dataCache = MockDataCache()
        pipeline = ImagePipeline {
            $0.dataLoader = dataLoader
            $0.dataCache = dataCache
            $0.imageCache = nil
            $0.dataCachePolicy = .storeOriginalData
        }
    }

    func testCacheHitWithDifferentProcessors() {
        let url = URL(string: "https://pbs.twimg.com/media/Gs42NzKbEAALxXJ?format=jpg&name=large")!

        let request1 = ImageRequest(url: url, processors: [ImageProcessors.Resize(width: 100, unit: .pixels)])
        expect(pipeline).toLoadImage(with: request1)
        wait()
        XCTAssertEqual(dataLoader.createdTaskCount, 1)
        XCTAssertEqual(dataCache.store.count, 1)

        let request2 = ImageRequest(url: url, processors: [ImageProcessors.Resize(width: 200, unit: .pixels)])
        expect(pipeline).toLoadImage(with: request2)
        wait()

        XCTAssertEqual(dataLoader.createdTaskCount, 1)
        XCTAssertEqual(dataCache.store.count, 1)
    }
}

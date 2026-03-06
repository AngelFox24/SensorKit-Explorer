import SwiftUI
import UniformTypeIdentifiers.UTType
struct HapticPatternFile: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(patternData: Data) {
        self.data = patternData
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(regularFileWithContents: data)
    }
}

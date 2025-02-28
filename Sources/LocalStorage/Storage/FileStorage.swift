import Foundation

/// Storage that writes data to the filesystem (documents, caches or library directory).
public final class FileStorage: Storage {

    /// MARK: Properties

    /// The absolute path to a file in which the data is stored
    public let path: String

    /// Indicates the chosen SearchPathDirectory (either documents, caches or library) of the storage file
    public let searchPathDirectory: FileStorage.SearchPathDirectory

    /// FileManager used by storage
    public let fileManager: FileManager

    /// Returns or sets raw data stored in file storage
    private(set) public var rawData: [Data] {
        get {
            // load object from file at path
            guard let storedData = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [Data] else { return [] }
            return storedData
        } set {
            // save data at path
            NSKeyedArchiver.archiveRootObject(newValue, toFile: path)
        }
    }

    // MARK: Init

    /// Initializes a FileStorage with a relative path referencing a file
    /// to be saved on the file storage.
    ///
    /// - Parameters:
    ///     - fileManager: FileManager used to store data in files.
    ///     - relativePath: Relative path in FileStorage to store data.
    ///     - searchPathDirectory: A CustomSearchPathDirectory object specifying the type of directory the file should be saved in.
    ///     - isExcludedFromBackup: flag which indicates whether the file should be backed up in the Cloud or not
    /// - Throws: a FileStorageError
    public init (fileManager: FileManager = .default,
                 relativePath: String,
                 searchPathDirectory: SearchPathDirectory,
                 isExcludedFromBackup: Bool = true) throws {

        self.searchPathDirectory = searchPathDirectory
        self.fileManager = fileManager
        path = try FileStorage.createStorageFile(in: searchPathDirectory, relativePath: relativePath, fileManager: fileManager)
        try FileStorage.setBackupResourceValues(isExcludedFromBackup: isExcludedFromBackup, for: path)
    }

    // MARK: Save

    /// Saves a single object to storage.
    ///
    /// - Parameters:
    ///   - object: Object to be saved
    ///   - with: Encoder to use for storage operation
    /// - Throws: Encdoding error
    public func append<T, E>(_ object: T, using encoder: E) throws where T == E.Encodable, E: Encoder {
        var storedData = rawData
        storedData.append(try encoder.encode(object: object))
        rawData = storedData
    }

    /// Appends a list of objects to storage.
    ///
    /// - Parameters:
    ///   - object: Objects to be saved
    ///   - with: Encoder to use for storage operation
    /// - Throws: Encdoding error
    public func append<T, E>(all objects: [T], using encoder: E) throws where T == E.Encodable, E: Encoder {

        // encode list of object instance to a data
        let encodedObjects = try objects.map { try encoder.encode(object: $0) }

        // append encoded objects to stored data list
        var storedData = rawData
        storedData.append(contentsOf: encodedObjects)
        rawData = storedData
    }

    // MARK: Load

    /// Loads list of model instances that were decodable with the given decoder.
    ///
    /// - decoder: Decoder to use to decode stored object data to a concrete instance
    /// - Returns: Return List of decoded models
    public func all<T, D>(using decoder: D) throws -> [T] where T == D.Decodable, D: Decoder {
        return try rawData.compactMap { try decoder.decode(data: $0) }
    }

    // MARK: Delete

    /// Removes a object from storage matching predicate
    ///
    /// - Parameters:
    ///   - decoder: Decoder to use to decode stored object data to a concrete instance
    ///   - encoder : Encoder to use to encode model to data
    ///   - predicate: A closure that takes an element of the
    ///   storage as its argument and returns a Boolean value indicating
    ///   whether the element is a match.
    /// - Returns: Removed object or nil if nothing was removed
    /// - Throws: Decoding or encoding error
    public func remove<T, D, E>(using decoder: D, encoder: E, where predicate: (T) -> Bool) throws -> T?
        where T == D.Decodable, D: Decoder, E: Encoder, D.Decodable == E.Encodable {
        // Make list of stored models mutable to return instance later
        var storedModels = try all(using: decoder)

        /// return nil if there is no instance matching predicate
        guard let indexToRemove = storedModels.firstIndex(where: predicate) else { return nil }

        // Remove object at given index from stored data list
        // and overwrite storage with new list
        var storedData = rawData
        storedData.remove(at: indexToRemove)
        rawData = storedData
        return storedModels.remove(at: indexToRemove)
    }

    /// Replaces stored data with given list of objects
    ///
    /// - Parameters:
    ///   - objects: Objects to replace stored items
    ///   - encoder : Encoder to use to encode model to data
    /// - Throws: Encoding error
    public func replaceAll<T, E>(with objects: [T], using encoder: E) throws where T == E.Encodable, E: Encoder {
        // encode list of object instance to a data
        rawData = try objects.map { try encoder.encode(object: $0) }
    }

    /// Removes all objects from storage
    public func clear() throws {
        rawData = []
    }

    /// Deletes storage file
    public func delete() throws {
        // delete file from system
        try fileManager.removeItem(atPath: path)
    }
}

// MARK: - File handling

extension FileStorage {

    /// Creates a file to store data if it does not exist.
    ///
    /// - Parameters:
    ///   - directory: SearchPath directory to store data to
    ///   - relativePath: Relative path within given directory
    ///   - fileManager: Filemanager to use to create files and directories
    /// - Returns: Path store storageFile
    /// - Throws: Error
    private static func createStorageFile(in directory: SearchPathDirectory,
                                          relativePath: String,
                                          fileManager: FileManager) throws -> String {

        guard let url = fileManager.urls(for: directory.searchPath, in: .userDomainMask).first else {
            throw FileStorageError.invalidPath("Could not find url for directory: \(directory.searchPath)")
        }

        let directoryURL = url.appendingPathComponent(relativePath)
        let storageFileURL = directoryURL.appendingPathComponent("storage_file")

        // check if the directory at path exists, create it and its intermediate directories otherwise
        var isDirectory: ObjCBool = true

        // Check if storage file already exists and return immediately if possible
        guard !fileManager.fileExists(atPath: storageFileURL.path, isDirectory: &isDirectory) else {
            // File at path exists but is a directory not a storage file
            if isDirectory.boolValue {
                throw FileStorageError.invalidPath("File at path \(directoryURL.path) is a directory not storage file bla")
            }
            // Storage file exists
            return storageFileURL.path
        }

        // Check if directory which will contain the storage file needs to be created
        if !fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        // If there is a file at the directory path but is not a directory, throw an error
        } else if isDirectory.boolValue == false {
            throw FileStorageError.invalidPath("File at path \(directoryURL.path) is a directory not storage file bla")
        }

        // Create the storage file
        fileManager.createFile(atPath: storageFileURL.path, contents: nil)
        return storageFileURL.path

    }

    /// Sets resource values to the given path
    ///
    /// - Parameters:
    ///   - isExcludedFromBackup: If excluded from iCloud backup
    ///   - path: Path to set resource values to
    private static func setBackupResourceValues(isExcludedFromBackup: Bool, for path: String) throws {
        var url = URL(fileURLWithPath: path, isDirectory: false)
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = isExcludedFromBackup
        try url.setResourceValues(resourceValues)
    }
}

// MARK: - SearchPathDirectory

extension FileStorage {

    /// A custom enum used to limit the possible types of SearchPathDirectories to three to be certain
    /// that we have access to the specified location.
    ///
    /// - documents: The document directory
    /// - cashes: The location of discardable cache files (Library/Caches)
    /// - library: Various user-visible documentation, support, and configuration files (/Library)
    public enum SearchPathDirectory {
        case documents
        case cashes
        case library
        case applicationSupport

        /// The FileManager.SearchPathDirectory representation
        var searchPath: FileManager.SearchPathDirectory {
            switch self {
            case .documents:
                return .documentDirectory
            case .cashes:
                return .cachesDirectory
            case .library:
                return .libraryDirectory
            case .applicationSupport:
                return .applicationSupportDirectory
            }
        }
    }
}

// MARK: - Error

extension FileStorage {

    /// A custom error type used to signify an invalid path when creating the path variable pointing to the file's location.
    ///
    /// - invalidPathError: an invalid path was passed to the FileStorage
    public enum FileStorageError: Swift.Error, CustomStringConvertible {
        case invalidPath(String)
        case resourceValues(String)

        public var description: String {
            switch self {
            case .invalidPath(let message): return "Invalid Path: \(message)"
            case .resourceValues(let message): return "Error with resource values: \(message)"
            }
        }
    }

}

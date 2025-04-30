import Darwin
import Foundation

extension URL {

    /// A wrapper around errors returned from system calls.
    ///
    /// This error type is simply a wrapper for `errno`. Due to the large range of possible values, I did not try to create a more
    /// detailed error type. You can learn more about the values with `man 2 errno`.
    enum FileStatError: Error, LocalizedError {

        /// Raised when reading file status fails.
        case cannotEvaluateFileStatusWithErrno(Int32)

        var errorDescription: String? {
            switch self {
            case .cannotEvaluateFileStatusWithErrno(let errno):
                // I added the ones I thought would be most likely to occur, but this is by no means
                // a complete list of cases.
                let errorIntro = "Failed to evaluate file status"

                switch errno {
                case EACCES:
                    return "\(errorIntro): Permission denied."

                case EFAULT:
                    return "\(errorIntro): Bad address."

                case ELOOP:
                    return "\(errorIntro): Too many symbolic links encountered."

                case ENOENT:
                    return "\(errorIntro): No such file or directory."

                case ENOTDIR:
                    return "\(errorIntro): A component of the path is not a directory."

                default:
                    return "\(errorIntro) with error code: \(errno)"
                }
            }
        }
    }

    /// Returns the path of the `URL` without percent encoding.
    var pathWithoutPercentEncoding: String {
        return self.path(percentEncoded: false)
    }

    /// Checks if a file is owned by root.
    var isOwnedByRoot: Bool {
        get throws {
            var statInfo = stat()

            guard stat(self.pathWithoutPercentEncoding, &statInfo) == 0 else {
                throw FileStatError.cannotEvaluateFileStatusWithErrno(errno)
            }

            // UID of root is 0.
            return statInfo.st_uid == 0
        }
    }
}

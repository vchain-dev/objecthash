import CommonCrypto

/*
   Example of usage:
   let string = "This is a string we want to hash"
   var digester = Digester(algorithm: .sha256)

   let buffer = string.toBytes()
   digester.update(buffer: buffer, byteCount: buffer.length)

   let digest = digester.final()
*/

class Digester {
    public enum Algorithm {
        case md5
        case sha256
    }

    var engine: DigesterEngine

    /**
       Create an algorithm-specific digest calculator
       - parameter algorithm: the desired message digest algorithm
     */
    public init(algorithm: Algorithm) {
        switch algorithm {
        case .md5:
            engine = DigesterEngineCC<CC_MD5_CTX>(
                initializer: CC_MD5_Init,
                updater: CC_MD5_Update,
                finalizer: CC_MD5_Final,
                length: CC_MD5_DIGEST_LENGTH
            )
        case .sha256:
            engine = DigesterEngineCC<CC_SHA256_CTX>(
                initializer: CC_SHA256_Init,
                updater: CC_SHA256_Update,
                finalizer: CC_SHA256_Final,
                length: CC_SHA256_DIGEST_LENGTH
            )
        }
    }

    /**
        Low-level update routine. Updates the message digest calculation with
        the contents of a byte buffer.

        - parameter buffer: the buffer
        - parameter byteCount: number of bytes in buffer
        - returns: this Digest object (for optional chaining)
    */

    // TODO: check how to work with UnsafeRawPointers and calculate byteCount within `update`
    open func update(buffer: UnsafeRawPointer, byteCount: size_t) -> Self? {
        engine.update(buffer: buffer, byteCount: CC_LONG(byteCount))
        return self
    }

    /**
       Completes the calculate of the message digest
       - returns: the message digest
     */
    open func final() -> [UInt8] {
        return engine.final()
    }
}

protocol DigesterEngine {
    func update(buffer: UnsafeRawPointer, byteCount: CC_LONG)
    func final() -> [UInt8]
}

/**
 * Wraps the underlying algorithm specific structures and calls
 * in a generic interface.
 */
class DigesterEngineCC<C>: DigesterEngine {
    typealias Context = UnsafeMutablePointer<C>
    typealias Buffer = UnsafeRawPointer
    typealias Digest = UnsafeMutablePointer<UInt8>
    typealias Initializer = (Context) -> (Int32)
    typealias Updater = (Context, Buffer, CC_LONG) -> (Int32)
    typealias Finalizer = (Digest, Context) -> (Int32)

    let context = Context.allocate(capacity: 1)
    var initializer: Initializer
    var updater: Updater
    var finalizer: Finalizer
    var length: Int32

    init(initializer: @escaping Initializer, updater: @escaping Updater, finalizer: @escaping Finalizer, length: Int32) {
        self.initializer = initializer
        self.updater = updater
        self.finalizer = finalizer
        self.length = length
        _ = initializer(context)
    }

    deinit {
        context.deallocate()
    }

    func update(buffer: Buffer, byteCount: CC_LONG) {
        _ = updater(context, buffer, byteCount)
    }

    func final() -> [UInt8] {
        let digestLength = Int(self.length)
        var digest = Array<UInt8>(repeating: 0, count: digestLength)
        _ = finalizer(&digest, context)
        return digest
    }
}

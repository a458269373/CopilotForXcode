import CodableWrappers
import Foundation

struct Cancellable {
    let cancel: () -> Void
    func callAsFunction() {
        cancel()
    }
}

public struct ChatMessage: Equatable, Codable {
    public enum Role: String, Codable, Equatable {
        case system
        case user
        case assistant
        case function
    }

    public struct FunctionCall: Codable, Equatable {
        public var name: String
        public var arguments: String
        public init(name: String, arguments: String) {
            self.name = name
            self.arguments = arguments
        }
    }

    public struct Reference: Codable, Equatable {
        public var title: String
        public var subTitle: String
        public var uri: String
        public var startLine: Int?
        public var endLine: Int?
        public var metadata: [String: String]

        public init(
            title: String,
            subTitle: String,
            uri: String,
            startLine: Int?,
            endLine: Int?,
            metadata: [String: String]
        ) {
            self.title = title
            self.subTitle = subTitle
            self.uri = uri
            self.metadata = metadata
        }
    }

    /// The role of a message.
    public var role: Role

    /// The content of the message, either the chat message, or a result of a function call.
    public var content: String? {
        didSet { tokensCount = nil }
    }

    /// A function call from the bot.
    public var functionCall: FunctionCall? {
        didSet { tokensCount = nil }
    }

    /// The function name of a reply to a function call.
    public var name: String? {
        didSet { tokensCount = nil }
    }

    /// The summary of a message that is used for display.
    public var summary: String?

    /// The id of the message.
    public var id: String

    /// The number of tokens of this message.
    var tokensCount: Int?

    /// The references of this message.
    @FallbackDecoding<EmptyArray<Reference>>
    public var references: [Reference]

    /// Is the message considered empty.
    var isEmpty: Bool {
        if let content, !content.isEmpty { return false }
        if let functionCall, !functionCall.name.isEmpty { return false }
        if let name, !name.isEmpty { return false }
        return true
    }

    public init(
        id: String = UUID().uuidString,
        role: Role,
        content: String?,
        name: String? = nil,
        functionCall: FunctionCall? = nil,
        summary: String? = nil,
        tokenCount: Int? = nil,
        references: [Reference] = []
    ) {
        self.role = role
        self.content = content
        self.name = name
        self.functionCall = functionCall
        self.summary = summary
        self.id = id
        tokensCount = tokenCount
        self.references = references
    }
}


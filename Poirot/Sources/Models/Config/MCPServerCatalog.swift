import Foundation

/// A catalog entry describing an MCP server that can be installed via the setup wizard.
struct MCPCatalogEntry: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let category: MCPCatalogCategory
    let command: String
    let args: [String]
    let envKeys: [MCPEnvKey]

    /// Whether this server uses npx as its command runner.
    var isNpx: Bool {
        command == "npx"
    }
}

/// A required or optional environment variable for an MCP server.
struct MCPEnvKey: Identifiable {
    let id: String
    let label: String
    let description: String
    let placeholder: String
    let isRequired: Bool
    let isSensitive: Bool

    init(
        id: String,
        label: String,
        description: String,
        placeholder: String = "",
        isRequired: Bool = true,
        isSensitive: Bool = false
    ) {
        self.id = id
        self.label = label
        self.description = description
        self.placeholder = placeholder
        self.isRequired = isRequired
        self.isSensitive = isSensitive
    }
}

/// Categories for grouping MCP servers in the catalog.
enum MCPCatalogCategory: String, CaseIterable {
    case developer = "Developer Tools"
    case productivity = "Productivity"
    case data = "Data & Search"
    case filesystem = "Filesystem"

    var icon: String {
        switch self {
        case .developer: "hammer"
        case .productivity: "tray.full"
        case .data: "magnifyingglass.circle"
        case .filesystem: "folder"
        }
    }
}

/// The bundled catalog of popular MCP servers.
enum MCPServerCatalog {
    static let entries: [MCPCatalogEntry] = [
        // MARK: - Developer Tools

        MCPCatalogEntry(
            id: "github",
            name: "GitHub",
            description: "Interact with GitHub repositories, issues, pull requests, and more.",
            icon: "arrow.triangle.branch",
            category: .developer,
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-github"],
            envKeys: [
                MCPEnvKey(
                    id: "GITHUB_PERSONAL_ACCESS_TOKEN",
                    label: "Personal Access Token",
                    description: "GitHub PAT with repo access",
                    placeholder: "ghp_...",
                    isSensitive: true
                ),
            ]
        ),

        MCPCatalogEntry(
            id: "playwright",
            name: "Playwright",
            description: "Browser automation for testing and web scraping.",
            icon: "theatermasks",
            category: .developer,
            command: "npx",
            args: ["-y", "@anthropic-ai/mcp-server-playwright"],
            envKeys: []
        ),

        MCPCatalogEntry(
            id: "puppeteer",
            name: "Puppeteer",
            description: "Headless Chrome browser automation and screenshots.",
            icon: "globe",
            category: .developer,
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-puppeteer"],
            envKeys: []
        ),

        MCPCatalogEntry(
            id: "sentry",
            name: "Sentry",
            description: "Access Sentry issues, events, and error tracking data.",
            icon: "ladybug",
            category: .developer,
            command: "npx",
            args: ["-y", "@sentry/mcp-server"],
            envKeys: [
                MCPEnvKey(
                    id: "SENTRY_AUTH_TOKEN",
                    label: "Auth Token",
                    description: "Sentry authentication token",
                    placeholder: "sntrys_...",
                    isSensitive: true
                ),
                MCPEnvKey(
                    id: "SENTRY_ORG",
                    label: "Organization",
                    description: "Sentry organization slug",
                    placeholder: "my-org",
                    isRequired: false
                ),
            ]
        ),

        MCPCatalogEntry(
            id: "linear",
            name: "Linear",
            description: "Manage Linear issues, projects, and workflows.",
            icon: "list.bullet.rectangle",
            category: .developer,
            command: "npx",
            args: ["-y", "@anthropic-ai/mcp-server-linear"],
            envKeys: [
                MCPEnvKey(
                    id: "LINEAR_API_KEY",
                    label: "API Key",
                    description: "Linear personal API key",
                    placeholder: "lin_api_...",
                    isSensitive: true
                ),
            ]
        ),

        // MARK: - Productivity

        MCPCatalogEntry(
            id: "slack",
            name: "Slack",
            description: "Read and send Slack messages, manage channels.",
            icon: "number",
            category: .productivity,
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-slack"],
            envKeys: [
                MCPEnvKey(
                    id: "SLACK_BOT_TOKEN",
                    label: "Bot Token",
                    description: "Slack bot OAuth token",
                    placeholder: "xoxb-...",
                    isSensitive: true
                ),
                MCPEnvKey(
                    id: "SLACK_TEAM_ID",
                    label: "Team ID",
                    description: "Slack workspace team ID",
                    placeholder: "T0123456789"
                ),
            ]
        ),

        MCPCatalogEntry(
            id: "notion",
            name: "Notion",
            description: "Search, read, and create Notion pages and databases.",
            icon: "doc.richtext",
            category: .productivity,
            command: "npx",
            args: ["-y", "@notionhq/notion-mcp-server"],
            envKeys: [
                MCPEnvKey(
                    id: "OPENAPI_MCP_HEADERS",
                    label: "Authorization Header",
                    description: "Notion integration token as JSON header",
                    placeholder: "{\"Authorization\": \"Bearer ntn_...\"}",
                    isSensitive: true
                ),
            ]
        ),

        MCPCatalogEntry(
            id: "google-drive",
            name: "Google Drive",
            description: "Search and access Google Drive files.",
            icon: "externaldrive.badge.icloud",
            category: .productivity,
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-gdrive"],
            envKeys: [
                MCPEnvKey(
                    id: "GDRIVE_CLIENT_ID",
                    label: "Client ID",
                    description: "Google OAuth client ID",
                    placeholder: "123456789.apps.googleusercontent.com"
                ),
                MCPEnvKey(
                    id: "GDRIVE_CLIENT_SECRET",
                    label: "Client Secret",
                    description: "Google OAuth client secret",
                    isSensitive: true
                ),
            ]
        ),

        // MARK: - Data & Search

        MCPCatalogEntry(
            id: "brave-search",
            name: "Brave Search",
            description: "Web and local search powered by Brave.",
            icon: "magnifyingglass",
            category: .data,
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-brave-search"],
            envKeys: [
                MCPEnvKey(
                    id: "BRAVE_API_KEY",
                    label: "API Key",
                    description: "Brave Search API key",
                    isSensitive: true
                ),
            ]
        ),

        MCPCatalogEntry(
            id: "fetch",
            name: "Fetch",
            description: "Fetch and convert web content to markdown.",
            icon: "arrow.down.doc",
            category: .data,
            command: "npx",
            args: ["-y", "@anthropic-ai/mcp-server-fetch"],
            envKeys: []
        ),

        MCPCatalogEntry(
            id: "postgres",
            name: "PostgreSQL",
            description: "Query and inspect PostgreSQL databases.",
            icon: "cylinder",
            category: .data,
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-postgres"],
            envKeys: [
                MCPEnvKey(
                    id: "POSTGRES_CONNECTION_STRING",
                    label: "Connection String",
                    description: "PostgreSQL connection URI",
                    placeholder: "postgresql://user:pass@localhost:5432/db",
                    isSensitive: true
                ),
            ]
        ),

        MCPCatalogEntry(
            id: "sqlite",
            name: "SQLite",
            description: "Query and manage SQLite databases.",
            icon: "tablecells",
            category: .data,
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-sqlite"],
            envKeys: [
                MCPEnvKey(
                    id: "SQLITE_DB_PATH",
                    label: "Database Path",
                    description: "Path to the SQLite database file",
                    placeholder: "/path/to/database.db"
                ),
            ]
        ),

        // MARK: - Filesystem

        MCPCatalogEntry(
            id: "filesystem",
            name: "Filesystem",
            description: "Secure read/write access to specified directories.",
            icon: "folder.badge.gearshape",
            category: .filesystem,
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-filesystem"],
            envKeys: [
                MCPEnvKey(
                    id: "ALLOWED_DIRS",
                    label: "Allowed Directories",
                    description: "Comma-separated list of allowed directory paths",
                    placeholder: "/Users/me/projects,/tmp"
                ),
            ]
        ),

        MCPCatalogEntry(
            id: "memory",
            name: "Memory",
            description: "Persistent memory using a knowledge graph.",
            icon: "brain",
            category: .filesystem,
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-memory"],
            envKeys: []
        ),

        MCPCatalogEntry(
            id: "everart",
            name: "EverArt",
            description: "AI image generation via EverArt models.",
            icon: "paintpalette",
            category: .data,
            command: "npx",
            args: ["-y", "@modelcontextprotocol/server-everart"],
            envKeys: [
                MCPEnvKey(
                    id: "EVERART_API_KEY",
                    label: "API Key",
                    description: "EverArt API key",
                    isSensitive: true
                ),
            ]
        ),
    ]

    /// Returns catalog entries matching the given query (fuzzy search on name and description).
    static func search(_ query: String) -> [MCPCatalogEntry] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return entries }
        return entries.filter {
            $0.name.lowercased().contains(q)
                || $0.description.lowercased().contains(q)
                || $0.category.rawValue.lowercased().contains(q)
        }
    }

    /// Returns catalog entries grouped by category.
    static func grouped() -> [(category: MCPCatalogCategory, entries: [MCPCatalogEntry])] {
        MCPCatalogCategory.allCases.compactMap { category in
            let matching = entries.filter { $0.category == category }
            return matching.isEmpty ? nil : (category, matching)
        }
    }
}

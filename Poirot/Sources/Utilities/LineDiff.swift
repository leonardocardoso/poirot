import Foundation

nonisolated struct DiffLine: Identifiable, Equatable {
    let id: Int
    let kind: Kind
    let text: String
    let oldLineNumber: Int?
    let newLineNumber: Int?

    enum Kind: Equatable {
        case context
        case added
        case removed
    }
}

nonisolated enum LineDiff {
    static func diff(old: String, new: String) -> [DiffLine] {
        let oldLines = old.components(separatedBy: "\n")
        let newLines = new.components(separatedBy: "\n")
        return diff(oldLines: oldLines, newLines: newLines)
    }

    static func diff(oldLines: [String], newLines: [String]) -> [DiffLine] {
        let m = oldLines.count
        let n = newLines.count

        // LCS table
        var dp = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        for i in 1 ... max(m, 1) where i <= m {
            for j in 1 ... max(n, 1) where j <= n {
                if oldLines[i - 1] == newLines[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        // Backtrack to produce diff
        var result: [DiffLine] = []
        var lineId = 0
        var i = m
        var j = n

        func append(kind: DiffLine.Kind, text: String, oldNum: Int?, newNum: Int?) {
            result.append(DiffLine(id: lineId, kind: kind, text: text, oldLineNumber: oldNum, newLineNumber: newNum))
            lineId += 1
        }

        while i > 0 || j > 0 {
            if i > 0, j > 0, oldLines[i - 1] == newLines[j - 1] {
                append(kind: .context, text: oldLines[i - 1], oldNum: i, newNum: j)
                i -= 1
                j -= 1
            } else if j > 0, i == 0 || dp[i][j - 1] >= dp[i - 1][j] {
                append(kind: .added, text: newLines[j - 1], oldNum: nil, newNum: j)
                j -= 1
            } else {
                append(kind: .removed, text: oldLines[i - 1], oldNum: i, newNum: nil)
                i -= 1
            }
        }

        return result.reversed().enumerated().map { index, line in
            DiffLine(
                id: index,
                kind: line.kind,
                text: line.text,
                oldLineNumber: line.oldLineNumber,
                newLineNumber: line.newLineNumber
            )
        }
    }

    static func unifiedText(from lines: [DiffLine]) -> String {
        lines.map { line in
            switch line.kind {
            case .context: " \(line.text)"
            case .added: "+\(line.text)"
            case .removed: "-\(line.text)"
            }
        }
        .joined(separator: "\n")
    }
}

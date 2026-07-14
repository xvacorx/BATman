# Graph Report - C:\Github\BATman  (2026-07-14)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 8 nodes · 9 edges · 2 communities
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Write-Centered

## God Nodes (most connected - your core abstractions)
1. `Write-Centered()` - 3 edges
2. `Pause-Menu()` - 2 edges
3. `Show-Header()` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (2 total, 0 thin omitted)

### Community 1 - "Write-Centered"
Cohesion: 0.67
Nodes (3): Pause-Menu(), Show-Header(), Write-Centered()

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Write-Centered()` connect `Write-Centered` to `Toolbox.ps1`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
# Graph Report - C:\Github\BATman  (2026-07-17)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 25 nodes · 25 edges · 6 communities (4 shown, 2 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Toolbox.ps1
- AntiSleep.ps1
- GenerateHash.ps1
- ShutdownTimeout.ps1

## God Nodes (most connected - your core abstractions)
1. `Get-AntiSleepStatus()` - 3 edges
2. `Write-Centered()` - 3 edges
3. `Enable-AntiSleep()` - 2 edges
4. `Disable-AntiSleep()` - 2 edges
5. `Test-IsAdmin()` - 2 edges
6. `Export-HardwareHash()` - 2 edges
7. `Show-Header()` - 2 edges
8. `Start-Monitoring()` - 2 edges
9. `Pause-Menu()` - 2 edges
10. `Show-Header()` - 2 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (6 total, 2 thin omitted)

### Community 0 - "Toolbox.ps1"
Cohesion: 0.32
Nodes (3): Pause-Menu(), Show-Header(), Write-Centered()

### Community 1 - "AntiSleep.ps1"
Cohesion: 0.60
Nodes (3): Disable-AntiSleep(), Enable-AntiSleep(), Get-AntiSleepStatus()

## Knowledge Gaps
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Not enough signal to generate questions. This usually means the corpus has no AMBIGUOUS edges, no bridge nodes, no INFERRED relationships, and all communities are tightly cohesive. Add more files or run with --mode deep to extract richer edges._
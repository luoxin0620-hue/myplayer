# myplayer

## Codex Skills

This repository stores project-local Codex skills under [`.codex/skills`](D:/MyProject/Job_hunting/Project/myplayer/.codex/skills).

Current local skills:

- [`code-quality-coach`](D:/MyProject/Job_hunting/Project/myplayer/.codex/skills/code-quality-coach)
- [`review-changes`](D:/MyProject/Job_hunting/Project/myplayer/.codex/skills/review-changes)

`code-quality-coach` is versioned in this repository and should be edited here first.

After updating a repository skill, sync it back to the user-level Codex install with:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync_codex_skill.ps1
```

The sync script currently targets `code-quality-coach` and copies it from the repository into `%USERPROFILE%\.codex\skills\code-quality-coach`, so Codex can keep using the installed version locally.

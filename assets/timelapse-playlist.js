// zergling-world timelapse playlist
//
// This file is append-only: each archived expression adds one push() line.
// The timelapse player (index.html in this directory) loads this file via a
// <script> tag so it works on file:// in every browser — no fetch / no server.
//
// Format for each entry:
//   { file: "<basename>.html", ts: "ISO timestamp", note: "short note" }
//
// Example:
//   window.playlist.push({ file: "2026-05-23T17-42-08Z.html", ts: "2026-05-23T17:42:08Z", note: "first opening" });

window.playlist = window.playlist || [];

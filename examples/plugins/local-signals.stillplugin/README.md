# Local Signals

Protocol-v1 metadata starter. Import in Still's Library, then explicitly enable its local metadata source. Still creates a connection.json with a new connection ID. A separately invoked producer writes a complete snapshot.json to the same directory. Still never runs package code.

`node examples/plugins/publish-sample.mjs '<connection directory>' working` emits one explicitly labelled sample signal for development. This does not observe any actual agent. Use real supported events and `isSample: false` only in a real producer with honest provenance. Disconnect revokes the connection; never reuse a previous connection ID. MIT licensed example.

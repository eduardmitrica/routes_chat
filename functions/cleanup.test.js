const test = require("node:test");
const assert = require("node:assert/strict");

const { groupDocumentPath } = require("./cleanup");

test("a deleted group's own document is what gets cleaned up", () => {
  assert.equal(
    groupDocumentPath("group-939f82c3-1193-4945-a635-89ed34d27a0a"),
    "groups/group-939f82c3-1193-4945-a635-89ed34d27a0a",
  );
});

test("nothing that is not a group's id is ever cleaned up", () => {
  for (const id of [
    "",
    undefined,
    "alice_bob",
    "group-",
    "group-../users",
    "group-939f82c3-1193-4945-a635-89ed34d27a0a/messages",
    "GROUP-939F82C3-1193-4945-A635-89ED34D27A0A",
  ]) {
    assert.equal(groupDocumentPath(id), null, String(id));
  }
});

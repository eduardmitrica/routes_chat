const test = require("node:test");
const assert = require("node:assert/strict");

const { recipientsOf, notificationFor, deadTokens } = require("./notify");

test("everyone in the chat except the sender is notified", () => {
  assert.deepEqual(recipientsOf(["alice", "bob"], "alice"), ["bob"]);
  assert.deepEqual(recipientsOf(["alice", "bob"], "bob"), ["alice"]);
});

test("a chat without participants notifies nobody", () => {
  assert.deepEqual(recipientsOf(undefined, "alice"), []);
});

test("the notification says who wrote, never what", () => {
  const payload = notificationFor({ senderName: "eduard", chatId: "alice_bob" });

  assert.deepEqual(payload.notification, { title: "eduard", body: "New message" });
  // Only the chat id travels as data; message text would leak past E2EE.
  assert.deepEqual(payload.data, { chatId: "alice_bob" });
  assert.deepEqual(Object.keys(payload).sort(), ["android", "apns", "data", "notification"]);
});

test("a sender without a readable profile still gets a title", () => {
  assert.equal(notificationFor({ senderName: undefined, chatId: "a_b" }).notification.title, "Someone");
});

test("only permanently invalid tokens are removed", () => {
  const tokens = ["works", "uninstalled", "malformed", "flaky"];
  const responses = [
    { success: true },
    { success: false, error: { code: "messaging/registration-token-not-registered" } },
    { success: false, error: { code: "messaging/invalid-registration-token" } },
    { success: false, error: { code: "messaging/internal-error" } },
  ];

  assert.deepEqual(deadTokens(tokens, responses), ["uninstalled", "malformed"]);
});

const test = require("node:test");
const assert = require("node:assert/strict");

const {
  CHANNELS,
  recipientsOf,
  notificationFor,
  friendRequestNotificationFor,
  deadTokens,
  groupMessageNotificationFor,
  groupInvitationNotificationFor,
  isWrittenMessage,
  newlyInvited,
} = require("./notify");

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
  // Only the kind and the chat id travel as data; message text would leak
  // past E2EE.
  assert.deepEqual(payload.data, { type: "message", chatId: "alice_bob" });
  assert.deepEqual(Object.keys(payload).sort(), ["android", "apns", "data", "notification"]);
});

test("a message notification goes to the messages channel, one per chat", () => {
  const { android } = notificationFor({ senderName: "eduard", chatId: "alice_bob" });

  assert.deepEqual(android.notification, { tag: "alice_bob", channelId: CHANNELS.messages });
});

test("a sender without a readable profile still gets a title", () => {
  assert.equal(notificationFor({ senderName: undefined, chatId: "a_b" }).notification.title, "Someone");
  assert.equal(
    friendRequestNotificationFor({ senderName: undefined, requestId: "a_b" }).notification.title,
    "Someone",
  );
});

test("a friend request notification says who, on its own channel", () => {
  const payload = friendRequestNotificationFor({ senderName: "eduard", requestId: "alice_bob" });

  assert.deepEqual(payload.notification, { title: "eduard", body: "Sent you a friend request" });
  assert.deepEqual(payload.data, { type: "friendRequest" });
  assert.deepEqual(payload.android.notification, {
    tag: "alice_bob",
    channelId: CHANNELS.friendRequests,
  });
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

const { isBlocking } = require("./notify");

test("nothing is announced from someone blocked now", () => {
  assert.equal(isBlocking({ blockedSince: { seconds: 1, nanoseconds: 0 } }), true);
});

test("an unblocked person, or no block at all, is announced as usual", () => {
  assert.equal(isBlocking({ earlier: [{ from: 1, to: 2 }] }), false);
  assert.equal(isBlocking({}), false);
  assert.equal(isBlocking(undefined), false);
});

const { messageKindFor, messageRequestNotificationFor } = require("./notify");

test("a friend's message, or one in an accepted chat, is an ordinary message", () => {
  assert.equal(messageKindFor({ isFriend: true, accepted: false, allowFromAnyone: false }), "message");
  assert.equal(messageKindFor({ isFriend: false, accepted: true, allowFromAnyone: false }), "message");
});

test("anyone else's message is a request, unless the user takes none", () => {
  assert.equal(messageKindFor({ isFriend: false, accepted: false, allowFromAnyone: true }), "request");
  assert.equal(messageKindFor({ isFriend: false, accepted: false, allowFromAnyone: false }), "none");
});

test("a message request says who, never what, and opens the requests", () => {
  const payload = messageRequestNotificationFor({ senderName: "eduard", chatId: "alice_bob" });

  assert.deepEqual(payload.notification, {
    title: "eduard",
    body: "Sent you a message request",
  });
  assert.deepEqual(payload.data, { type: "messageRequest", chatId: "alice_bob" });
});

test("a group message says who wrote, never what or which group", () => {
  const payload = groupMessageNotificationFor({ senderName: "ana", groupId: "group-1" });

  assert.deepEqual(payload.notification, { title: "ana", body: "New message in a group" });
  assert.deepEqual(payload.data, { type: "groupMessage", groupId: "group-1" });
  assert.deepEqual(payload.android.notification, { tag: "group-1", channelId: CHANNELS.messages });
  assert.equal(groupMessageNotificationFor({ groupId: "group-1" }).notification.title, "Someone");
});

test("being added to a group names who added you", () => {
  const payload = groupInvitationNotificationFor({ adderName: "ana", groupId: "group-1" });

  assert.deepEqual(payload.notification, { title: "ana", body: "Added you to a group" });
  assert.deepEqual(payload.data, { type: "groupInvitation", groupId: "group-1" });
});

test("events in a group are not announced as messages", () => {
  assert.equal(isWrittenMessage({ senderId: "ana", content: {} }), true);
  assert.equal(isWrittenMessage({ kind: "event", type: "joined", senderId: "ana" }), false);
  assert.equal(isWrittenMessage(undefined), false);
});

test("only people invited by this write are told", () => {
  assert.deepEqual(newlyInvited(undefined, { invitedIds: ["bob", "carol"] }), ["bob", "carol"]);
  assert.deepEqual(newlyInvited({ invitedIds: ["bob"] }, { invitedIds: ["bob", "dan"] }), ["dan"]);
  // Joining takes someone out of the invited, which tells nobody.
  assert.deepEqual(newlyInvited({ invitedIds: ["bob"] }, { invitedIds: [] }), []);
  assert.deepEqual(newlyInvited({ invitedIds: ["bob"] }, undefined), []);
});

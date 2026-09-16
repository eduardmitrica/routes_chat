// Pure helpers for the notification functions, kept free of Firebase so they
// can be unit tested without emulators or credentials.

/**
 * Android notification channels. The app creates them (MainActivity.kt) with
 * these ids, and the user can mute each in the phone's settings.
 */
const CHANNELS = { messages: "messages", friendRequests: "friend_requests" };

/** Everyone in the chat except the sender. */
function recipientsOf(participantIds, senderId) {
  return (participantIds || []).filter((uid) => uid !== senderId);
}

/**
 * The push message for a new chat message.
 *
 * It deliberately carries no message text. Chats are end-to-end encrypted,
 * and a notification passes through FCM in the clear, so it only says who
 * wrote. Tapping it opens the chat, by its id.
 */
function notificationFor({ senderName, chatId }) {
  return {
    notification: { title: senderName || "Someone", body: "New message" },
    data: { type: "message", chatId },
    // One notification per chat on the device, replaced by the next message.
    android: { notification: { tag: chatId, channelId: CHANNELS.messages } },
    apns: { payload: { aps: { "thread-id": chatId } } },
  };
}

/**
 * What a message from [senderId] is to a recipient: an ordinary message from
 * a friend or a chat they accepted, a message request from anyone else, or
 * nothing at all when they take no messages from people who are not friends.
 */
function messageKindFor({ isFriend, accepted, allowFromAnyone }) {
  if (isFriend || accepted) return "message";
  return allowFromAnyone ? "request" : "none";
}

/**
 * The push message for a first message from someone who is not a friend. It
 * says no more than that someone wants to reach them; tapping it opens the
 * requests.
 */
function messageRequestNotificationFor({ senderName, chatId }) {
  return {
    notification: { title: senderName || "Someone", body: "Sent you a message request" },
    data: { type: "messageRequest", chatId },
    android: { notification: { tag: chatId, channelId: CHANNELS.messages } },
    apns: { payload: { aps: { "thread-id": "message-requests" } } },
  };
}

/** The push message for a new friend request. */
function friendRequestNotificationFor({ senderName, requestId }) {
  return {
    notification: { title: senderName || "Someone", body: "Sent you a friend request" },
    data: { type: "friendRequest" },
    android: { notification: { tag: requestId, channelId: CHANNELS.friendRequests } },
    apns: { payload: { aps: { "thread-id": "friend-requests" } } },
  };
}

// FCM errors that mean a token will never work again. Other errors (quota,
// internal) are transient and must not cost the user their registration.
const PERMANENTLY_INVALID = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
]);

/** The tokens FCM rejected for good, in the order they were sent. */
function deadTokens(tokens, responses) {
  return responses
    .map((response, index) =>
      !response.success && PERMANENTLY_INVALID.has(response.error && response.error.code)
        ? tokens[index]
        : null,
    )
    .filter((token) => token !== null);
}

/**
 * Whether the block a user keeps for someone (users/{uid}/blocks/{other})
 * says that person is blocked now. A block is silent: what a blocked person
 * sends is stored as usual, and simply not announced.
 */
function isBlocking(blockData) {
  return Boolean(blockData && blockData.blockedSince);
}

module.exports = {
  CHANNELS,
  recipientsOf,
  notificationFor,
  messageKindFor,
  messageRequestNotificationFor,
  friendRequestNotificationFor,
  deadTokens,
  isBlocking,
};

// Pure helpers for notifyNewMessage, kept free of Firebase so they can be unit
// tested without emulators or credentials.

/** Everyone in the chat except the sender. */
function recipientsOf(participantIds, senderId) {
  return (participantIds || []).filter((uid) => uid !== senderId);
}

/**
 * The push message for a new chat message.
 *
 * It deliberately carries no message text. Chats are going to be end-to-end
 * encrypted, and a notification passes through FCM in the clear, so it only
 * says who wrote. Tapping it has the chat id to work with.
 */
function notificationFor({ senderName, chatId }) {
  return {
    notification: { title: senderName || "Someone", body: "New message" },
    data: { chatId },
    // One notification per chat on the device, replaced by the next message.
    android: { notification: { tag: chatId } },
    apns: { payload: { aps: { "thread-id": chatId } } },
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

module.exports = { recipientsOf, notificationFor, deadTokens };

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineString } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

const { recipientsOf, notificationFor, friendRequestNotificationFor, deadTokens } = require("./notify");

initializeApp();

// The named Firestore database the app uses, from functions/.env (see
// .env.example). This project has no "(default)" database.
const databaseId = defineString("FIRESTORE_DATABASE_ID", {
  description: "Named Firestore database the app reads and writes",
});

// The database is in the eur3 multi-region.
const REGION = "europe-west1";

/**
 * Sends [payload] to every device of [uid], and deletes the tokens FCM
 * reports as permanently invalid (app uninstalled, data cleared).
 *
 * Devices register under users/{uid}/fcmTokens/{token} when their user signs
 * in, and remove themselves before signing out.
 */
async function sendToUser(db, uid, payload, what, context) {
  const tokenDocs = await db.collection(`users/${uid}/fcmTokens`).get();
  const tokens = tokenDocs.docs.map((doc) => doc.id);
  if (tokens.length === 0) return;

  const result = await getMessaging().sendEachForMulticast({ tokens, ...payload });
  const dead = deadTokens(tokens, result.responses);
  await Promise.all(dead.map((token) => db.doc(`users/${uid}/fcmTokens/${token}`).delete()));

  logger.info(`${what} notification sent`, {
    ...context,
    recipient: uid,
    delivered: result.successCount,
    failed: result.failureCount,
    removedTokens: dead.length,
  });
}

/** The username of [uid], which the security rules pin to its owner. */
async function usernameOf(db, uid) {
  const user = await db.doc(`users/${uid}`).get();
  return user.get("username");
}

/** Notifies the other participants of a chat when a message is sent. */
exports.notifyNewMessage = onDocumentCreated(
  { document: "chats/{chatId}/messages/{messageId}", database: databaseId, region: REGION },
  async (event) => {
    const message = event.data && event.data.data();
    if (!message) return;
    const { chatId } = event.params;
    const db = getFirestore(databaseId.value());

    // The first message of a chat is written in the same transaction as the
    // chat itself, so the chat exists by the time this runs.
    const chat = await db.doc(`chats/${chatId}`).get();
    const recipients = recipientsOf(chat.get("participantIds"), message.senderId);
    if (recipients.length === 0) return;

    // senderId is pinned to the author's uid by the security rules, so the
    // name shown cannot be spoofed by the client.
    const payload = notificationFor({ senderName: await usernameOf(db, message.senderId), chatId });
    await Promise.all(
      recipients.map((uid) => sendToUser(db, uid, payload, "New message", { chatId })),
    );
  },
);

/** Notifies the receiver of a new friend request. */
exports.notifyFriendRequest = onDocumentCreated(
  { document: "friendRequests/{requestId}", database: databaseId, region: REGION },
  async (event) => {
    const request = event.data && event.data.data();
    // The rules only let a request be created as Pending, by its sender.
    if (!request || request.status !== "Pending" || !request.receiverId) return;
    const { requestId } = event.params;
    const db = getFirestore(databaseId.value());

    const payload = friendRequestNotificationFor({
      senderName: await usernameOf(db, request.senderId),
      requestId,
    });
    await sendToUser(db, request.receiverId, payload, "Friend request", { requestId });
  },
);

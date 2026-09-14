const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineString } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

const { recipientsOf, notificationFor, deadTokens } = require("./notify");

initializeApp();

// The named Firestore database the app uses, from functions/.env (see
// .env.example). This project has no "(default)" database.
const databaseId = defineString("FIRESTORE_DATABASE_ID", {
  description: "Named Firestore database the app reads and writes",
});

/**
 * Notifies the other participants of a chat when a message is sent.
 *
 * Devices register under users/{uid}/fcmTokens/{token} when their user signs
 * in, and remove themselves before signing out. Tokens FCM reports as
 * permanently invalid (app uninstalled, data cleared) are deleted here.
 */
exports.notifyNewMessage = onDocumentCreated(
  {
    document: "chats/{chatId}/messages/{messageId}",
    database: databaseId,
    // The database is in the eur3 multi-region.
    region: "europe-west1",
  },
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
    const sender = await db.doc(`users/${message.senderId}`).get();
    const payload = notificationFor({ senderName: sender.get("username"), chatId });

    await Promise.all(
      recipients.map(async (uid) => {
        const tokenDocs = await db.collection(`users/${uid}/fcmTokens`).get();
        const tokens = tokenDocs.docs.map((doc) => doc.id);
        if (tokens.length === 0) return;

        const result = await getMessaging().sendEachForMulticast({ tokens, ...payload });
        const dead = deadTokens(tokens, result.responses);
        await Promise.all(dead.map((token) => db.doc(`users/${uid}/fcmTokens/${token}`).delete()));

        logger.info("New message notification sent", {
          chatId,
          recipient: uid,
          delivered: result.successCount,
          failed: result.failureCount,
          removedTokens: dead.length,
        });
      }),
    );
  },
);

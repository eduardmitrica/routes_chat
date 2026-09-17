const {
  onDocumentCreated,
  onDocumentWritten,
  onDocumentDeleted,
} = require("firebase-functions/v2/firestore");
const { defineString } = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { getStorage } = require("firebase-admin/storage");

const {
  recipientsOf,
  notificationFor,
  messageKindFor,
  messageRequestNotificationFor,
  friendRequestNotificationFor,
  deadTokens,
  isBlocking,
  groupMessageNotificationFor,
  groupInvitationNotificationFor,
  isWrittenMessage,
  newlyInvited,
} = require("./notify");
const { groupDocumentPath, groupMediaPrefix } = require("./cleanup");

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

/** Whether [uid] has blocked [otherUid] now. */
async function hasBlocked(db, uid, otherUid) {
  const block = await db.doc(`users/${uid}/blocks/${otherUid}`).get();
  return isBlocking(block.data());
}

/**
 * What a message in [chatId] from [senderId] is to [uid]: "message",
 * "request" or "none". A one-to-one chat's id is the pair of user ids, which
 * is also the id of their friend request.
 */
async function kindForRecipient(db, uid, senderId, chatId) {
  const [friendRequest, decision, settings] = await Promise.all([
    db.doc(`friendRequests/${chatId}`).get(),
    db.doc(`users/${uid}/chatRequests/${chatId}`).get(),
    db.doc(`users/${uid}/settings/messaging`).get(),
  ]);
  return messageKindFor({
    isFriend: friendRequest.get("status") === "Accepted",
    accepted: decision.get("state") === "accepted",
    allowFromAnyone: settings.get("allowFromAnyone") !== false,
  });
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
    // Nothing is announced to someone who blocked the sender, and a message
    // from someone who is not a friend is a request, or nothing at all.
    const participants = recipientsOf(chat.get("participantIds"), message.senderId);
    const recipients = [];
    for (const uid of participants) {
      if (await hasBlocked(db, uid, message.senderId)) continue;
      const kind = await kindForRecipient(db, uid, message.senderId, chatId);
      if (kind !== "none") recipients.push({ uid, kind });
    }
    if (recipients.length === 0) return;

    // senderId is pinned to the author's uid by the security rules, so the
    // name shown cannot be spoofed by the client.
    const senderName = await usernameOf(db, message.senderId);
    await Promise.all(
      recipients.map(({ uid, kind }) =>
        sendToUser(
          db,
          uid,
          kind === "request"
            ? messageRequestNotificationFor({ senderName, chatId })
            : notificationFor({ senderName, chatId }),
          kind === "request" ? "Message request" : "New message",
          { chatId },
        ),
      ),
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
    if (await hasBlocked(db, request.receiverId, request.senderId)) return;

    const payload = friendRequestNotificationFor({
      senderName: await usernameOf(db, request.senderId),
      requestId,
    });
    await sendToUser(db, request.receiverId, payload, "Friend request", { requestId });
  },
);

/**
 * Notifies the other members of a group when someone writes in it. Events
 * such as someone joining are not announced, and nobody hears from someone
 * they blocked.
 */
exports.notifyNewGroupMessage = onDocumentCreated(
  { document: "groups/{groupId}/messages/{messageId}", database: databaseId, region: REGION },
  async (event) => {
    const message = event.data && event.data.data();
    if (!isWrittenMessage(message)) return;
    const { groupId } = event.params;
    const db = getFirestore(databaseId.value());

    const group = await db.doc(`groups/${groupId}`).get();
    // Only members read a group's messages; the invited are not told.
    const recipients = [];
    for (const uid of recipientsOf(group.get("memberIds"), message.senderId)) {
      if (!(await hasBlocked(db, uid, message.senderId))) recipients.push(uid);
    }
    if (recipients.length === 0) return;

    // senderId is pinned to the author's uid by the security rules.
    const senderName = await usernameOf(db, message.senderId);
    const payload = groupMessageNotificationFor({ senderName, groupId });
    await Promise.all(
      recipients.map((uid) => sendToUser(db, uid, payload, "Group message", { groupId })),
    );
  },
);

/**
 * Tells people they were added to a group, naming who added them, unless
 * they blocked that person.
 */
exports.notifyGroupInvitation = onDocumentWritten(
  { document: "groups/{groupId}", database: databaseId, region: REGION },
  async (event) => {
    const before = event.data && event.data.before.data();
    const after = event.data && event.data.after.data();
    const invited = newlyInvited(before, after);
    if (invited.length === 0) return;
    const { groupId } = event.params;
    const db = getFirestore(databaseId.value());

    await Promise.all(
      invited.map(async (uid) => {
        // The rules pin who invited each person to the one who wrote it.
        const adderId = after.invitedBy && after.invitedBy[uid];
        if (!adderId || (await hasBlocked(db, uid, adderId))) return;
        const payload = groupInvitationNotificationFor({
          adderName: await usernameOf(db, adderId),
          groupId,
        });
        await sendToUser(db, uid, payload, "Group invitation", { groupId });
      }),
    );
  },
);

/**
 * Deletes everything a group kept once the group itself is deleted, which
 * happens when its last member leaves: messages and events, reactions, shared
 * keys, history copies, typing and read markers, and its photos in Storage. Nobody can read any of it without
 * the group, since the rules decide from its members, so it would only take
 * up space. Deleting twice is harmless, so a failed run is retried.
 */
exports.cleanUpDeletedGroup = onDocumentDeleted(
  { document: "groups/{groupId}", database: databaseId, region: REGION, retry: true },
  async (event) => {
    const path = groupDocumentPath(event.params.groupId);
    if (!path) return;
    const db = getFirestore(databaseId.value());
    await db.recursiveDelete(db.doc(path));
    await getStorage().bucket().deleteFiles({ prefix: groupMediaPrefix(event.params.groupId) });
    logger.info("Deleted group cleaned up", { groupId: event.params.groupId });
  },
);

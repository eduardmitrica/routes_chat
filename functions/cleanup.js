// Pure helpers for cleaning up after deleted documents, kept free of Firebase
// so they can be unit tested without emulators or credentials.

// A group's id: "group-" and a random UUID (lib/domain/groups/group.dart).
const GROUP_ID = /^group-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

/**
 * The path of the group [groupId], whose messages, events, keys, history
 * copies, typing and read markers go when it is deleted; null for anything
 * that is not a group's id, so a recursive delete never reaches further.
 */
function groupDocumentPath(groupId) {
  return typeof groupId === "string" && GROUP_ID.test(groupId) ? `groups/${groupId}` : null;
}

/**
 * Where the photos and GIFs of the group [groupId] are stored, ending in "/"
 * so no other group's files share the prefix; null for anything that is not
 * a group's id.
 */
function groupMediaPrefix(groupId) {
  return groupDocumentPath(groupId) === null ? null : `group_media/${groupId}/`;
}

module.exports = { groupDocumentPath, groupMediaPrefix };

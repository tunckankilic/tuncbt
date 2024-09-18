const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotification = functions.firestore
    .document("notifications/{notificationId}")
    .onCreate(async (snap, _context) => {
      const notification = snap.data();

      const message = {
        data: {
          taskId: notification.taskId,
          uploadedBy: notification.uploadedBy,
          type: notification.type,
        },
        notification: {
          title: getNotificationTitle(notification.type),
          body: notification.message,
        },
        topic: "notifications",
      };

      try {
        const response = await admin.messaging().send(message);
        console.log("Successfully sent message:", response);
        return null;
      } catch (error) {
        console.log("Error sending message:", error);
        return null;
      }
    });

/**
 * Bildirim türüne göre başlık döndürür.
 * @param {string} type - Bildirim türü.
 * @return {string} Bildirim başlığı.
 */
function getNotificationTitle(type) {
  switch (type) {
    case "new_task":
      return "Yeni Görev";
    case "status_update":
      return "Görev Durumu Güncellendi";
    case "new_comment":
      return "Yeni Yorum";
    default:
      return "Bildirim";
  }
}

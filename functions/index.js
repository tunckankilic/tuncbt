const functions = require("firebase-functions");
const admin = require("firebase-admin");
const i18n = require("./i18n");
admin.initializeApp();

exports.sendNotification = functions.firestore
    .document("notifications/{notificationId}")
    .onCreate(async (snap, _context) => {
        const notification = snap.data();

        // Kullanıcının dil tercihini al
        let userLocale = 'tr'; // Varsayılan dil
        try {
            const userDoc = await admin.firestore()
                .collection('users')
                .doc(notification.uploadedBy)
                .get();
            
            if (userDoc.exists) {
                userLocale = userDoc.data().languageCode || 'tr';
            }
        } catch (error) {
            console.log("Error fetching user language:", error);
        }

        const message = {
            data: {
                taskId: notification.taskId || '',
                uploadedBy: notification.uploadedBy || '',
                type: notification.type || '',
                locale: userLocale,
            },
            notification: {
                title: getNotificationTitle(notification.type, userLocale),
                body: notification.message || '',
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
 * Bildirim türüne göre yerelleştirilmiş başlık döndürür.
 * @param {string} type - Bildirim türü.
 * @param {string} locale - Kullanıcının dil tercihi.
 * @return {string} Yerelleştirilmiş bildirim başlığı.
 */
function getNotificationTitle(type, locale) {
    const key = `notifications.${type}`;
    return i18n.t(key, locale) || i18n.t('notifications.default', locale);
} 
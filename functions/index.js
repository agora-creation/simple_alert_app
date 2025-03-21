/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

//const {onRequest} = require("firebase-functions/v2/https");
//const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require('firebase-functions/v1')
const admin = require('firebase-admin')
admin.initializeApp()

exports.createUserNotice = functions.region('asia-northeast2').firestore.document('user/{userId}/notice/{noticeId}')
    .onCreate(async (snap, context) => {
        const data = snap.data();
        admin.messaging().send(pushMessage(
            data.token,
            data.title,
            data.content,
        ));
    });

const pushMessage = (token, title, body) => ({
    notification: {
        title: title,
        body: body,
    },
    apns: {
        headers: {'apns-priority': '10'},
        payload: {
            aps: {
                badge: 1,
                sound: 'default',
            },
        },
    },
    token: token,
})
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");

initializeApp();

exports.onTripStarted = onDocumentCreated(
    "trips/{tripId}",
    async (event) => {
        const data = event.data?.data();
        if (!data) return;

        const tripInfo = data["e-tripInfo"];
        const emergencyContacts = data["d-emergencyContacts"];
        const userName = data["b-userInfo"]?.userName ?? "المسافر";

        if (!tripInfo) return;
        if (!emergencyContacts?.length) return;

        // SMS sending is temporarily disabled
        // waiting for commercial registration to activate provider
        for (const contact of emergencyContacts) {
            console.log(`[SMS PENDING] Would send to ${contact.phone} — ${userName} started a trip to ${tripInfo.destination}`);
        }
    }
);
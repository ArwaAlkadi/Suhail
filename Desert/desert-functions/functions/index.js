/**
 * index.js — Desert App Cloud Functions
 */

const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const axios = require("axios");

initializeApp();

const db = getFirestore();

// WhatsApp server URL
const WHATSAPP_SERVER = "https://suhail-whatsapp-production.up.railway.app";

// 35 minutes without any Firebase upload
const NO_RECENT_UPLOAD_LIMIT = 35 * 60;

// MARK: - Scheduled Trigger
exports.checkOverdueTrips = onSchedule("every 5 minutes", async () => {
    const now = Date.now() / 1000;

    const snapshot = await db
        .collection("trips")
        .where("b-status", "in", ["active", "overdue"])
        .get();

    for (const doc of snapshot.docs) {
        const trip = doc.data();
        const tripId = doc.id;

        const tripInfo    = trip["e-tripInfo"] ?? {};
        const location    = trip["c-lastKnownLocation"] ?? {};
        const alertStatus = trip["h-alertStatus"] ?? {};

        const returnTime     = tripInfo.returnTime;
        const lastUploadTime = location.lastUploadTime ?? 0;

        if (!returnTime) continue;

        const returnTimePassed       = now >= returnTime;
        const noRecentUploadFor35Min = lastUploadTime === 0 || now - lastUploadTime >= NO_RECENT_UPLOAD_LIMIT;
        const alertAlreadySent       = alertStatus.alertSent === true;

        if (returnTimePassed && noRecentUploadFor35Min && !alertAlreadySent) {
            await sendAlert({ tripId, trip, type: "initial" });

            await db.collection("trips").doc(tripId).update({
                "b-status": "overdue",
                "h-alertStatus": {
                    alertSent: true,
                    alertSentAt: now,
                    alertSentAtReadable: new Date().toLocaleString("ar-SA"),
                    updatedAlertSent: false,
                    reason: "return_time_passed_no_recent_upload"
                }
            });

            console.log(`Initial overdue alert sent for ${tripId}`);
        }
    }
});

// MARK: - Location Update Trigger
exports.onLocationUpdatedAfterOverdue = onDocumentUpdated("trips/{tripId}", async (event) => {
    const before = event.data.before.data();
    const after  = event.data.after.data();

    const tripId = event.params.tripId;

    const beforeLocation = before["c-lastKnownLocation"] ?? {};
    const afterLocation  = after["c-lastKnownLocation"] ?? {};
    const alertStatus    = after["h-alertStatus"] ?? {};
    const status         = after["b-status"];

    const oldUploadTime    = beforeLocation.lastUploadTime ?? 0;
    const newUploadTime    = afterLocation.lastUploadTime ?? 0;
    const newUploadArrived = newUploadTime > oldUploadTime;

    if (status !== "overdue") return;
    if (!newUploadArrived) return;
    if (alertStatus.alertSent !== true) return;
    if (alertStatus.updatedAlertSent === true) return;

    await sendAlert({ tripId, trip: after, type: "updated" });

    await db.collection("trips").doc(tripId).update({
        "h-alertStatus.updatedAlertSent": true,
        "h-alertStatus.updatedAlertSentAt": Date.now() / 1000,
        "h-alertStatus.updatedAlertSentAtReadable": new Date().toLocaleString("ar-SA")
    });

    console.log(`Updated location alert sent for ${tripId}`);
});

// MARK: - Send Alert Helper
async function sendAlert({ tripId, trip, type }) {
    const tripInfo = trip["e-tripInfo"] ?? {};
    const userInfo = trip["c-userInfo"] ?? {};
    const carInfo  = trip["f-carInfo"] ?? {};
    const contacts = trip["d-emergencyContacts"] ?? [];
    const location = trip["c-lastKnownLocation"] ?? {};

    if (contacts.length === 0) {
        console.log(`No emergency contacts for ${tripId}`);
        return;
    }

    const userName    = userInfo.userName    ?? "Unknown";
    const phone       = userInfo.phoneNumber ?? "Unknown";
    const tripName    = tripInfo.tripName    ?? "Desert Trip";
    const destination = tripInfo.destination ?? "Unknown";
    const returnTime  = tripInfo.returnTimeReadable ?? "Unknown";
    const carDetails  = `${carInfo.carColor ?? ""} ${carInfo.carName ?? ""}`.trim() || "Unknown";
    const plate       = `${carInfo.plateNumbers ?? ""} | ${carInfo.plateLetters ?? ""}`.trim() || "Unknown";
    const lat         = location.lat ?? "Unknown";
    const lng         = location.lng ?? "Unknown";
    const lastUpload  = location.lastUploadTimeReadable ?? "Unknown";

    const title = type === "updated"
        ? "🚨 تحديث موقع جديد بعد التأخر"
        : "🚨 تنبيه عدم العودة";

    const message = type === "updated"
        ? `${title}\n\nتم استقبال موقع جديد لـ ${userName} بعد إرسال تنبيه عدم العودة.\n\nآخر موقع: ${lat}, ${lng}\nآخر تحديث: ${lastUpload}`
        : `${title}\n\nلم يعد ${userName} في الموعد المحدد من رحلته البرية.\n\nالجوال: ${phone}\nاسم الرحلة: ${tripName}\nالوجهة: ${destination}\nوقت العودة: ${returnTime}\nالسيارة: ${carDetails}\nاللوحة: ${plate}\nآخر موقع: ${lat}, ${lng}\nآخر تحديث: ${lastUpload}`;

    for (const contact of contacts) {
        const contactPhone = contact.phone?.replace(/\D/g, '');
        if (!contactPhone) continue;

        try {
            await axios.post(`${WHATSAPP_SERVER}/send`, {
                phone: contactPhone,
                message
            });
            console.log(`WhatsApp sent to ${contactPhone} for trip ${tripId}`);
        } catch (err) {
            console.error(`Failed to send WhatsApp to ${contactPhone}:`, err.message);
        }
    }
}

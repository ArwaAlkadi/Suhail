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

// Max updated alerts before auto-completing the trip
const MAX_UPDATED_ALERTS = 3;

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

        const status = trip["b-status"];
        const tripInfo = trip["e-tripInfo"] ?? {};
        const location = trip["c-lastKnownLocation"] ?? {};
        const alertStatus = trip["h-alertStatus"] ?? {};

        const returnTime = tripInfo.returnTime;
        const lastUploadTime = location.lastUploadTime ?? 0;

        if (!returnTime) continue;

        const returnTimePassed = now >= returnTime;
        const noRecentUploadFor35Min =
            lastUploadTime === 0 ||
            now - lastUploadTime >= NO_RECENT_UPLOAD_LIMIT;

        const alertAlreadySent = alertStatus.alertSent === true;

        // Step 1: Mark trip as overdue immediately when return time passes
        if (returnTimePassed && status !== "overdue") {
            await db.collection("trips").doc(tripId).update({
                "b-status": "overdue"
            });

            console.log(`Trip marked as overdue: ${tripId}`);
        }

        // Step 2: Send alert only if no recent upload for 35 minutes
        if (returnTimePassed && noRecentUploadFor35Min && !alertAlreadySent) {
            const alertSentSuccessfully = await sendAlert({
                tripId,
                trip,
                type: "initial"
            });

            if (!alertSentSuccessfully) {
                console.log(`Initial alert not marked as sent for ${tripId}`);
                continue;
            }

            await db.collection("trips").doc(tripId).update({
                "h-alertStatus": {
                    alertSent: true,
                    alertSentAt: now,
                    alertSentAtReadable: new Date().toLocaleString("ar-SA"),
                    updatedAlertSent: false,
                    updatedAlertSentAt: 0,
                    updatedAlertCount: 0,
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
    const after = event.data.after.data();

    const tripId = event.params.tripId;

    const beforeLocation = before["c-lastKnownLocation"] ?? {};
    const afterLocation = after["c-lastKnownLocation"] ?? {};
    const status = after["b-status"];

    const oldUploadTime = beforeLocation.lastUploadTime ?? 0;
    const newUploadTime = afterLocation.lastUploadTime ?? 0;
    const newUploadArrived = newUploadTime > oldUploadTime;

    if (status !== "overdue") return;
    if (!newUploadArrived) return;

    const now = Date.now() / 1000;
    const tripRef = db.collection("trips").doc(tripId);

    let shouldSendAlert = false;
    let newCount = 0;
    let shouldCompleteTrip = false;

    try {
        await db.runTransaction(async (transaction) => {
            const tripDoc = await transaction.get(tripRef);
            const currentAlertStatus = tripDoc.data()["h-alertStatus"] ?? {};

            // Initial alert must have been sent first
            if (currentAlertStatus.alertSent !== true) return;

            const currentCount = currentAlertStatus.updatedAlertCount ?? 0;

            // Already reached max — stop
            if (currentCount >= MAX_UPDATED_ALERTS) return;

            newCount = currentCount + 1;
            shouldCompleteTrip = newCount >= MAX_UPDATED_ALERTS;

            const updates = {
                "h-alertStatus.updatedAlertSent": true,
                "h-alertStatus.updatedAlertSentAt": now,
                "h-alertStatus.updatedAlertSentAtReadable": new Date().toLocaleString("ar-SA"),
                "h-alertStatus.updatedAlertCount": newCount
            };

            if (shouldCompleteTrip) {
                updates["b-status"] = "completed";
            }

            transaction.update(tripRef, updates);
            shouldSendAlert = true;
        });
    } catch (err) {
        console.error(`Transaction failed for ${tripId}:`, err.message);
        return;
    }

    if (!shouldSendAlert) {
        console.log(`Updated alert skipped for ${tripId} — max alerts reached or initial not sent`);
        return;
    }

    // Read latest data from Firebase to ensure we send the most recent location
    // This handles the case where 40 uploads arrive simultaneously — we always
    // send the newest location regardless of which trigger won the transaction
    const latestDoc = await tripRef.get();
    const latestTrip = latestDoc.data();

    const updateSentSuccessfully = await sendAlert({
        tripId,
        trip: latestTrip,
        type: "updated"
    });

    if (!updateSentSuccessfully) {
        console.log(`Updated alert failed to send for ${tripId}`);

        // Rollback count so it can be retried
        await tripRef.update({
            "h-alertStatus.updatedAlertCount": newCount - 1,
            "h-alertStatus.updatedAlertSent": newCount - 1 > 0,
            ...(shouldCompleteTrip ? { "b-status": "overdue" } : {})
        });
    } else {
        if (shouldCompleteTrip) {
            console.log(`Trip auto-completed after ${MAX_UPDATED_ALERTS} updated alerts — ${tripId}`);
        } else {
            console.log(`Updated alert #${newCount} sent for ${tripId}`);
        }
    }
});

// MARK: - Send Alert Helper
async function sendAlert({ tripId, trip, type }) {
    const tripInfo = trip["e-tripInfo"] ?? {};
    const userInfo = trip["c-userInfo"] ?? {};
    const contacts = trip["d-emergencyContacts"] ?? [];
    const location = trip["c-lastKnownLocation"] ?? {};

    if (contacts.length === 0) {
        console.log(`No emergency contacts for ${tripId}`);
        return false;
    }

    const lat = location.lat;
    const lng = location.lng;

    if (!lat || !lng || lat === "Unknown" || lng === "Unknown") {
        console.log(`No location available for ${tripId}, alert not sent`);
        return false;
    }

    const userName = userInfo.userName ?? "المستخدم";
    const tripStartTime = tripInfo.startTimeReadable ?? "غير معروف";
    const returnTime = tripInfo.returnTimeReadable ?? "غير معروف";
    const lastUpload = location.lastUploadTimeReadable ?? "غير معروف";

    const mapsLink = `https://maps.google.com/?q=${lat},${lng}`;
    const tripLink = `https://suhail-1.web.app/?id=${tripId}`;

    const batteryLevel = location.deviceBatteryLevel;
    const batteryLine = (batteryLevel != null && batteryLevel >= 0)
        ? `\nنسبة البطارية:\n${batteryLevel}%`
        : "";

    const message = type === "updated"
        ? `السلام عليكم،

وصلنا تحديث جديد لموقع ${userName} بعد تنبيه عدم العودة السابق.

الموقع الحالي:
${mapsLink}

تفاصيل الرحلة كاملة:
${tripLink}

آخر تحديث للموقع:
${lastUpload}${batteryLine}

راح نستمر بمتابعة أي تحديثات جديدة، وبنبلغكم مباشرة إذا وصل موقع جديد.

— تطبيق سهيل`
        : `السلام عليكم،

ما وصلنا أي تحديث لموقع ${userName} بعد وقت العودة المتوقع. الرحلة بدأت الساعة ${tripStartTime} وكان المفروض تنتهي الساعة ${returnTime}.

آخر موقع معروف:
${mapsLink}

تفاصيل الرحلة كاملة:
${tripLink}

آخر تحديث للموقع:
${lastUpload}${batteryLine}

نعرف إن الموقف ممكن يسبب قلق، لذلك ننصح بمحاولة التواصل معه مباشرة. وإذا ما قدرتوا توصلون له، نرجو التواصل مع الجهات المختصة أو مع دعم إنجاد على الرقم:
920018911

راح نستمر بمتابعة أي تحديثات جديدة، وبنبلغكم مباشرة إذا وصل موقع جديد.

— تطبيق سهيل`;

    let sentToAtLeastOneContact = false;

    for (const contact of contacts) {
        const contactPhone = contact.phone?.replace(/\D/g, "");
        if (!contactPhone) continue;

        try {
            const response = await axios.post(`${WHATSAPP_SERVER}/send`, {
                phone: contactPhone,
                message
            });

            if (response.data?.success === true) {
                sentToAtLeastOneContact = true;
                console.log(`WhatsApp sent to ${contactPhone} for trip ${tripId}`);
            } else {
                console.error(`WhatsApp failed for ${contactPhone}:`, response.data);
            }
        } catch (err) {
            console.error(`Failed to send WhatsApp to ${contactPhone}:`, err.message);
        }
    }

    return sentToAtLeastOneContact;
}
